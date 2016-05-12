//
//  CADTestViewController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/1/22.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADTestViewController.h"

@interface CADTestViewController ()

@property (nonatomic, strong) CADNetworkLoadingViewController *networkLoadingViewController;

@end

@implementation CADTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Container Segue Methods

- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([CADNetworkLoadingViewController class])])
    {
        self.networkLoadingViewController = segue.destinationViewController;
        self.networkLoadingViewController.delegate = self;
    }
}

#pragma mark -
#pragma mark KMNetworkLoadingViewDelegate

-(void)retryRequest;
{
    // TODO
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
