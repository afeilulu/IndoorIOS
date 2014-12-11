//
//  SportDayRule.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportDayRule.h"

@implementation SportDayRule

-(NSString *)description{
    return [_idString stringByAppendingString: [_minOrderUnit stringByAppendingString:_ruleJson ]];
}

@end