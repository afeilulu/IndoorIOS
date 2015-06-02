//
//  Constants.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/16.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>

// 加密私钥
NSString *const kSecretKey;

// 所有场馆地理位置
extern NSString * const kStadiumsJsonUrl;

// 场馆详情
extern NSString *const kStadiumDetailJsonUrl;

// 获取场地状态
extern NSString *const kSportPlaceStatusJsonUrl;

// Alipay回调
extern NSString *const kAlipayCallbackUrl;

// 时间戳
extern NSString *const kTimeStampUrl;

// 登录
extern NSString *const kLoginUrl;

// 注册
extern NSString *const kRegisterUrl;

// 订单列表
extern NSString *const kOrderListJsonUrl;

// 单日预订最大场次
extern int const kMaxOrderPlace;

// 提交订单
extern NSString *const kSubmitOrderJsonUrl;

// 获取手机验证码
extern NSString *const kValiCodeJsonUrl;

// 获取用户信息
extern NSString *const kGetUserInfoJsonUrl;

// 余额支付
extern NSString *const kFeePayUrl;

// 支付宝支付前验证
extern NSString *const kPreAliPayUrl;

extern int const kSelectableColor;

extern int const kUnSelectableColor;

@interface Constants : NSObject

@end
