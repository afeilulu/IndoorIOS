//
//  Activity.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject

@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;
@property (nonatomic, strong) NSString *maxNum;
@property (nonatomic, strong) NSString *currentNum;
@property (nonatomic, strong) NSString *initiator;
@property (nonatomic, strong) NSString *contactPhone;
@property (nonatomic, strong) NSString *fee;
@property (nonatomic, strong) NSString *desc;

@end
