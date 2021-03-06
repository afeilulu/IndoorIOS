//
//  CADOrderListItem.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/30.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CADOrderListItem : NSObject

@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *orderTitle;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *orderSeq;
@property (nonatomic) int remainTime;
@property (nonatomic, strong) NSArray *siteTimeList;
@property (nonatomic, strong) NSString *orderStatus;
@property (nonatomic, strong) NSString *zflx;
@property (nonatomic, strong) NSString *totalMoney;
@property (nonatomic, strong) NSString *fpPrintYn;
@property (nonatomic, strong) NSString *sportId; // 场馆id
@property (nonatomic, strong) NSString *sportTypeId; // 运动id
@property (nonatomic, strong) NSString *sportTypeName; // 运动名称
@property (nonatomic, strong) NSString *sportTypeSmallImage;// 运动小图片地址

@end
