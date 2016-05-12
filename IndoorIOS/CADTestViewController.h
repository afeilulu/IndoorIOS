//
//  CADTestViewController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/1/22.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CADNetworkLoadingViewController.h"

@interface CADTestViewController : UIViewController <CADNetworkLoadingViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *networkLoadingContainerView;

@end
