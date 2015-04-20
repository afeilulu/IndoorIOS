//
//  ParseStadiumDetail.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseStadiumDetail.h"
#import "StadiumManager.h"
#import "SportDayRule.h"

// string contants found in the RSS feed
static NSString *kStadiumIDStr     = @"stadiumId";
static NSString *kSportIDStr     = @"sportId";
static NSString *kUnitStr   = @"minOrderUnit";
static NSString *kNameStr   = @"name";
static NSString *kRuleJsonStr   = @"ruleJson";
static NSString *kMaxCountInt   = @"maxCount";

@interface ParseStadiumDetail ()

@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) SportDayRule *workingEntry;

@end

@implementation ParseStadiumDetail

// -------------------------------------------------------------------------------
//	initWithData:
// -------------------------------------------------------------------------------
- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        _dataToParse = data;
    }
    return self;
}

// -------------------------------------------------------------------------------
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
    
    
    if ([result objectForKey:@"success"]){
        
        NSDictionary *sportSiteInfo = [result objectForKey:@"sportSiteInfo"];
        NSString *id = [sportSiteInfo objectForKey:@"id"];
        
        // get singleton
        StadiumManager *stadiumManager = [StadiumManager sharedInstance];
        StadiumRecord *stadium = [stadiumManager.stadiumList objectForKey:id];
        
        [stadium setGotDetail:TRUE];
        [stadium setAddress:[sportSiteInfo objectForKey:@"address"]];
        // TODO : set more properties
        
    }
    
    if (![self isCancelled])
    {
        NSLog(@"parseOperation completed");
    }
    
    self.dataToParse = nil;
}
@end