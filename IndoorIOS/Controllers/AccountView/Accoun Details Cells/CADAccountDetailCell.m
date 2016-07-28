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
    
    self.statusContainer1.layer.cornerRadius = 3.0f;
    self.statusContainer1.layer.borderWidth = 1.0f;
    self.statusContainer1.layer.borderColor = [[self.name textColor] CGColor];
    self.statusContainer1.backgroundColor = [UIColor clearColor];
    
    self.statusContainer2.layer.cornerRadius = 3.0f;
    self.statusContainer2.layer.borderWidth = 1.0f;
    self.statusContainer2.layer.borderColor = [[self.name textColor] CGColor];
    self.statusContainer2.backgroundColor = [UIColor clearColor];
    
    self.statusContainer3.layer.cornerRadius = 3.0f;
    self.statusContainer3.layer.borderWidth = 1.0f;
    self.statusContainer3.layer.borderColor = [[self.name textColor] CGColor];
    self.statusContainer3.backgroundColor = [UIColor clearColor];
    
    self.statusContainer4.layer.cornerRadius = 3.0f;
    self.statusContainer4.layer.borderWidth = 1.0f;
    self.statusContainer4.layer.borderColor = [[self.name textColor] CGColor];
    self.statusContainer4.backgroundColor = [UIColor clearColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)statusContainer1Action:(id)sender {
    if ([self.status1value.text floatValue] > 0){
        NSLog(@"%@ - %@", NSStringFromClass([self class]), @"111");
    }
}
- (IBAction)statusContainer2Action:(id)sender {
    if ([self.status2value.text floatValue] > 0){
        NSLog(@"%@ - %@", NSStringFromClass([self class]), @"222");
    }
}
- (IBAction)statusContainer3Action:(id)sender {
    if ([self.status3value.text floatValue] > 0){
        NSLog(@"%@ - %@", NSStringFromClass([self class]), @"333");
    }
}
- (IBAction)statusContainer4Action:(id)sender {
    if ([self.status4value.text floatValue] > 0){
        NSLog(@"%@ - %@", NSStringFromClass([self class]), @"444");
    }
}

@end
