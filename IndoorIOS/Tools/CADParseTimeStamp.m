//
//  CADParseTimeStamp.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/27.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADParseTimeStamp.h"
#import "CADUserManager.h"

@implementation CADParseTimeStamp

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
    
    
    if (![self isCancelled])
    {
        if ([result objectForKey:@"success"]){
            _timeStamp = [result objectForKey:@"randTime"];
            
            CADUserManager *userManager = [CADUserManager sharedInstance];
            [userManager setTimeStamp:_timeStamp];
        }
    }
    
    self.dataToParse = nil;
}

@end
