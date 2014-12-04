//
//  ViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/20.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"

@interface ViewController : UIViewController <BMKMapViewDelegate,BMKLocationServiceDelegate>{
    IBOutlet BMKMapView* _mapView;
    BMKLocationService* _locService;
}

@property (nonatomic, strong) NSArray *entries;
- (void) loadData;

@end

