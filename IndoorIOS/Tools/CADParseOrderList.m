//
//  CADParseOrderList.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/30.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADParseOrderList.h"

@implementation CADParseOrderList

// initWithData
- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        _dataToParse = data;
    }
    return self;
}

//	main
//  Entry point for the operation.
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{
    // The default implemetation of the -start method sets up an autorelease pool
    // just before invoking -main however it does NOT setup an excption handler
    // before invoking -main.  If an exception is thrown here, the app will be
    // terminated.
    
    NSError* error;
    NSDictionary *result = [NSJSONSerialization
                            JSONObjectWithData:_dataToParse
                            options:kNilOptions
                            error:&error];
    
    _workingArray = [NSMutableArray array];
    
    if ([[result objectForKey:@"success"] boolValue] == true){
        NSArray *listArray = [result objectForKey:@"list"];
        
        for (int i=0; i < listArray.count; i++) {
            NSDictionary *item = (NSDictionary *)[listArray objectAtIndex:i];
            CADOrderListItem *orderItem = [[CADOrderListItem alloc] init];
            [orderItem setCreateTime:[item objectForKey:@"createTime"]];
            [orderItem setFpPrintYn:[item objectForKey:@"fpPrintYn"]];
            [orderItem setOrderId:[item objectForKey:@"orderId"]];
            [orderItem setOrderSeq:[item objectForKey:@"orderSeq"]];
            [orderItem setOrderStatus:[item objectForKey:@"orderStatus"]];
            [orderItem setOrderTitle:[item objectForKey:@"orderTitle"]];
            [orderItem setRemainTime:[[item objectForKey:@"remainTime"] intValue]];
            [orderItem setSiteTimeList:[item objectForKey:@"siteTimeList"]];
            [orderItem setTotalMoney:[item objectForKey:@"totalMoney"]];
            [orderItem setZflx:[item objectForKey:@"zflx"]];
            [orderItem setSportId:[item objectForKey:@"sportId"]];
            [orderItem setSportTypeId:[item objectForKey:@"sportTypeId"]];
            
            [_workingArray addObject:orderItem];
        }
        
        if (_workingArray.count == 0) {
            [_workingArray addObject:@"您还没有任何预订"];
        }
    } else {
        NSString *domain = @"com.chinaairdome.indoorios";
        //        NSString *desc = NSLocalizedString(@"Unable to…", @"aaa");
        NSString *desc = [result objectForKey:@"msg"];
        if (!desc) {
            desc=@"抱歉，服务器无响应，请稍候再试。";
        }
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
        error = [NSError errorWithDomain:domain code:-101 userInfo:userInfo];
        
        if (self.errorHandler)
        {
            self.errorHandler(error);
        }
        
    }
    
    if (![self isCancelled])
    {
        _orderList = [NSMutableArray arrayWithArray:_workingArray];
    }
    
    _workingArray = nil;
    _dataToParse = nil;
}

@end
