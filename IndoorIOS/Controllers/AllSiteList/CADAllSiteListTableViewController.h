//
//  CADAllSiteListTableViewController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/22.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StadiumRecord.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "Utils.h"

@interface CADAllSiteListTableViewController : UITableViewController<BMKMapViewDelegate>{
    BMKMapView* mapView;
}

@property (nonatomic, strong) NSMutableArray *allSites;

@property (nonatomic, strong) NSMutableArray *annotations;

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;


@end
