//
//  CADSearchResultController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/12.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StadiumRecord.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface CADSearchResultController : UITableViewController<BMKMapViewDelegate>{
    BMKMapView* mapView;
}

@property (nonatomic, strong) NSArray *filteredResults;

@property (nonatomic, strong) NSMutableArray *annotations;

-(void) reloadData;

@end
