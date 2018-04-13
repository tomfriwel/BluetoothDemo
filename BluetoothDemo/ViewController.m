//
//  ViewController.m
//  BluetoothDemo
//
//  Created by tomfriwel on 14/09/2017.
//  Copyright © 2017 tomfriwel. All rights reserved.
//

//http://www.jianshu.com/p/87c30628ddaa

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSData+Conversion.h"

#import "BLDeviceInfoCell.h"

/** 判断手机蓝牙状态 */
#define SERVICE_UUID        @"CDD1"
#define CHARACTERISTIC_READ_UUID @"CDD2"
#define CHARACTERISTIC_WRITE_UUID @"CDD3"
//#define TEST_SERVICE_UUID @"CDD1"

@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>
/* 中心管理者 */
@property (nonatomic, strong) CBCentralManager *centralManager;
/* 连接到的外设 */
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristicRead;
@property (nonatomic, strong) CBCharacteristic *characteristicWrite;

@property (nonatomic, strong) NSArray *invalidatedServices;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *peripherals;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.myTableView registerNib:[UINib nibWithNibName:NSStringFromClass([BLDeviceInfoCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:BLDeviceInfoCellIdentifier];
    
//    [self.myTableView registerClass:BLDeviceInfoCell.class forCellReuseIdentifier:BLDeviceInfoCellIdentifier];
    
    [self centralManager];
}

-(CBCentralManager *)centralManager {
    if (!_centralManager) {
        // 创建中心设备管理器，会回调centralManagerDidUpdateState
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return _centralManager;
}

//-(void)setPeripheral:(CBPeripheral *)peripheral {
//    _peripheral = peripheral;
//}

-(NSArray *)invalidatedServices {
    if (!_invalidatedServices) {
        _invalidatedServices = @[];
    }
    return _invalidatedServices;
}

-(NSMutableArray *)peripherals {
    if (!_peripherals) {
        _peripherals = [[NSMutableArray alloc] init];
    }
    return _peripherals;
}

#pragma mark - util methods


id dataToArrayBuffer(NSData* data)
{
    return @{
             @"CDVType" : @"ArrayBuffer",
             @"data" :[data base64EncodedStringWithOptions:0],
             @"bytes" :[data toArray]
             };
}

-(void)showAlert:(NSString *)message {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Info"
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

+(BOOL)checkAvailable:(CBPeripheral *)peripheral {
    if(!peripheral) {
        return NO;
    }
    
    BOOL res = NO;
    switch (peripheral.state) {
        case CBPeripheralStateConnected:
            res = YES;
            break;
            
        default:
            res = NO;
            break;
    }
    return res;
}

#pragma mark - methods

/** 写入数据 */
- (IBAction)didClickPost:(id)sender {
    NSString *str = self.textField.text;
    NSLog(@"%s, %@", __FUNCTION__, str);
    
    if([[self class] checkAvailable:self.peripheral]) {
        // 用NSData类型来写入
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        // 根据上面的特征self.characteristic来写入数据
        [self.peripheral writeValue:data forCharacteristic:self.characteristicWrite type:CBCharacteristicWriteWithoutResponse];
    }
    else {
        NSLog(@"外设不可用，重新扫描");
        
        [self centralManagerDidUpdateState:self.centralManager];
    }
}

/** 读取数据 */
- (IBAction)didClickGet:(id)sender {
    [self.peripheral readValueForCharacteristic:self.characteristicRead];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    BLDeviceInfoCell *cell  = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(BLDeviceInfoCell.class)];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(BLDeviceInfoCell.class) owner:self options:nil];
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:BLDeviceInfoCell.class]){
                cell =  currentObject;
                break;
            }
        }
    }
    
    CBPeripheral *peripheral = self.peripherals[row];
    if (!cell) {
        NSLog(@"new cell");
        cell = [[BLDeviceInfoCell alloc] init];
    }
    NSString *name = peripheral.name;
    
    name = name?name:@"unknow";
    
    cell.nameLabel.text = name;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [BLDeviceInfoCell cellHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    CBPeripheral *peripheral = self.peripherals[row];
    
    switch (peripheral.state) {
        case CBPeripheralStateConnected:
            break;
        case CBPeripheralStateDisconnected:
            break;
        case CBPeripheralStateConnecting:
            break;
        case CBPeripheralStateDisconnecting:
            break;
            
        default:
            break;
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // 蓝牙可用，开始扫描外设
    if (@available(iOS 10.0, *)) {
        if (central.state == CBManagerStatePoweredOn) {
            NSLog(@"蓝牙可用");
            // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
//            [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TEST_SERVICE_UUID]] options:nil];
            [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
        }
    } else {
        // Fallback on earlier versions
    }
    if(central.state==CBCentralManagerStateUnsupported) {
        NSLog(@"该设备不支持蓝牙");
        [self showAlert:@"BLE is unsupported"];
    }
    if (central.state==CBCentralManagerStatePoweredOff) {
        NSLog(@"蓝牙已关闭");
        [self showAlert:@"BLE is powerd off"];
    }
}

/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 对外设对象进行强引用
    self.peripheral = peripheral;
    
    //    if ([peripheral.name hasPrefix:@"WH"]) {
    //        // 可以根据外设名字来过滤外设
    //        [central connectPeripheral:peripheral options:nil];
    //    }
    NSLog(@"advertisementData:%@", advertisementData);
    NSData *mfgData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (mfgData) {
        NSLog(@"%@", dataToArrayBuffer(mfgData));
    }
    
    // 连接外设
    [central connectPeripheral:peripheral options:nil];
}

/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    // 可以停止扫描
    [self.centralManager stopScan];
    // 设置代理
    peripheral.delegate = self;
    // 根据UUID来寻找服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    NSLog(@"连接成功");
}

