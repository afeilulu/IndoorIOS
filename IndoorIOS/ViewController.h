//
//  ViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/20.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI/BMapKit.h>

@interface ViewController : UIViewController <BMKMapViewDelegate,BMKLocationServiceDelegate>{
    IBOutlet BMKMapView* _mapView;
    BMKLocationService* _locService;
}

- (void) loadData;

@property (nonatomic, strong) NSMutableDictionary *detailDownloadsInProgress;

@end

