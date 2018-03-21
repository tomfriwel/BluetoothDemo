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

#import "BLDeviceInfoCell.h"

@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>
/* 中心管理者 */
@property (nonatomic, strong) CBCentralManager *centralManager;
/* 连接到的外设 */
//@property (nonatomic, strong) CBPeripheral *peripheral;

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
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _centralManager;
}

-(NSMutableArray *)peripherals {
    if (!_peripherals) {
        _peripherals = [[NSMutableArray alloc] init];
    }
    return _peripherals;
}

-(BOOL)addPeripheral:(CBPeripheral *)peripheral {
    //    NSLog(@"identifier:%@",[self.peripherals valueForKey:@"identifier"]);
    //    if (![[self.peripherals valueForKey:@"identifier"] containsObject:peripheral.identifier])
    if (![self.peripherals containsObject:peripheral])
    {
        [self.peripherals addObject:peripheral];
        [self.myTableView reloadData];
        NSLog(@"names: %@", [self.peripherals valueForKey:@"name"]);
        return YES;
    }
    else {
        //        NSInteger index = [self.peripherals valueForKey:peripheral.identifier]
    }
    return NO;
}

-(void)handlePeripheralInfo:(CBPeripheral *)peripheral {
    NSLog(@"services:%@", peripheral.services);}

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
            [self handlePeripheralInfo:peripheral];
            break;
        case CBPeripheralStateDisconnected:
            [self.centralManager connectPeripheral:peripheral options:nil];
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

//只要中心管理者初始化 就会触发此代理方法 判断手机蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case 0:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case 1:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case 2:
            NSLog(@"CBCentralManagerStateUnsupported");//不支持蓝牙
            break;
        case 3:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case 4:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");//蓝牙未开启
        }
            break;
        case 5:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");//蓝牙已开启
            // 在中心管理者成功开启后再进行一些操作
            // 搜索外设
            [self.centralManager scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                                        options:nil]; // dict,条件
            // 搜索成功之后,会调用我们找到外设的代理方法
            // - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI; //找到外设
        }
            break;
        default:
            break;
    }
}
// 发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central // 中心管理者
 didDiscoverPeripheral:(CBPeripheral *)peripheral // 外设
     advertisementData:(NSDictionary *)advertisementData // 外设携带的数据
                  RSSI:(NSNumber *)RSSI // 外设发出的蓝牙信号强度
{
    [self addPeripheral:peripheral];
    //    [self.myTableView reloadData];
    //    NSLog(@"didDiscoverPeripheral name:%@", peripheral.name);
    //    NSLog(@"%s, line = %d, cetral = %@,peripheral = %@, advertisementData = %@, RSSI = %@", __FUNCTION__, __LINE__, central, peripheral, advertisementData, RSSI);
    
    /*
     peripheral = <CBPeripheral: 0x166668f0 identifier = C69010E7-EB75-E078-FFB4-421B4B951341, Name = "OBand-75", state = disconnected>, advertisementData = {
     kCBAdvDataChannel = 38;
     kCBAdvDataIsConnectable = 1;
     kCBAdvDataLocalName = OBand;
     kCBAdvDataManufacturerData = <4c69616e 0e060678 a5043853 75>;
     kCBAdvDataServiceUUIDs =     (
     FEE7
     );
     kCBAdvDataTxPowerLevel = 0;
     }, RSSI = -55
     根据打印结果,我们可以得到运动手环它的名字叫 OBand-75
     
     */
    
    // 需要对连接到的外设进行过滤
    // 1.信号强度(40以上才连接, 80以上连接)
    // 2.通过设备名(设备字符串前缀是 OBand)
    // 在此时我们的过滤规则是:有OBand前缀并且信号强度大于35
    // 通过打印,我们知道RSSI一般是带-的
    
    if ([peripheral.name hasPrefix:@"OBand"]) {
        // 在此处对我们的 advertisementData(外设携带的广播数据) 进行一些处理
        
        // 通常通过过滤,我们会得到一些外设,然后将外设储存到我们的可变数组中,
        // 这里由于附近只有1个运动手环, 所以我们先按1个外设进行处理
        
        // 标记我们的外设,让他的生命周期 = vc
//        self.peripheral = peripheral;
        // 发现完之后就是进行连接
//        [self.centralManager connectPeripheral:self.peripheral options:nil];
        NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    }
}

// 中心管理者连接外设成功
- (void)centralManager:(CBCentralManager *)central // 中心管理者
  didConnectPeripheral:(CBPeripheral *)peripheral // 外设
{
    NSLog(@"%s, line = %d, %@=连接成功", __FUNCTION__, __LINE__, peripheral.name);
    // 连接成功之后,可以进行服务和特征的发现
    
    //  设置外设的代理
    peripheral.delegate = self;
    
    // 外设发现服务,传nil代表不过滤
    // 这里会触发外设的代理方法 - (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [peripheral discoverServices:nil];
    [peripheral readRSSI];
}

// 外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
}

// 丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
}


#pragma mark - CBPeripheralDelegate
// 发现外设服务里的特征的时候调用的代理方法(这个是比较重要的方法，你在这里可以通过事先知道UUID找到你需要的特征，订阅特征，或者这里写入数据给特征也可以)
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    
    for (CBCharacteristic *cha in service.characteristics) {
        //        NSLog(@"%s, line = %d, char = %@", __FUNCTION__, __LINE__, cha);
        NSLog(@"CBCharacteristic:%@", cha);
    }
}
// 更新特征的value的时候会调用 （凡是从蓝牙传过来的数据都要经过这个回调，简单的说这个方法就是你拿数据的唯一方法） 你可以判断是否
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"characteristic: %s, line = %d", __FUNCTION__, __LINE__);
    if ([characteristic  isEqual: @"你要的特征的UUID或者是你已经找到的特征"]) {
        //characteristic.value就是你要的数据
    }
}

-(void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"peripheralDidUpdateName:%@", peripheral.name);
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error {
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    NSLog(@"didReadRSSI:%@", RSSI);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    [self handlePeripheralInfo:peripheral];
}


@end
