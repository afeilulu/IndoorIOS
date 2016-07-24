//
//  CADPayScoreRuleCell.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/24.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADPayScoreRuleCell.h"

@implementation CADPayScoreRuleCell

#pragma mark Init Methods

+ (CADPayScoreRuleCell*) makeCell
{
    CADPayScoreRuleCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CADPayScoreRuleCell" owner:self options:nil] objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
    }
    return self;
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
