//
//  CADOrderDetailSportTypeCell.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/26.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADOrderDetailSportTypeCell.h"

@implementation CADOrderDetailSportTypeCell

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
    
    if (self.imageView.image == nil)
        return;
    
    CGFloat imgHeight = self.frame.size.height - 4;
    CGRect rect = CGRectMake(0, 0, imgHeight, imgHeight);
    self.imageView.bounds = rect;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.imageView.layer.masksToBounds = true;
    self.imageView.layer.cornerRadius = imgHeight / 2;
    self.imageView.clipsToBounds = YES;
    
    self.imageView.layer.borderWidth = 1;
    self.imageView.layer.borderColor = [[UIColor orangeColor] CGColor];
    
}

@end