/** 连接失败的回调 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接失败");
}

/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开连接");
    // 断开连接可以设置重新连接
    [central connectPeripheral:peripheral options:nil];
}

#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        NSLog(@"所有的服务：%@",service);
    }
    
    //    再重复一遍，一般开发中可以设置两个特征，一个用来发送数据，一个用来接收中心设备写过来的数据。
//    这里用一个属性引用特征，是为了后面通过这个特征向外设写入数据或发送指令。
//    readValueForCharacteristic方法是直接读一次这个特征上的数据。
    
    // 这里仅有一个服务，所以直接获取
    CBService *service = peripheral.services.lastObject;
    if(!service) {
        NSLog(@"no service");
        return;
    }
    // 根据UUID寻找服务中的特征
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_READ_UUID], [CBUUID UUIDWithString:CHARACTERISTIC_WRITE_UUID]] forService:service];
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
        
        if([characteristic.UUID.UUIDString isEqualToString:CHARACTERISTIC_READ_UUID]) {
            self.characteristicRead = characteristic;
        }
        else if([characteristic.UUID.UUIDString isEqualToString:CHARACTERISTIC_WRITE_UUID]) {
            self.characteristicWrite = characteristic;
        }
    }
    
    // 这里只获取一个特征，写入数据的时候需要用到这个特征
//    self.characteristic = service.characteristics.lastObject;
//
    if(!self.characteristicWrite || !self.characteristicRead) {
        NSLog(@"no characteristic");
        return;
    }
//    // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
    [peripheral readValueForCharacteristic:self.characteristicRead];
//
//    // 订阅通知
    [peripheral setNotifyValue:YES forCharacteristic:self.characteristicRead];
//    [peripheral setNotifyValue:YES forCharacteristic:self.characteristicWrite];
}

/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
    } else {
        NSLog(@"取消订阅");
    }
}

/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    // 拿到外设发送过来的数据,readValueForCharacteristic
    if([characteristic.UUID.UUIDString isEqualToString:CHARACTERISTIC_READ_UUID]) {
        NSData *data = characteristic.value;
        self.textField.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"写入成功");
}

-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    NSLog(@"%s", __FUNCTION__);
    
    self.invalidatedServices = invalidatedServices;
}


@end
