//
//  StadiumRecord.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/29.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import "StadiumRecord.h"

@implementation StadiumRecord

-(NSString *)description{
    return [_idString stringByAppendingString: _name];
}

@end

