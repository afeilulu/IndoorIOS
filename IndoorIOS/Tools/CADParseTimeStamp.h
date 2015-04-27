//
//  CADParseTimeStamp.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/27.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CADParseTimeStamp : NSOperation

// A block to call when an error is encountered during parsing.
@property (nonatomic, copy) void (^errorHandler)(NSError *error);

@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSString *timeStamp;

// The initializer for this NSOperation subclass.
- (instancetype)initWithData:(NSData *)data;

@end
