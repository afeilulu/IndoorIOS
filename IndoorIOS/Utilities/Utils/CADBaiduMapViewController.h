//
//  CADBaiduMapViewController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/2/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface CADBaiduMapViewController : UIViewController <BMKMapViewDelegate,BMKLocationServiceDelegate>{
    IBOutlet BMKMapView* _mapView;
    BMKLocationService* _locService;
}

- (void) loadData;

@property (nonatomic, strong) NSMutableDictionary *detailDownloadsInProgress;

@end
