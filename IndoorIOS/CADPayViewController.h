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

@interface CADPayViewController : UIViewController;

@property (nonatomic, strong) CADOrderListItem *orderInfo;

@property (weak, nonatomic) IBOutlet UIButton *RemainPayButton;
@property (weak, nonatomic) IBOutlet UIButton *AlipayButton;

- (IBAction)RemainPayAction:(id)sender;
- (IBAction)AlipayAction:(id)sender;

@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSMutableData *jsonData;
@end