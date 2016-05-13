//
//  cad_NSDictionary+SafeValues.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 03/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//


#import "CAD_NSDictionary+SafeValues.h"
#import <UIKit/UIKit.h>

@implementation NSDictionary (CAD_NSDictionary_SafeValues)

- (NSString*)cad_safeStringForKey:(id)key {
    NSString* string = nil;
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]]){
        string = obj;
    }
    else {
        string = @"";
    }
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSNumber*)cad_safeNumberForKey:(id)key {
    NSNumber* number = nil;
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]){
        number = obj;
    }
    else {
        number = [NSNumber numberWithInt:0];
    }
    return number;
}

- (NSArray*)cad_safeArrayForKey:(id)key {
    NSArray* array = nil;
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]){
        array = obj;
    }
    else {
        array = [NSArray array];
    }
    return array;
}

- (NSDictionary*)cad_safeDictionaryForKey:(id)key {
    NSDictionary* dictionary = nil;
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        dictionary = obj;
    }
    else {
        dictionary = [NSDictionary dictionary];
    }
    return dictionary;
}

- (UIImage*)cad_safeImageForKey:(id)key;
{
    UIImage* image = nil;
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[UIImage class]]) {
        image = obj;
    }
    else {
        image = nil;
    }
    return image;
}

@end
