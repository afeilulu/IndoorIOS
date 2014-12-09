//
//  StadiumManager.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/5.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StadiumManager.h"
#import "StadiumRecord.h"

@implementation StadiumManager

+ (StadiumManager *)sharedInstance {
    static StadiumManager *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[StadiumManager alloc] init];
            sharedInstance.stadiumList = [NSMutableDictionary dictionary];
        }
    }
    return sharedInstance;
}

- (StadiumRecord *) getStadiumRecordById : (NSString*)idStr{
    return [_stadiumList objectForKey:idStr];
}

- (StadiumRecord *) getStadiumRecordByTitle : (NSString*)title{
    
    for (NSString *key in _stadiumList) {
        StadiumRecord *stadium = [_stadiumList objectForKey:key];
        if ([stadium.name isEqualToString:title]){
            return stadium;
        }
    }

    return nil;
}

- (void) clear{
    if (_stadiumList){
        [_stadiumList removeAllObjects];
    }
}

@end
