//
//  CADAccountDetailCell.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADAccountDetailCell.h"

@implementation CADAccountDetailCell

#pragma mark -
#pragma mark Init Methods

+ (CADAccountDetailCell*) makeCell
{
    CADAccountDetailCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CADAccountDetailCell" owner:self options:nil] objectAtIndex:0];
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
    self.icon.layer.cornerRadius = self.icon.frame.size.width/2;
    self.icon.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
