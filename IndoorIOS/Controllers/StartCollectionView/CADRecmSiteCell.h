//
//  CADRecmSiteCell.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/18.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StadiumRecord.h"

@interface CADRecmSiteCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *siteImageView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;
@property (weak, nonatomic) IBOutlet UILabel *siteTitleLabel;

- (void)updateUI:(NSString *)title imageUrl:(NSString*)urlString type:(NSInteger)value;

@end
