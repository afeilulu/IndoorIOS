//
//  CADStartViewController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/9.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "Utils.h"
#import "CADSearchResultController.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h> // 定位
#import <BaiduMapAPI_Utils/BMKGeometry.h> // 距离计算

@interface CADStartViewController : UIViewController <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,BMKLocationServiceDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UISearchController* searchController;

@property (nonatomic, strong) CADSearchResultController *resultsTableController;

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@property (nonatomic) bool gettingCityFlag;
@property (strong,nonatomic) NSArray *cityArray;
@property (strong,nonatomic) UIAlertController *cityActionSheet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cityButton;
- (IBAction)clickCityButton:(UIBarButtonItem *)sender;

@property (nonatomic, strong) NSMutableArray *sites;

@property (nonatomic, strong) BMKLocationService* locService;
@property (nonatomic) double userLastLat;
@property (nonatomic) double userLastLng;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic) NSArray *sectionsTitle;
@property (strong,nonatomic) NSArray *section1;
@property (strong,nonatomic) NSArray *section2;
@property (strong,nonatomic) NSArray *section3;

@end
