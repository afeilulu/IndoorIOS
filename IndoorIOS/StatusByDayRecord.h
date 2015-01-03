//
//  StatusByDayRecord.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/1/2.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#ifndef IndoorIOS_StatusByDayRecord_h
#define IndoorIOS_StatusByDayRecord_h


#endif

@interface StatusByDayRecord : NSObject

@property (nonatomic, strong) NSString *sportId;
@property (nonatomic, strong) NSString *stadiumId;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *status;

-(NSDictionary *)dictionary;

@end