//
//  CADOrderTableCell.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/28.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADOrderTableCell.h"

@implementation CADOrderTableCell

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
    
//    if (self.icon.image == nil)
//        return;
    
//    CGFloat imgHeight = self.frame.size.height - 4;
//    CGRect rect = CGRectMake(0, 0, imgHeight, imgHeight);
//    self.imageView.bounds = rect;
    self.icon.contentMode = UIViewContentModeScaleAspectFill;
    
    self.icon.layer.masksToBounds = true;
    self.icon.layer.cornerRadius = self.icon.frame.size.height / 2;
    self.icon.clipsToBounds = YES;
    
    self.icon.layer.borderWidth = 1;
    self.icon.layer.borderColor = [[UIColor orangeColor] CGColor];
    
}

@end
