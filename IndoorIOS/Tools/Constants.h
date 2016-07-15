//
//  Constants.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/16.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>

// 加密私钥
extern NSString *const kSecretKey;

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

// 重置密码前获取验证码
extern NSString *const kValiCodeOfResetPasswordJsonUrl;

// 重置密码
extern NSString *const kResetPasswordJsonUrl;

// 修改密码
extern NSString *const KModifyPasswordJsonUrl;

// 获取城市
extern NSString *const KGetCityUrl;

// 获取推荐场馆
extern NSString *const KRecommendStoreUrl;

// 获取推荐教练
extern NSString *const KRecommendTrainerUrl;

// 获取活动列表
extern NSString *const KActivityListUrl;

// 获取图片
extern NSString *const KImageUrl;

// 获取积分规则
extern NSString *const KRuleJFDK;

extern int const kSelectableColor;

extern int const kUnSelectableColor;

@interface Constants : NSObject

@end
