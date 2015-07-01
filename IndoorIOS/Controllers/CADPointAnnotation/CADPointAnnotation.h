//
//  CADPointAnnotation.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/16.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//
#import <BaiduMapAPI/BMKPointAnnotation.h>

///表示一个点的annotation
@interface CADPointAnnotation : BMKPointAnnotation

// 改点代表的场馆id
@property (nonatomic, assign) NSString * stadiumId;

@end