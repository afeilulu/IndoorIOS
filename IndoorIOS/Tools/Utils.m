//
//  Utils.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/10.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"
#import <CommonCrypto/CommonDigest.h>
#import "RegexKitLite.h"

@implementation Utils

+ (NSString *) getWeekName:(NSInteger) week{
    switch (week) {
            
        case 1:
            return @"周日";
            break;
            
        case 2:
            return @"周一";
            break;
        
        case 3:
            return @"周二";
            break;
            
        case 4:
            return @"周三";
            break;
            
        case 5:
            return @"周四";
            break;
            
        case 6:
            return @"周五";
            break;
            
        case 7:
            return @"周六";
            break;
            
        default:
            return @"error";
            break;
    }
}

+ (NSString *)md5:(NSString *) input
{
    const char* cStr = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    static const char HexEncodeChars[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    char *resultData = malloc(CC_MD5_DIGEST_LENGTH * 2 + 1);
    
    for (uint index = 0; index < CC_MD5_DIGEST_LENGTH; index++) {
        resultData[index * 2] = HexEncodeChars[(result[index] >> 4)];
        resultData[index * 2 + 1] = HexEncodeChars[(result[index] % 0x10)];
    }
    resultData[CC_MD5_DIGEST_LENGTH * 2] = 0;
    
    NSString *resultString = [NSString stringWithCString:resultData encoding:NSASCIIStringEncoding];
    free(resultData);
    
    return resultString;
}

+ (bool) textIsValidValue:( NSString*) text
{
    bool result = false;
    
    if ( [text isMatchedByRegex:@"^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$"] ) {
        result = true;
    }
    return result;
}

@end