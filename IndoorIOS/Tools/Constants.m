//
//  Constants.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/16.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "Constants.h"

#ifdef DEBUG
#define BASE_URL @"http://www.paopaoty.com:8082"
#else
#define BASE_URL @"http://www.paopaoty.com"
#endif

NSString *const kSecretKey = @"wmdpzsdl";

NSString *const kStadiumsJsonUrl = (BASE_URL @"/App-getSportSiteListAjax.action");
NSString *const kStadiumDetailJsonUrl = (BASE_URL @"/App-getSportSiteDetailAjax.action");
NSString *const kSportPlaceStatusJsonUrl = (BASE_URL @"/App-getSportPlaceStatusAjax.action");
NSString *const kRegisterUrl = (BASE_URL @"/App-addCustomerAjax.action");
NSString *const kAlipayCallbackUrl = (BASE_URL @"/PayAlipay-orderNotify.action");
NSString *const kTimeStampUrl  = (BASE_URL @"/App-getCurrentTimeAjax.action");
NSString *const kLoginUrl  = (BASE_URL @"/App-loginAjax.action");
NSString *const kOrderListJsonUrl = (BASE_URL @"/App-getOrderListAjax.action");
NSString *const kOrderInfoJsonUrl = (BASE_URL @"/App-getOrderInfoAjax.action");
NSString *const kOrderStatusJsonUrl = (BASE_URL @"/App-getOrderGroupStateAjax.action");
NSString *const kOrderStatusListJsonUrl = (BASE_URL @"/App-getOrderGroupListAjax.action");
NSString *const kSubmitOrderJsonUrl = (BASE_URL @"/App-submitOrderAjax.action");
NSString *const kValiCodeJsonUrl= (BASE_URL @"/App-getValidateCodeAjax.action");
NSString *const kGetUserInfoJsonUrl = (BASE_URL @"/App-getUserInfoAjax.action");
NSString *const kFeePayUrl = (BASE_URL @"/App-feePayAjax.action");
NSString *const kPreAliPayUrl = (BASE_URL @"/App-aliPayAjax.action");
NSString *const kValiCodeOfResetPasswordJsonUrl = (BASE_URL @"/App-getValidateCodeForGMAjax.action");
NSString *const kResetPasswordJsonUrl = (BASE_URL @"/App-resetPasswordAjax.action");
NSString *const KModifyPasswordJsonUrl = (BASE_URL @"/App-changePasswordAjax.action");

NSString *const KGetCityUrl = (BASE_URL @"/App-getSportCitiesAjax.action");
NSString *const KRecommendStoreUrl = (BASE_URL @"/App-recommendStoreAjax.action");
NSString *const KRecommendTrainerUrl = (BASE_URL @"/App-recommendTrainAjax.action");
NSString *const KActivityListUrl = (BASE_URL @"/App-activityListAjax.action");
NSString *const KImageUrl = (BASE_URL @"/Image-getImage.action?imageName=");
NSString *const KRuleJFDK = (BASE_URL @"/App-ruleJFDKAjax.action");

NSString *const kWXPayUrl = (BASE_URL @"/App-orderWxPayAjax.action");

NSString *const kWXMchKey = @"Wos0Zq8Er3VvI3s1pCfTtDmtPfTk0M3U";

@implementation Constants

+(NSDictionary*)getOrderStatusDictionary {
    static NSDictionary *iconNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iconNames = @{@"0":@"未付费",
                      @"1":@"支付中",
                      @"2":@"用户取消",
                      @"3":@"已付费",
                      @"4":@"支付失败",
                      @"5":@"等待确认",
                      @"6":@"确认通过",
                      @"7":@"确认拒绝",
                      @"8":@"超时",
                      @"9":@"退订中",
                      @"10":@"退订成功",
                      @"11":@"退订失败"
                      };
        
    });
    return iconNames;
}

@end
