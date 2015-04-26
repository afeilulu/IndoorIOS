//
//  CADUserManager.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/26.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADUserManager.h"
#import "CADUser.h"

@implementation CADUserManager

+ (CADUser *)sharedInstance {
    static CADUser *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[CADUser alloc] init];
        }
    }
    return sharedInstance;
}

@end
