//
//  Constants.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/16.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "Constants.h"

NSString *const kSecretKey = @"wmdpzsdl";

NSString *const kStadiumsJsonUrl = @"http://www.paopaoty.com:8082/App-getSportSiteListAjax.action";

NSString *const kStadiumDetailJsonUrl = @"http://www.paopaoty.com:8082/App-getSportSiteDetailAjax.action";
NSString *const kSportPlaceStatusJsonUrl = @"http://www.paopaoty.com:8082/App-getSportPlaceStatusAjax.action";
NSString *const kRegisterUrl = @"http://www.paopaoty.com:8082/App-addCustomerAjax.action";
NSString *const kAlipayCallbackUrl = @"http://www.paopaoty.com:8082/AlipayNotify-sportOrder.action";
NSString *const kTimeStampUrl  = @"http://www.paopaoty.com:8082/App-getCurrentTimeAjax.action";
NSString *const kLoginUrl  = @"http://www.paopaoty.com:8082/App-loginAjax.action";
NSString *const kOrderListJsonUrl = @"http://www.paopaoty.com:8082/App-getOrderListAjax.action";
NSString *const kOrderStatusJsonUrl = @"http://www.paopaoty.com:8082/App-getOrderGroupStateAjax.action";
NSString *const kOrderStatusListJsonUrl = @"http://www.paopaoty.com:8082/App-getOrderGroupListAjax.action";
NSString *const kSubmitOrderJsonUrl = @"http://www.paopaoty.com:8082/App-submitOrderAjax.action";
NSString *const kValiCodeJsonUrl=@"http://www.paopaoty.com:8082/App-getValidateCodeAjax.action";
NSString *const kGetUserInfoJsonUrl = @"http://www.paopaoty.com:8082/App-getUserInfoAjax.action";
NSString *const kFeePayUrl = @"http://www.paopaoty.com:8082/App-feePayAjax.action";
NSString *const kPreAliPayUrl = @"http://www.paopaoty.com:8082/App-aliPayAjax.action";
NSString *const kValiCodeOfResetPasswordJsonUrl = @"http://www.paopaoty.com:8082/App-getValidateCodeForGMAjax.action";
NSString *const kResetPasswordJsonUrl = @"http://www.paopaoty.com:8082/App-resetPasswordAjax.action";
NSString *const KModifyPasswordJsonUrl =@"http://www.paopaoty.com:8082/App-changePasswordAjax.action";

NSString *const KGetCityUrl =@"http://www.paopaoty.com:8082/App-getSportCitiesAjax.action";
NSString *const KRecommendStoreUrl =@"http://www.paopaoty.com:8082/App-recommendStoreAjax.action";
NSString *const KRecommendTrainerUrl =@"http://www.paopaoty.com:8082/App-recommendTrainAjax.action";
NSString *const KActivityListUrl =@"http://www.paopaoty.com:8082/App-activityListAjax.action";

NSString *const KImageUrl =@"http://www.paopaoty.com:8082/Image-getImage.action?imageName=";

NSString *const KRuleJFDK =@"http://www.paopaoty.com:8082/App-ruleJFDKAjax.action";

int const kMaxOrderPlace = 4;

int const kSelectableColor = 242;
int const kUnSelectableColor = 205;

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
