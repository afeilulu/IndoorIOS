//
//  ParseSportDayRule.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

@interface ParseSportDayRule : NSOperation

// A block to call when an error is encountered during parsing.
@property (nonatomic, copy) void (^errorHandler)(NSError *error);

// The initializer for this NSOperation subclass.
- (instancetype)initWithData:(NSData *)data;

@end