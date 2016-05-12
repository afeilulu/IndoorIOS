//
//  CADIndexViewController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/2/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface CADIndexViewController  : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate>{
    BMKMapView* mapView;
    BMKLocationService* _locService;
}

@property (nonatomic, strong) NSMutableDictionary *detailDownloadsInProgress;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
