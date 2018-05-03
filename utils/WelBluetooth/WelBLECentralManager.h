//
//  WelBLECentralManager.h
//  BluetoothDemo
//
//  Created by tomfriwel on 2018/5/3.
//  Copyright © 2018 tomfriwel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface WelBLECentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@end
