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

@interface CADStartViewController : UIViewController <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchController* searchController;

@property (nonatomic, strong) CADSearchResultController *resultsTableController;

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@property (strong,nonatomic) NSArray *cityArray;
@property (strong,nonatomic) UIAlertController *cityActionSheet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cityButton;
- (IBAction)clickCityButton:(UIBarButtonItem *)sender;

@property (nonatomic, strong) NSMutableArray *sites;

@end
