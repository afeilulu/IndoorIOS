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

// string contants found in the RSS feed
static NSString *kIDStr     = @"id";
static NSString *kNameStr   = @"name";
static NSString *kCityStr   = @"city";
static NSString *kAddressStr   = @"address";
static NSString *kPicUrlStr  = @"picUrl";
static NSString *kPhoneStr = @"phone";
static NSString *kLngStr  = @"lng";
static NSString *kLatStr  = @"lat";

@interface ParseOperation ()

// Redeclare appRecordList so we can modify it within this class
@property (nonatomic, strong) NSArray *stadiumRecordList;

@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;
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
    
    _workingArray = [NSMutableArray array];
    NSError* error;

    NSArray *stadiums = [NSJSONSerialization
                         JSONObjectWithData:_dataToParse
                         options:kNilOptions
                         error:&error];
    
    for (id item in stadiums) {
        self.workingEntry = [[StadiumRecord alloc] init];
        self.workingEntry.idString = [NSString stringWithFormat:@"%@",[item objectForKey:kIDStr]];
        self.workingEntry.name = [item objectForKey:kNameStr];
        self.workingEntry.address = [item objectForKey:kAddressStr];
        // TODO
        NSLog(@"stadium: %@", self.workingEntry);
        
        [self.workingArray addObject:self.workingEntry];
    }
    
    if (![self isCancelled])
    {
        // Set appRecordList to the result of our parsing
        self.stadiumRecordList = [NSArray arrayWithArray:self.workingArray];
    }
    
    self.workingArray = nil;
    self.dataToParse = nil;
}
@end