//
//  CADOrderTableViewCell.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/5/4.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADOrderTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *siteLabel;
@property (nonatomic, weak) IBOutlet UIImageView *sportImageView;
@property (nonatomic, weak) IBOutlet UILabel *createTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *moneyLabel;

@end
