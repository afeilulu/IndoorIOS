//
//  StadiumManager.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/5.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#ifndef IndoorIOS_StadiumManager_h
#define IndoorIOS_StadiumManager_h

#endif

#import "StadiumRecord.h"

@interface StadiumManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *stadiumList;

- (StadiumRecord *) getStadiumRecordById : (NSString*)idStr;

- (StadiumRecord *) getStadiumRecordByTitle : (NSString*)title;

+ (StadiumManager *)sharedInstance;

- (void) clear;

@end