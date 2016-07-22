//
//  CADCoachDetailCell.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/22.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CADGillSansLabel.h"

@interface CADCoachDetailCell : UITableViewCell

+ (CADCoachDetailCell*) makeCell;


@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet CADGillSansLightLabel *name;

@end
