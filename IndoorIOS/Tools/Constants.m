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
NSString *const kSubmitOrderJsonUrl = @"http://www.paopaoty.com:8082/App-submitOrderAjax.action";
NSString *const kValiCodeJsonUrl=@"http://www.paopaoty.com:8082/App-getValidateCodeAjax.action";
NSString *const kGetUserInfoJsonUrl = @"http://www.paopaoty.com:8082/App-getUserInfoAjax.action";
NSString *const kFeePayUrl = @"http://www.paopaoty.com:8082/App-feePayAjax.action";
NSString *const kPreAliPayUrl = @"http://www.paopaoty.com:8082/App-aliPayAjax.action";
NSString *const kValiCodeOfResetPasswordJsonUrl = @"http://www.paopaoty.com/App-getValidateCodeForGMAjax.action";
NSString *const kResetPasswordJsonUrl = @"http://www.paopaoty.com/App-resetPasswordAjax.action";
NSString *const KModifyPasswordJsonUrl =@"http://www.paopaoty.com/App-changePasswordAjax.action";

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

@end
