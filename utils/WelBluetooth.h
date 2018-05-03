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

@end
