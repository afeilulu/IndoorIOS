//
//  CADParseUser.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/27.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADParseUserLogin.h"
#import "CADUser.h"
#import "CADUserManager.h"

@implementation CADParseUserLogin

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
    
    _workingUser = [[CADUser alloc] init];
    
    if ([[result objectForKey:@"success"] boolValue] == true){
        NSDictionary *userInfo = [result objectForKey:@"userInfo"];
        
        _workingUser.fee = [userInfo objectForKey:@"fee"];
        _workingUser.idString = [userInfo objectForKey:@"id"];
        _workingUser.mail = [userInfo objectForKey:@"mail"];
        _workingUser.phone = [userInfo objectForKey:@"phone"];
        _workingUser.sex_code = [userInfo objectForKey:@"sex_code"];
        _workingUser.sex_name = [userInfo objectForKey:@"sec_name"];
        _workingUser.imgUrl = [userInfo objectForKey:@"image_url"];
        _workingUser.address = [userInfo objectForKey:@"address"];
        _workingUser.area_code = [userInfo objectForKey:@"area_code"];
        _workingUser.area_name = [userInfo objectForKey:@"area_name"];
        _workingUser.name = [userInfo objectForKey:@"name"];
        _workingUser.score = [userInfo objectForKey:@"score"];
        _workingUser.qq = [userInfo objectForKey:@"qq"];
    } else {
        NSString *domain = @"com.chinaairdome.indoorios";
        //        NSString *desc = NSLocalizedString(@"Unable to…", @"aaa");
        NSString *desc = [result objectForKey:@"msg"];
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
        error = [NSError errorWithDomain:domain code:-101 userInfo:userInfo];
        
        if (self.errorHandler)
        {
            self.errorHandler(error);
        }
        
    }
    
    if (![self isCancelled])
    {
        _user = _workingUser;
        
        CADUserManager *userManager = [CADUserManager sharedInstance];
        [userManager setUser:_user];
    }
    
    _workingUser = nil;
    self.dataToParse = nil;
}

@end
