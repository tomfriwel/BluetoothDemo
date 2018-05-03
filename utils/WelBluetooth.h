//
//  WelBluetooth.h
//  BluetoothDemo
//
//  Created by tomfriwel on 2018/5/3.
//  Copyright © 2018 tomfriwel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface WelBluetooth : NSObject

+(WelBluetooth *)shared;

- (void)onCentralManagerDidUpdateState:(void (^)(CBCentralManager *central))block;

@property (nonatomic, strong) NSMutableArray <CBPeripheral *>*peripherals;

- (void)onPeripheralsDidChange:(void (^)(NSArray *peripherals))block;

@end
