//
//  CADUserManager.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/26.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CADUser.h"

@interface CADUserManager : NSObject

+ (CADUserManager *)sharedInstance;

@property (nonatomic, strong) CADUser *user;
@property (nonatomic, strong) NSString *timeStamp;

- (NSString *)getTimeStamp;
- (CADUser *)getUser;
- (void) clear;

@end
