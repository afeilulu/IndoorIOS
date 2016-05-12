//
//  CADNetworkLoadingViewController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/1/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADActivityIndicator.h"
#import <UIKit/UIKit.h>

@protocol CADNetworkLoadingViewDelegate <NSObject>

-(void)retryRequest;

@end


@interface CADNetworkLoadingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet CADActivityIndicator *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *noContentView;

@property (weak, nonatomic) id <CADNetworkLoadingViewDelegate> delegate;

- (IBAction)retryRequest:(id)sender;

- (void)showLoadingView;
- (void)showNoContentView;
- (void)showErrorView;

@end
