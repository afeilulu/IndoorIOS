//
//  CADStartViewController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/9.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADStartViewController.h"
#import "CADAlertManager.h"
#import "StadiumRecord.h"
#import "CADUserManager.h"
#import "StartCollectionView/CADStartCollectionViewHeader.h"
#import "SiteDetailView/CADSiteDetailViewController.h"
#import "CADStoryBoardUtilities.h"
#import "StadiumManager.h"
#import "Trainer.h"
#import "Activity.h"
#import "CADRecmSiteCell.h"
#import "CADAccountViewController.h"
#import "CADLoginController.h"
#import "CADUser.h"
#import "CADCoachDetailTableViewController.h"
#import "CADActivityDetailTableViewController.h"

#define leftAndRightPaddings 8.0
#define numberOfItemPerRow 3.0
#define heightAdjustment 30.0

@interface CADStartViewController ()

@end

@implementation CADStartViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    // 初始化搜索框
    self.resultsTableController = [[CADSearchResultController alloc] init];
    self.searchController = [[CADSearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    // hide empty cell
    self.resultsTableController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.searchController.searchBar.barStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.placeholder= NSLocalizedString(@"Search", @"SearchBar PlaceHolder");
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.tintColor = self.navigationController.navigationBar.barTintColor;
//    self.searchController.searchBar.keyboardType = UIKeyboardTypeDefault;
    
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    
    //去除UISearchBar背景色,解决闪烁问题
    for (UIView *view in self.searchController.searchBar.subviews) {
        // for before iOS7.0
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [view removeFromSuperview];
            break;
        }
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    
    self.navigationItem.title = @"";
    self.navigationItem.titleView = self.searchController.searchBar;
    self.definesPresentationContext = YES; // know where you want UISearchController to be displayed
    
    // 初始化collectionview
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.sectionsTitle = [[NSArray alloc] initWithObjects:@"推荐场馆",@"推荐教练",@"推荐活动", nil];

    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSLog(@"%@ - %f", NSStringFromClass([self class]), screenWidth);

//    CGFloat width = (screenWidth - leftAndRightPaddings) / numberOfItemPerRow;
//    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
//    layout.itemSize = CGSizeMake(width, width + heightAdjustment);
    self.flowItemWidth3 = (screenWidth - leftAndRightPaddings * (numberOfItemPerRow + 1)) / numberOfItemPerRow;
    self.flowItemWidth2 = (screenWidth - leftAndRightPaddings * (2 + 1)) / 2;
    
    self.afm = [AFHTTPSessionManager manager];
    
    // 获取积分规则
    [self getRule];
    
    // get all sport sites
    [self getSportSiteList:@""];
    // TODO : specify city code
    
    [self getRecommendStoreList:@"" atPage:@"1" withPageSize:@"10"];
    [self getRecommendTrainerListAtPage:@"1" withPageSize:@"10"];
    [self getActivityList:@"" atPage:@"1" withPageSize:@"10"];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.sites mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
        //
        // example if searchItems contains "iphone 599 2007":
        //      name CONTAINS[c] "iphone"
        //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
        //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
        //
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // Below we use NSExpression represent expressions in our predicates.
        // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        /*
        // yearIntroduced field matching
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterNoStyle;
        NSNumber *targetNumber = [numberFormatter numberFromString:searchString];
        if (targetNumber != nil) {   // searchString may not convert to a number
            lhs = [NSExpression expressionForKeyPath:@"yearIntroduced"];
            rhs = [NSExpression expressionForConstantValue:targetNumber];
            finalPredicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lhs
                              rightExpression:rhs
                              modifier:NSDirectPredicateModifier
                              type:NSEqualToPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
            
            // price field matching
            lhs = [NSExpression expressionForKeyPath:@"introPrice"];
            rhs = [NSExpression expressionForConstantValue:targetNumber];
            finalPredicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lhs
                              rightExpression:rhs
                              modifier:NSDirectPredicateModifier
                              type:NSEqualToPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
        }
         */
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    self.filteredResults = searchResults;
    
    // hand over the filtered results to our search results table
    CADSearchResultController *searchResultController = (CADSearchResultController *)self.searchController.searchResultsController;
    searchResultController.filteredResults = searchResults;
    [searchResultController reloadData];
}

/*
 * 获取城市
 */
- (void) getCity {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@'}",self.timeStamp,[Utils md5:beforeMd5]]};
            
            [self.afm POST:KGetCityUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
//                    NSLog(@"JSON: %@", responseObject);
                    self.cityArray = [responseObject objectForKey:@"list"];
                    
                    self.cityActionSheet =[UIAlertController
                                      alertControllerWithTitle:nil
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleActionSheet];
                
                    // firstly set depending on location
                    [self.cityButton setTitle:[[CADUserManager sharedInstance].cityName substringWithRange:NSMakeRange(0, 2)]];
                    
                    // setting action sheet
                    NSString *matchCity = [[CADUserManager sharedInstance].cityName substringWithRange:NSMakeRange(0, 2)];
                    for (NSDictionary *city in self.cityArray) {
                        UIAlertAction *action = [UIAlertAction
                                                        actionWithTitle:[city objectForKey:@"name"]
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                                        {
                                                            // update city name
                                                            NSString *innerMatchCity = [[city objectForKey:@"name"] substringWithRange:NSMakeRange(0, 2)];
                                                            [self.cityButton setTitle:innerMatchCity];
                                                            
                                                            // update city code
                                                            for (NSDictionary *innerCity in self.cityArray) {
                                                                if ([[[innerCity objectForKey:@"name"] substringWithRange:NSMakeRange(0, 2)] isEqualToString:innerMatchCity]) {
                                                                    [CADUserManager sharedInstance].cityCode = [innerCity objectForKey:@"code"];
                                                                    break;
                                                                }
                                                            }
                                                        }];
                        [self.cityActionSheet addAction:action];
                        
                        // update city code
                        if ([[[city objectForKey:@"name"] substringWithRange:NSMakeRange(0, 2)] isEqualToString:matchCity]) {
                            [CADUserManager sharedInstance].cityCode = [city objectForKey:@"code"];
                        }
                    }
                    
                    UIAlertAction *cancelAction = [UIAlertAction
                                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                   style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action)
                                                   {
//                                                       NSLog(@"Cancel action");
                                                   }];
                    [self.cityActionSheet addAction:cancelAction];
                    
                    
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"errmsg"];
                    [CADAlertManager showAlert:self setTitle:@"获取城市错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取城市错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
 * 获取场馆列表
 * code:城市代码
 */
- (void) getSportSiteList:(NSString*)code {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','code':'%@'}",self.timeStamp,[Utils md5:beforeMd5],code]};
            
            [self.afm POST:kStadiumsJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
//                    NSLog(@"JSON: %@", responseObject);
                    
                    // get singleton
                    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
                    
                    self.sites = [[NSMutableArray alloc] init];
                    for (NSDictionary *item in [responseObject objectForKey:@"list"]) {
                        
                        NSString* id = [item objectForKey:@"id"];
                        
                        StadiumRecord *site = [stadiumManager.stadiumList objectForKey:id];
                        if (!site) {
                            site = [[StadiumRecord alloc] init];
                        }
                        
                        site.name = [item objectForKey:@"name"];
                        site.imageURLString = [item objectForKey:@"imgUrl"];
                        site.lat = [item objectForKey:@"lat"];
                        site.lng = [item objectForKey:@"lng"];
                        site.idString = id;
                        site.pms =[item objectForKey:@"pms"];
                        site.score = [item objectForKey:@"score"];
                        
                        [self.sites addObject:site];
                        [stadiumManager.stadiumList setValue:site forKey:id];

                    }
                    
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"errmsg"];
                    [CADAlertManager showAlert:self setTitle:@"获取场馆错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取场馆错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
 * 获取推荐场馆
 * key:查询关键字
 * page:第几页
 * pageSize:页面大小
 */
- (void) getRecommendStoreList:(NSString*)key atPage:(NSString*)page withPageSize:(NSString*)pageSize {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','key':'%@','page':'%@','pageSize':'%@'}",self.timeStamp,[Utils md5:beforeMd5],key,page,pageSize]};
            
            [self.afm POST:KRecommendStoreUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
//                    NSLog(@"JSON: %@", responseObject);
                
                    self.recommendSites = [[NSMutableArray alloc] init];
                    for (NSDictionary *item in [responseObject objectForKey:@"list"]) {
                        
                        NSString* id = [item objectForKey:@"id"];
                        StadiumRecord *site = [[StadiumRecord alloc] init];
                        site.name = [item objectForKey:@"name"];
                        site.imageURLString = [item objectForKey:@"imgUrl"];
                        site.lat = [item objectForKey:@"lat"];
                        site.lng = [item objectForKey:@"lng"];
                        site.idString = id;
                        site.pmsValue =[item objectForKey:@"pms"];
                        site.score = [item objectForKey:@"score"];
                        
                        [self.recommendSites addObject:site];
                        
                        self.sitesFlag= YES;
                        [self collectionViewReloadData];
                    }
                    
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"errmsg"];
                    [CADAlertManager showAlert:self setTitle:@"获取场馆错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取场馆错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
 * 获取推荐教练
 * page:第几页
 * pageSize:页面大小
 */
- (void) getRecommendTrainerListAtPage:(NSString*)page withPageSize:(NSString*)pageSize {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','page':'%@','pageSize':'%@'}",self.timeStamp,[Utils md5:beforeMd5],page,pageSize]};
            
            [self.afm POST:KRecommendTrainerUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
//                    NSLog(@"JSON: %@", responseObject);
                    
                    self.trainers = [[NSMutableArray alloc] init];
                    for (NSDictionary *item in [responseObject objectForKey:@"list"]) {
                        Trainer *trainer = [[Trainer alloc] init];
                        trainer.name = [item objectForKey:@"name"];
                        trainer.nick = [item objectForKey:@"nick"];
                        trainer.idString = [item objectForKey:@"id"];
                        trainer.imageUrl = [item objectForKey:@"image_url"];
                        trainer.phone = [item objectForKey:@"phone"];
                        trainer.sexCode = [item objectForKey:@"sex_code"];
                        trainer.typeName = [item objectForKey:@"type_name"];
                        
                        trainer.attrs = [[NSMutableDictionary alloc] init];
                        NSArray *tmpAttrs = [item objectForKey:@"attributes"];
                        for (NSDictionary *attrItem in tmpAttrs) {
                            NSString *value = [attrItem objectForKey:@"attr_value"];
                            if (value == nil) {
                                value = [[attrItem objectForKey:@"attributeDef"] objectForKey:@"default_value"];
                            }
                            
                            [trainer.attrs setObject:value forKey:[[attrItem objectForKey:@"attributeDef"] objectForKey:@"name"]];
                        }
                        
                        [self.trainers addObject:trainer];
                    }
                    
                    self.trainersFlag = YES;
                    [self collectionViewReloadData];
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"errmsg"];
                    [CADAlertManager showAlert:self setTitle:@"获取教练错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取教练错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
 * 获取活动
 * key:关键字
 * page:第几页
 * pageSize:页面大小
 */
- (void) getActivityList:(NSString*)key atPage:(NSString*)page withPageSize:(NSString*)pageSize {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','key':'%@','page':'%@','pageSize':'%@'}",self.timeStamp,[Utils md5:beforeMd5],key,page,pageSize]};
            
            [self.afm POST:KActivityListUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
//                    NSLog(@"JSON: %@", responseObject);
                    
                    self.activities = [[NSMutableArray alloc] init];
                    for (NSDictionary *item in [responseObject objectForKey:@"list"]) {
                        Activity *activity = [[Activity alloc] init];
                        activity.name = [item objectForKey:@"name"];
                        activity.idString = [item objectForKey:@"id"];
                        activity.address = [item objectForKey:@"address"];
                        activity.imageUrl = [item objectForKey:@"logo_url"];
                        activity.startDate = [item objectForKey:@"start_time"];
                        activity.endDate = [item objectForKey:@"end_time"];
                        activity.fee = [item objectForKey:@"fee"];
                        activity.desc = [item objectForKey:@"bak"];
                        activity.initiator = [[item objectForKey:@"customer"] objectForKey:@"name"];
                        activity.contactPhone = [item objectForKey:@"contact_code"];
                        activity.maxNum = [[item objectForKey:@"member_max"] stringValue] ;
                        activity.currentNum = [[item objectForKey:@"member_amount"] stringValue];
                        [self.activities addObject:activity];
                    }
                    self.activitiesFlag = YES;
                    [self collectionViewReloadData];
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"errmsg"];
                    [CADAlertManager showAlert:self setTitle:@"获取活动错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取活动错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/**
 * 获取积分规则 {"item":{"fee":"0.10","percent":"10.00","low":"100.00"},"success":true}
 */
-(void) getRule{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            CADUser *user = CADUserManager.sharedInstance.getUser;
            if (user == nil || user.phone == nil){
                NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [defaults objectForKey:@"user"];
                user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if (user != nil){
                    [CADUserManager.sharedInstance setUser:user];
                }
            }
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@'}",self.timeStamp,[Utils md5:beforeMd5]]};
            
            [self.afm POST:KRuleJFDK parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取积分规则异常" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
//                    NSLog(@"JSON: %@", responseObject);
                    CADUserManager *cm = CADUserManager.sharedInstance;
                    cm.fee2Rmb = [[[responseObject objectForKey:@"item"] objectForKey:@"fee"] floatValue];
                    cm.maxRatio = [[[responseObject objectForKey:@"item"] objectForKey:@"percent"] floatValue];
                    cm.downLimit = [[[responseObject objectForKey:@"item"] objectForKey:@"low"] floatValue];
                    
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取积分规则异常" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickCityButton:(UIBarButtonItem *)sender {
    
    self.cityActionSheet.modalPresentationStyle = UIModalPresentationPopover;
    self.cityActionSheet.popoverPresentationController.barButtonItem = sender;
    self.cityActionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    [self presentViewController:self.cityActionSheet animated:YES completion:nil];
    
}

- (IBAction)clickAccountButton:(UIBarButtonItem *)sender {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"user"];
    CADUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (user == nil){
        // 跳转登录
        CADLoginController* vc = (CADLoginController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Login" class:[CADLoginController class]];
        
        [self.navigationController pushViewController:vc animated:YES];
        [vc setNextView:@"Account"];
        [vc setNextClass:[CADAccountViewController class]];
        
    } else {
        CADAccountViewController * vc = (CADAccountViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Account" class:[CADAccountViewController class]];
        
        UINavigationController *nc = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nc pushViewController:vc animated:YES];
    }
}

#pragma mark - baidu location

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
//    NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    CLGeocoder *Geocoder=[[CLGeocoder alloc]init];//CLGeocoder用法参加之前博客
    CLGeocodeCompletionHandler handler = ^(NSArray *place, NSError *error) {
        for (CLPlacemark *placemark in place) {
//            NSLog(@"city %@",placemark.thoroughfare);//获取街道地址
//            NSLog(@"cityName %@",placemark.locality);//获取城市名
            
            // save city name
            [CADUserManager sharedInstance].cityName = placemark.locality;
            
            break;
        }
    
        // getttingCityFalg make sure get city only once
        if (self.gettingCityFlag == NO && ( self.cityArray == nil || self.cityArray.count == 0)) {
            self.gettingCityFlag = YES;
            [self getCity];
        }
        
    };
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    [Geocoder reverseGeocodeLocation:loc completionHandler:handler];
    

    // 距离计算
    // TODO:try not to calculate every time
    if (self.userLastLat != userLocation.location.coordinate.latitude || self.userLastLng != userLocation.location.coordinate.longitude) {
        
        self.userLastLat = userLocation.location.coordinate.latitude;
        self.userLastLng = userLocation.location.coordinate.longitude;
        
        BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude));
        for (StadiumRecord *item in self.sites) {
            BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([item.lat doubleValue],[item.lng doubleValue]));
            CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
            
            if (distance > 1000) {
                distance = distance / 1000;
                item.distance = [[NSString alloc] initWithFormat:@"%.2f千米",distance ];
            } else {
                item.distance = [[NSString alloc] initWithFormat:@"%.0f米",distance ];
            }
        }
    }
    
}

#pragma mark - collection view

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.sectionsTitle.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return self.recommendSites.count;
            break;
        case 1:
            return self.trainers.count;
            break;
        case 2:
            return self.activities.count;
            break;
    }
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 || indexPath.section == 2) {
        // 场馆 活动 一行显示两个
        return CGSizeMake(self.flowItemWidth2, self.flowItemWidth2 * gRatio);
    } else {
        // 教练一行显示三个
        return CGSizeMake(self.flowItemWidth3, self.flowItemWidth3 / gRatio);
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CADRecmSiteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        // 场馆
        StadiumRecord *site = [self.recommendSites objectAtIndex:indexPath.row];
        [cell updateUI:site.name imageUrl:site.imageURLString type:0];
    }
    
    if (indexPath.section == 1) {
        // 教练
        Trainer *trainer = [self.trainers objectAtIndex:indexPath.row];
        NSString *name = trainer.nick;
        if (name.length == 0) {
            name = trainer.name;
        }
        [cell updateUI:name imageUrl:[[NSString alloc] initWithFormat:@"%@%@",KImageUrl,trainer.imageUrl] type:1];
    }
    
    if (indexPath.section == 2) {
        // 活动
        Activity *activity = [self.activities objectAtIndex:indexPath.row];
        [cell updateUI:activity.name imageUrl:[[NSString alloc] initWithFormat:@"%@%@",KImageUrl,activity.imageUrl] type:2];
    }

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 场馆
    if (indexPath.section == 0) {
        CADSiteDetailViewController* vc = (CADSiteDetailViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Site" class:[CADSiteDetailViewController class]];
        
        [self.navigationController pushViewController:vc animated:YES];
        StadiumRecord *site = [self.recommendSites objectAtIndex:indexPath.row];
        [vc setStadiumId:site.idString];
        [vc setTitle:site.name];
    }
    
    // 教练
    if (indexPath.section == 1) {
        Trainer *trainer = [self.trainers objectAtIndex:indexPath.row];
        
        CADCoachDetailTableViewController* vc = (CADCoachDetailTableViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"CoachDetail" class:[CADCoachDetailTableViewController class]];
        
        [self.navigationController pushViewController:vc animated:YES];
        [vc setCoach:trainer];
        
    }
    
    // 活动
    if (indexPath.section == 2) {
        Activity *activity = [self.activities objectAtIndex:indexPath.row];
        
        CADActivityDetailTableViewController * vc = (CADActivityDetailTableViewController *)[CADStoryBoardUtilities viewControllerForStoryboardName:@"ActivityDetail" class:[CADActivityDetailTableViewController class]];
        
        [self.navigationController pushViewController:vc animated:YES];
        [vc setActivity:activity];
        
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    if (kind == UICollectionElementKindSectionHeader) {
         CADStartCollectionViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"startCollectionHeader" forIndexPath:indexPath];
        
        switch (indexPath.section) {
            case 0:
                [headerView setHeaderWithTitle:@"推荐场馆" tag:indexPath.section];
                break;
            case 1:
                [headerView setHeaderWithTitle:@"推荐教练" tag:indexPath.section];
                break;
            case 2:
                [headerView setHeaderWithTitle:@"推荐活动" tag:indexPath.section];
                break;
        }
        
        return headerView;
    }
    
    return nil;
}

#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CADSiteDetailViewController* vc = (CADSiteDetailViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Site" class:[CADSiteDetailViewController class]];
    
    [self.navigationController pushViewController:vc animated:YES];
    StadiumRecord *site = self.filteredResults[indexPath.row];
    [vc setStadiumId:site.idString];
    [vc setTitle:site.name];
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}

#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}

- (void)collectionViewReloadData{
    if (self.sitesFlag && self.trainersFlag && self.activitiesFlag) {
        [self.collectionView reloadData];
    }
}

@end
