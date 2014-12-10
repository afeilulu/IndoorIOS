//
//  Utils.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/10.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

@implementation Utils

+ (NSString *) getWeekName:(int) week{
    switch (week) {
            
        case 1:
            return @"周日";
            break;
            
        case 2:
            return @"周一";
            break;
        
        case 3:
            return @"周二";
            break;
            
        case 4:
            return @"周三";
            break;
            
        case 5:
            return @"周四";
            break;
            
        case 6:
            return @"周五";
            break;
            
        case 7:
            return @"周六";
            break;
            
        default:
            return @"error";
            break;
    }
}

@end