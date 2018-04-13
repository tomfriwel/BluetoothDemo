//
//  ViewController.m
//  BluetoothDemoMac
//
//  Created by tomfriwel on 15/09/2017.
//  Copyright © 2017 tomfriwel. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID        @"CDD1"
#define CHARACTERISTIC_READ_UUID @"CDD2"
#define CHARACTERISTIC_WRITE_UUID @"CDD3"

@interface ViewController()<CBPeripheralManagerDelegate, NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *textField;

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *characteristicRead;
@property (nonatomic, strong) CBMutableCharacteristic *characteristicWrite;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建外设管理器，会回调peripheralManagerDidUpdateState方法
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
#pragma mark - util

+(void)showAlert:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    //    [alert setInformativeText:@"Informative text."];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
}

#pragma mark - methods

- (IBAction)sendValue:(id)sender {
    BOOL sendSuccess = [self.peripheralManager updateValue:[self.textField.stringValue dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristicRead onSubscribedCentrals:nil];
    if (sendSuccess) {
        NSLog(@"数据发送成功");
    }else {
        NSLog(@"数据发送失败");
    }
}
-(void)setupServiceAndCharacteristics {
    // 创建服务
    CBUUID *serviceID = [CBUUID UUIDWithString:SERVICE_UUID];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceID primary:YES];
    // 创建服务中的特征
    CBUUID *characteristicIDRead = [CBUUID UUIDWithString:CHARACTERISTIC_READ_UUID];
    CBMutableCharacteristic *characteristicRead = [
                                                   [CBMutableCharacteristic alloc]
                                                   initWithType:characteristicIDRead
                                                   properties:
                                                   CBCharacteristicPropertyRead |
                                                   CBCharacteristicPropertyNotify
                                                   value:nil
                                                   permissions:CBAttributePermissionsReadable |
                                                   CBAttributePermissionsWriteable
                                                   ];
    
    CBUUID *characteristicIDWrite = [CBUUID UUIDWithString:CHARACTERISTIC_WRITE_UUID];
    CBMutableCharacteristic *characteristicWrite = [
                                                    [CBMutableCharacteristic alloc]
                                                    initWithType:characteristicIDWrite
                                                    properties:
                                                    CBCharacteristicPropertyWrite |
                                                    CBCharacteristicPropertyNotify |
                                                    CBCharacteristicPropertyWriteWithoutResponse
                                                    value:nil
                                                    permissions:CBAttributePermissionsReadable |
                                                    CBAttributePermissionsWriteable
                                                    ];
    // 特征添加进服务
    service.characteristics = @[characteristicRead, characteristicWrite];
    // 服务加入管理
    [self.peripheralManager addService:service];
    // 为了手动给中心设备发送数据
    self.characteristicRead = characteristicRead;
    self.characteristicWrite = characteristicWrite;
}

#pragma mark - CBPeripheralManagerDelegate

/*
 设备的蓝牙状态
 CBManagerStateUnknown = 0,  未知
 CBManagerStateResetting,    重置中
 CBManagerStateUnsupported,  不支持
 CBManagerStateUnauthorized, 未验证
 CBManagerStatePoweredOff,   未启动
 CBManagerStatePoweredOn,    可用
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBManagerStatePoweredOn) {
        // 创建Service（服务）和Characteristics（特征）
        [self setupServiceAndCharacteristics];
        // 根据服务的UUID开始广播
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]], CBAdvertisementDataLocalNameKey:@"Test tomfriwel"}];
    }
    else {
        [ViewController showAlert:@"请检查蓝牙是否开启"];
    }
}

/** 中心设备读取数据的时候回调 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"%s", __FUNCTION__);
    // 请求中的数据，这里把文本框中的数据发给中心设备
    request.value = [self.textField.stringValue dataUsingEncoding:NSUTF8StringEncoding];
    // 成功响应请求
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

/** 中心设备写入数据的时候回调 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    NSLog(@"%s", __FUNCTION__);
    // 写入数据的请求
    CBATTRequest *request = requests.lastObject;
    // 把写入的数据显示在文本框中
    self.textField.stringValue = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
}

/** 订阅成功回调 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

/** 取消订阅回调 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - NSTextFieldDelegate

-(void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"controlTextDidChange: stringValue == %@", [textField stringValue]);
    [self sendValue:nil];
}

@end
