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
#import "CADSearchController.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h> // 定位
#import <BaiduMapAPI_Utils/BMKGeometry.h> // 距离计算

@interface CADStartViewController : UIViewController <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,BMKLocationServiceDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet CADSearchController* searchController;
// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@property (nonatomic, strong) CADSearchResultController *resultsTableController;
@property (nonatomic, copy) NSMutableArray *filteredResults;

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@property (nonatomic) bool gettingCityFlag;
@property (strong,nonatomic) NSArray *cityArray;
@property (strong,nonatomic) UIAlertController *cityActionSheet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cityButton;
- (IBAction)clickCityButton:(UIBarButtonItem *)sender;

@property (nonatomic, strong) NSMutableArray *sites; // 场馆

@property (nonatomic, strong) BMKLocationService* locService;
@property (nonatomic) double userLastLat;
@property (nonatomic) double userLastLng;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic) NSArray *sectionsTitle;
@property (nonatomic, strong) NSMutableArray *trainers; // 教练
@property (nonatomic, strong) NSMutableArray *activities; // 活动

@property (nonatomic) bool sitesFlag; // 场馆
@property (nonatomic) bool trainersFlag; // 教练
@property (nonatomic) bool activitiesFlag; // 活动

@property (nonatomic) CGFloat flowItemWidth2;
@property (nonatomic) CGFloat flowItemWidth3;


@end
