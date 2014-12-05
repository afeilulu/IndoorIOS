//
//  ParseOperation.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/29.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#ifndef IndoorIOS_ParseOperation_h
#define IndoorIOS_ParseOperation_h


#endif


@interface ParseOperation : NSOperation

// A block to call when an error is encountered during parsing.
@property (nonatomic, copy) void (^errorHandler)(NSError *error);

// NSArray containing AppRecord instances for each entry parsed
// from the input data.
// Only meaningful after the operation has completed.
//@property (nonatomic, strong, readonly) NSArray *stadiumRecordList;

// The initializer for this NSOperation subclass.
- (instancetype)initWithData:(NSData *)data;

@end