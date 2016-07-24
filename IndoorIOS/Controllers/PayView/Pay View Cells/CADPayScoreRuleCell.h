//
//  CADPayScoreRuleCell.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/24.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@interface CADPayScoreRuleCell : UITableViewCell

+ (CADPayScoreRuleCell*) makeCell;

@property (weak, nonatomic) IBOutlet MarqueeLabel *ruleLabel;

@end
