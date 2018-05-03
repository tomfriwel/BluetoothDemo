//
//  WelBluetooth.m
//  BluetoothDemo
//
//  Created by tomfriwel on 2018/5/3.
//  Copyright © 2018 tomfriwel. All rights reserved.
//

#import "WelBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>


//设备状态改变的委托
typedef void (^CentralManagerDidUpdateStateBlock)(CBCentralManager *central);
typedef void (^CentralManagerWillRestoreStateBlock)(CBCentralManager *central, NSDictionary<NSString *, id> *dict);
typedef void (^CentralManagerDidDiscoverPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary<NSString *, id> *advertisementData, NSNumber *RSSI);
typedef void (^CentralManagerDidConnectPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral);
typedef void (^CentralManagerDidFailToConnectPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);
typedef void (^CentralManagerDidDisconnectPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);


typedef void (^PeripheralsDidChangeBlock)(NSArray *peripherals);

@interface WelBluetooth()<CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate>

@property (nonatomic, copy) CentralManagerDidUpdateStateBlock centralManagerDidUpdateStateBlock;
@property (nonatomic, copy) CentralManagerWillRestoreStateBlock centralManagerWillRestoreStateBlock;
@property (nonatomic, copy) CentralManagerDidDiscoverPeripheralBlock centralManagerDidDiscoverPeripheralBlock;
@property (nonatomic, copy) CentralManagerDidConnectPeripheralBlock centralManagerDidConnectPeripheralBlock;
@property (nonatomic, copy) CentralManagerDidFailToConnectPeripheralBlock centralManagerDidFailToConnectPeripheralBlock;
@property (nonatomic, copy) CentralManagerDidDisconnectPeripheralBlock centralManagerDidDisconnectPeripheralBlock;

@property (nonatomic, copy) PeripheralsDidChangeBlock peripheralsDidChangeBlock;

@end

@implementation WelBluetooth

+(WelBluetooth *)shared {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

-(NSMutableArray *)peripherals {
    if(!_peripherals) {
        _peripherals = [[NSMutableArray alloc] init];
    }
    
    return _peripherals;
}

-(CBCentralManager *)centralManager {
    if (!_centralManager) {
        // 创建中心设备管理器，会回调centralManagerDidUpdateState
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return _centralManager;
}

-(CBPeripheralManager *)peripheralManager {
    if (!_peripheralManager) {
        // 创建外设管理器，会回调peripheralManagerDidUpdateState方法
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return _peripheralManager;
}

-(instancetype)init {
    self = [super init];
    
    if(self) {
        
    }
    
    return self;
}

#pragma mark - peripheral handlers

-(void)addPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI {
    if (peripheral.name.length <= 0) {
        return ;
    }
    
    if (self.peripherals.count == 0) {
        NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
        [self.peripherals addObject:dict];
    } else {
        BOOL isExist = NO;
        for (int i = 0; i < self.peripherals.count; i++) {
            NSDictionary *dict = [self.peripherals objectAtIndex:i];
            CBPeripheral *per = dict[@"peripheral"];
            if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                isExist = YES;
                NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
                [self.peripherals replaceObjectAtIndex:i withObject:dict];
            }
        }
        
        if (!isExist) {
            NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
            [self.peripherals addObject:dict];
        }
    }
    
    if (self.peripheralsDidChangeBlock) {
        self.peripheralsDidChangeBlock([NSArray arrayWithArray:self.peripherals]);
    }
}

#pragma mark - custom callbacks

- (void)onPeripheralsDidChange:(void (^)(NSArray *peripherals))block {
    _peripheralsDidChangeBlock = block;
}

#pragma mark - central manager callbacks

- (void)onCentralManagerDidUpdateState:(void (^)(CBCentralManager *central))block {
    _centralManagerDidUpdateStateBlock = block;
}

- (void)onCentralManagerWillRestoreState:(void (^)(CBCentralManager *central, NSDictionary<NSString *, id> *dict))block {
    _centralManagerWillRestoreStateBlock = block;
}

- (void)onCentralManagerDidDiscoverPeripheral:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary<NSString *, id> *advertisementData, NSNumber *RSSI))block {
    _centralManagerDidDiscoverPeripheralBlock = block;
}

- (void)onCentralManagerDidConnectPeripheral:(void (^)(CBCentralManager *central, CBPeripheral *peripheral))block {
    _centralManagerDidConnectPeripheralBlock = block;
}

- (void)onCentralManagerDidFailToConnectPeripheral:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))block {
    _centralManagerDidFailToConnectPeripheralBlock = block;
}

- (void)onCentralManagerDidDisconnectPeripheral:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))block {
    _centralManagerDidDisconnectPeripheralBlock = block;
}

#pragma mark - peripheral manager callbacks

- (void)onPeripheralDidModifyServices:(void (^)(CBPeripheral *peripheral, NSArray<CBService *> *invalidatedServices))block {
}

- (void)onPeripheralDidUpdateRSSI:(void (^)(CBPeripheral *peripheral, NSError *error))block {
}

- (void)onPeripheralDidReadRSSI:(void (^)(CBPeripheral *peripheral, NSNumber *RSSI, NSError *error))block {
}

- (void)onPeripheralDidDiscoverServices:(void (^)(CBPeripheral *peripheral, NSError *error))block {
}

- (void)onPeripheralDidDiscoverIncludedServicesForService:(void (^)(CBPeripheral *peripheral, CBService *service, NSError *error))block {
}

- (void)onPeripheralDidDiscoverCharacteristicsForService:(void (^)(CBPeripheral *peripheral, NSError *error))block {
}

- (void)onPeripheralDidUpdateValueForCharacteristic:(void (^)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error))block {
}

- (void)onPeripheralDidWriteValueForCharacteristic:(void (^)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error))block {
}

- (void)onPeripheralDidUpdateNotificationStateForCharacteristic:(void (^)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error))block {
}

- (void)onPeripheralDidDiscoverDescriptorsForCharacteristic:(void (^)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error))block {
}

- (void)onPeripheralDidUpdateValueForDescriptor:(void (^)(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error))block {
}

- (void)onPeripheralDidWriteValueForDescriptor:(void (^)(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error))block {
}

- (void)onPeripheralIsReadyToSendWriteWithoutResponse:(void (^)(CBPeripheral *peripheral))block {
}

- (void)onPeripheralDidOpenL2CAPChannel:(void (^)(CBPeripheral *peripheral, CBL2CAPChannel *channel, NSError *error))block API_AVAILABLE(ios(11.0)){
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error {
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error {
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

- (void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(nullable CBL2CAPChannel *)channel error:(nullable NSError *)error API_AVAILABLE(ios(11.0)){
    
}

@end
