//
//  CADLoginViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/24.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *UserName;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UIButton *LoginButton;

@property (nonatomic, strong) NSURLConnection *timeStampConnection;
@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSString *sportSiteId;
@property (nonatomic, strong) NSString *sportTypeId;

@property (nonatomic) bool isGoToChoose;

- (IBAction)LoginAction:(id)sender;
@end
