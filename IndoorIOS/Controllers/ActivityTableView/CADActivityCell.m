//
//  CADActivityCell.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/19.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADActivityCell.h"

@implementation CADActivityCell

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
    
//    self.imageView.frame = CGRectMake(12,0,80,72);
    CGRect rect = CGRectMake(0, 0, 88, 66);
    self.imageView.bounds = rect;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.imageView.layer.masksToBounds = true;
    self.imageView.layer.cornerRadius = 3.0;
    self.imageView.clipsToBounds = YES;
    
    CGRect tmpFrame = self.textLabel.frame;
//    tmpFrame.origin.x = 106;
    tmpFrame.origin.y = 8;
    self.textLabel.frame = tmpFrame;
    
//    tmpFrame = self.detailTextLabel.frame;
//    tmpFrame.origin.x = 106;
//    self.detailTextLabel.frame = tmpFrame;
    
}

@end