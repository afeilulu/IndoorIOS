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
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic) bool gotDetail;

@end