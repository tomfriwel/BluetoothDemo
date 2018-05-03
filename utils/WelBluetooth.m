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

@interface WelBluetooth()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, copy) CentralManagerDidUpdateStateBlock centralManagerDidUpdateStateBlock;

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

-(instancetype)init {
    self = [super init];
    
    if(self) {
        
    }
    
    return self;
}

#pragma mark - central manager callbacks

- (void)onCentralManagerDidUpdateState:(void (^)(CBCentralManager *central))block {
    _centralManagerDidUpdateStateBlock = block;
}

- (void)onCentralManagerWillRestoreState:(void (^)(CBCentralManager *central, NSDictionary<NSString *, id> *dict))block {
    
}

- (void)onCentralManagerDidDiscoverPeripheral:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary<NSString *, id> *advertisementData, NSNumber *RSSI))block {
    
}

- (void)onCentralManagerDidConnectPeripheral:(void (^)(CBCentralManager *central, CBPeripheral *peripheral))block {
    
}

- (void)onCentralManagerDidFailToConnectPeripheral:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))block {
    
}

- (void)onCentralManagerDidDisconnectPeripheral:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))block {
    
}

#pragma mark - peripheral manager callbacks

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
