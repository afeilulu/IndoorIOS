//
//  CADActivityCell.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/19.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADActivityCell.h"
#import "Constants.h"

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
    
    CGFloat imgHeight = self.frame.size.height - 4;
//    self.imageView.frame = CGRectMake(12,8,width + 16,width * gRatio);
    CGRect rect = CGRectMake(0, 0, imgHeight /gRatio, imgHeight);
    self.imageView.bounds = rect;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.imageView.layer.masksToBounds = true;
    self.imageView.layer.cornerRadius = 3.0;
    self.imageView.clipsToBounds = YES;
    
    // 改变位置
    CGRect tmpFrame = self.textLabel.frame;
//    tmpFrame.origin.x = tmpFrame.origin.x - 2 * adj;
    tmpFrame.origin.y = 8;
    self.textLabel.frame = tmpFrame;

//    tmpFrame = self.detailTextLabel.frame;
//    tmpFrame.origin.x = tmpFrame.origin.x - 2 * adj;
//    self.detailTextLabel.frame = tmpFrame;

}

@end
