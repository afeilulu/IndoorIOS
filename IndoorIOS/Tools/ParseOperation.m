//
//  ParseOperation.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/29.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseOperation.h"
#import "StadiumRecord.h"
#import "StadiumManager.h"

// string contants found in the RSS feed
static NSString *kIDStr     = @"id";
static NSString *kNameStr   = @"name";
static NSString *kPicUrlStr  = @"imgUrl";
static NSString *kLngStr  = @"lng";
static NSString *kLatStr  = @"lat";

@interface ParseOperation ()

// Redeclare appRecordList so we can modify it within this class
//@property (nonatomic, strong) NSArray *stadiumRecordList;

@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) StadiumRecord *workingEntry;

@end

@implementation ParseOperation

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
    
    //    NSArray *stadiums = [NSJSONSerialization
    //                         JSONObjectWithData:_dataToParse
    //                         options:kNilOptions
    //                         error:&error];
    
    NSDictionary *stadiumSites = [NSJSONSerialization
                                  JSONObjectWithData:_dataToParse
                                  options:kNilOptions
                                  error:&error];
    
    if ([stadiumSites objectForKey:@"success"]) {
        
        NSArray *stadiums = [stadiumSites objectForKey:@"list"];
        
        // get singleton
        StadiumManager *stadiumManager = [StadiumManager sharedInstance];
        
        // clear data first
        [stadiumManager clearStadium];
        
        for (id item in stadiums) {
            self.workingEntry = [[StadiumRecord alloc] init];
            self.workingEntry.idString = [NSString stringWithFormat:@"%@",[item objectForKey:kIDStr]];
            self.workingEntry.name = [item objectForKey:kNameStr];
            self.workingEntry.lat = [item objectForKey:kLatStr];
            self.workingEntry.lng = [item objectForKey:kLngStr];
//            self.workingEntry.imageURLString = [item objectForKey:kPicUrlStr];
            self.workingEntry.imageURLString = @"http://sn.cnr.cn/shouyetupian/201304/W020130412371064650712.jpg";
            
            [stadiumManager.stadiumList setObject:self.workingEntry forKey:self.workingEntry.idString];
        }
        
    }
    
    if (![self isCancelled])
    {
        NSLog(@"parseOperation is cancelled");
    }
    
    self.dataToParse = nil;
}
@end