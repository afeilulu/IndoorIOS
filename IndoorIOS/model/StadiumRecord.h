//
//  StadiumRecord.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/29.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StadiumRecord : NSObject

@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *lat;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageURLString;

@property (nonatomic, strong) NSString *open_time;
@property (nonatomic, strong) NSString *close_time;

@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *bus_road;
@property (nonatomic, strong) NSString *phone;

@property (nonatomic, strong) NSString *area_code;
@property (nonatomic, strong) NSString *area_name;

@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) NSArray *productTypes;
@property (nonatomic, strong) NSMutableDictionary *imagesOfSportType;

@property (nonatomic, strong) NSArray *pms;

// flag for assure get only once
@property (nonatomic) bool gotDetail;

@end