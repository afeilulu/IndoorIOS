//
//  CADAccountViewController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/16.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "CADUser.h"

@interface CADAccountViewController : UITableViewController{
    NSInteger sectionNumber;
}

@property (strong,nonatomic) CADUser *user;

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@end
