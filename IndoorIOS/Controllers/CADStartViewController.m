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
    
    self.resultsTableController = [[CADSearchResultController alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
//    self.searchController.searchBar.barStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.placeholder= NSLocalizedString(@"Search", @"SearchBar PlaceHolder");
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.keyboardType = UIKeyboardTypeDefault;
    
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.dimsBackgroundDuringPresentation = true;
    
    self.navigationItem.titleView = self.searchController.searchBar;
    self.definesPresentationContext = true;
    

    self.afm = [AFHTTPSessionManager manager];
    
    [self getSportSiteList:@""];
//    [self getRecommendStoreList:@"" atPage:@"1" withPageSize:@"10"];
//    [self getRecommendTrainerListAtPage:@"1" withPageSize:@"10"];
//    [self getActivityList:@"" atPage:@"1" withPageSize:@"10"];
    
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
    
    // hand over the filtered results to our search results table
    CADSearchResultController *searchResultController = (CADSearchResultController *)self.searchController.searchResultsController;
    searchResultController.filteredResults = searchResults;
    [searchResultController.tableView reloadData];
    
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
                    
                    // TODO
                    // first set depending on location
                    [self.cityButton setTitle:[CADUserManager sharedInstance].cityName];
                    
                    for (NSDictionary *city in self.cityArray) {
                        UIAlertAction *action = [UIAlertAction
                                                        actionWithTitle:[city objectForKey:@"name"]
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                                        {
                                                            [self.cityButton setTitle:[city objectForKey:@"name"]];
                                                        }];
                        [self.cityActionSheet addAction:action];
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
                    NSLog(@"JSON: %@", responseObject);
                    
                    NSArray *allSitesInDic = [responseObject objectForKey:@"list"];
                    self.sites = [[NSMutableArray alloc] init];
                    for (NSDictionary *item in allSitesInDic) {
                        StadiumRecord *site = [[StadiumRecord alloc] init];
                        site.name = [item objectForKey:@"name"];
                        site.imageURLString = [item objectForKey:@"imgUrl"];
                        site.lat = [item objectForKey:@"lat"];
                        site.lng = [item objectForKey:@"lng"];
                        site.idString = [item objectForKey:@"id"];
                        
                        [self.sites addObject:site];
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
                    NSLog(@"JSON: %@", responseObject);
                    
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
                    NSLog(@"JSON: %@", responseObject);
                    
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
                    NSLog(@"JSON: %@", responseObject);
                    
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
            item.distance = [[NSString alloc] initWithFormat:@"%.0f米",distance ];
        }
    }
    
}

@end
