//
//  CADPayViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/15.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#ifndef IndoorIOS_CADPayViewController_h
#define IndoorIOS_CADPayViewController_h


#endif

#import <UIKit/UIKit.h>
#import "CADOrderListItem.h"
#import "AFNetworking.h"
#import "MarqueeLabel.h"

@interface CADPayViewController : UIViewController;

@property (nonatomic, strong) CADOrderListItem *orderInfo;

@property (weak, nonatomic) IBOutlet UIButton *RemainPayButton;
@property (weak, nonatomic) IBOutlet UIButton *AlipayButton;

- (IBAction)RemainPayAction:(id)sender;
- (IBAction)AlipayAction:(id)sender;

@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (weak, nonatomic) IBOutlet UIImageView *sportImageView;
@property (weak, nonatomic) IBOutlet UIView *orderContainer;
@property (weak, nonatomic) IBOutlet UILabel *OrderSeqLabel;
@property (weak, nonatomic) IBOutlet UILabel *SiteNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *place4Label;
@property (weak, nonatomic) IBOutlet UILabel *place3Label;
@property (weak, nonatomic) IBOutlet UILabel *place2Label;
@property (weak, nonatomic) IBOutlet UILabel *place1Label;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *place4HeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *place3HeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *place2HeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderContainerHeightConstraint;

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@property (weak, nonatomic) IBOutlet MarqueeLabel *ruleTips;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UITextField *useScoreText;

- (IBAction)switchAction:(id)sender;

@end