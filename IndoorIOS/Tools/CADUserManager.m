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

+ (CADUserManager *)sharedInstance {
    static CADUserManager *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[CADUserManager alloc] init];
            
            sharedInstance.user = [[CADUser alloc] init];
            sharedInstance.timeStamp = nil;
        }
    }
    return sharedInstance;
}

-(CADUser *)getUser{
    return _user;
}

-(NSString *)getTimeStamp{
    return _timeStamp;
}

-(void)clear{
    _user = nil;
    _timeStamp = nil;
}
@end
