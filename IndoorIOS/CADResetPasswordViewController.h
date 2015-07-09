//
//  CADResetPasswordViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/7/9.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADResetPasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *Valicode;

@property (weak, nonatomic) IBOutlet UIButton *getValicodeButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSMutableData *jsonData;

@property (nonatomic, strong) NSString *inputValicode;
@end
