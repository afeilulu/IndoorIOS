//
//  CADRecmSiteCell.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/18.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADRecmSiteCell.h"
#import <UIImageView+WebCache.h>

@implementation CADRecmSiteCell

//-(void)updateUIWithSite:(StadiumRecord *)site{
//    if ([site.imageURLString length] > 0) {
//        [self.siteImageView sd_setImageWithURL:[NSURL URLWithString:site.imageURLString]];
//    }
//    self.siteTitleLabel.text = site.name;
//}


- (void)updateUI:(NSString *)title imageUrl:(NSString*)urlString type:(NSInteger)value{
    
    self.layer.masksToBounds = true;
    self.layer.cornerRadius = 3.0;
    
    if (value == 1) {
        [self.siteImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"defaultTrainerImage"]];
    } else {
        [self.siteImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"defaultSiteImage"]];
    }
    self.siteTitleLabel.text = title;
}
@end
