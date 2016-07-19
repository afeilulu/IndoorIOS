//
//  CADCoachCell.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/19.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADCoachCell.h"

@implementation CADCoachCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = CGRectMake(2, 2, 66, 66);
    self.imageView.bounds = rect;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;

    self.imageView.layer.masksToBounds = true;
    self.imageView.layer.cornerRadius = 33;
    
//    self.imageView.layer.borderWidth = 1.0f;
//    self.imageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.imageView.clipsToBounds = YES;
    
    CGRect tmpFrame = self.textLabel.frame;
    tmpFrame.origin.y = 8;
    self.textLabel.frame = tmpFrame;
}

@end
