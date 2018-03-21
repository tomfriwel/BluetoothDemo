//
//  BLDeviceInfoCell.m
//  BluetoothDemo
//
//  Created by tomfriwel on 20/03/2018.
//  Copyright © 2018 tomfriwel. All rights reserved.
//

#import "BLDeviceInfoCell.h"

@implementation BLDeviceInfoCell

-(instancetype)init{
    self = [super init];
    
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
    }
    
    return self;
}

+(CGFloat)cellHeight {
    return 100.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
