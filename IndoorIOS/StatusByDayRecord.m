//
//  StatusByDayRecord.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/1/2.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusByDayRecord.h"

@implementation StatusByDayRecord

-(NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:self.stadiumId,@"stadiumId",self.sportId,@"sportId",self.date,@"date",self.status,@"status",nil];
}

@end