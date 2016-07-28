//
//  CADResetPasswordController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/27.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface CADResetPasswordController : UIViewController

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *Valicode;

@property (weak, nonatomic) IBOutlet UIButton *getValicodeButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

- (IBAction)getValicodeAction:(id)sender;
- (IBAction)okAction:(id)sender;

@property (nonatomic, strong) NSString *inputValicode;

@end
