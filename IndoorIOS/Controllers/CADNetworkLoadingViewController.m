//
//  CADNetworkLoadingViewController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/1/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADNetworkLoadingViewController.h"

@interface CADNetworkLoadingViewController ()

@end

@implementation CADNetworkLoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showLoadingView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.activityIndicatorView startAnimating];
}

- (void)showLoadingView
{
    self.errorView.hidden = YES;
    
    self.activityIndicatorView.color = [UIColor colorWithRed:232.0/255.0f green:35.0/255.0f blue:111.0/255.0f alpha:1.0];
}

- (void)showErrorView
{
    self.noContentView.hidden = YES;
    
    self.errorView.hidden = NO;
}

- (void)showNoContentView;
{
    self.noContentView.hidden = NO;
    
    self.errorView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)retryRequest:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(retryRequest)])
        [self.delegate retryRequest];
    
    [self showLoadingView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
