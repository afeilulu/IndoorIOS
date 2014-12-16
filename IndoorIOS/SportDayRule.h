//
//  SportDayRule.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#ifndef IndoorIOS_SportDayRule_h
#define IndoorIOS_SportDayRule_h


#endif

@interface SportDayRule : NSObject

@property (nonatomic, strong) NSString *stadiumId;// 场馆id
@property (nonatomic, strong) NSString *name;// 运动名称
@property (nonatomic, strong) NSNumber *maxCount; // 该运动最大场地数
@property (nonatomic, strong) NSString *minOrderUnit;//最小单位
@property (nonatomic, strong) NSString *ruleJson;

@end