//
//  CADPayTableViewController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/23.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CADOrderListItem.h"
#import "AFNetworking.h"

@interface CADPayTableViewController : UITableViewController

@property (nonatomic, strong) CADOrderListItem *orderInfo;
@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@property (nonatomic) CGFloat originalTotalMoney;
@property (nonatomic) CGFloat maxScoreCanBeUse;
@property (nonatomic) CGFloat usedScore;

@property (nonatomic, retain) UIAlertController *alertController;

@property (nonatomic, retain) UIAlertController *scoreAlertController;

@end
