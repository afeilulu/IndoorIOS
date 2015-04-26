//
//  CADRegisterViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/24.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADRegisterViewController.h"

@interface CADRegisterViewController ()

@end

@implementation CADRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)RegisterAction:(id)sender {
    // TODO:register action
    UIAlertView * alertView = [[UIAlertView alloc] init];
    alertView.title = @"Sign in Failed!";
    alertView.message = @"Please enter Username and Password";
    alertView.delegate = self;
    [alertView addButtonWithTitle:@"OK"];
    [alertView show];

}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"TextField Should Return Method Called!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [textField resignFirstResponder];
    return YES;
}

@end
