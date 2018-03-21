//
//  BLDeviceInfoCell.h
//  BluetoothDemo
//
//  Created by tomfriwel on 20/03/2018.
//  Copyright © 2018 tomfriwel. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *BLDeviceInfoCellIdentifier = @"BLDeviceInfoCell";

@interface BLDeviceInfoCell : UITableViewCell

+(CGFloat)cellHeight;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *RSSILabel;

@end
