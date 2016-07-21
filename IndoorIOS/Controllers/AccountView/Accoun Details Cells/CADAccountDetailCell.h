//
//  CADAccountDetailCell.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CADGillSansLabel.h"

@interface CADAccountDetailCell : UITableViewCell

+ (CADAccountDetailCell*) makeCell;

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet CADGillSansLightLabel *name;
@property (weak, nonatomic) IBOutlet UILabel *fee;
@property (weak, nonatomic) IBOutlet UILabel *score;

@end
