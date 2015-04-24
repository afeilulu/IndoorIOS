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
            sharedInstance.sportDayRuleList = [[NSMutableArray alloc] init];
        }
    }
    return sharedInstance;
}

- (StadiumRecord *) getStadiumRecordById : (NSString*)idStr{
    return [_stadiumList objectForKey:idStr];
}

- (void) clearStadium{
    if (_stadiumList){
        [_stadiumList removeAllObjects];
    }
}

- (void) clearSportDayRule{
    if (_sportDayRuleList){
        [_sportDayRuleList removeAllObjects];
    }
}
@end
