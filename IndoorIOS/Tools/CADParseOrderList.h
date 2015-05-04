//
//  CADParseOrderList.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/30.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CADOrderListItem.h"

@interface CADParseOrderList : NSOperation

// A block to call when an error is encountered during parsing.
@property (nonatomic, copy) void (^errorHandler)(NSError *error);

//@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong, readonly) NSMutableArray *orderList;

@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;
@property (nonatomic, strong) CADOrderListItem *workingEntry;

// The initializer for this NSOperation subclass.
- (instancetype)initWithData:(NSData *)data;

@end
