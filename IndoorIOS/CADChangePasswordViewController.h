//
//  CADChangePasswordViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/7/10.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADChangePasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *freshPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *okButton;


@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic,strong) NSURLConnection *jsonConnection;
@end
