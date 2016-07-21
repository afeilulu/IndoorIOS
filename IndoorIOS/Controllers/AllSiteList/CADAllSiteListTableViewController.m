//
//  CADAllSiteListTableViewController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/22.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADAllSiteListTableViewController.h"
#import "CADSiteDetailViewController.h"
#import "CADStoryBoardUtilities.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "CADPointAnnotation.h"
#import <UIImageView+WebCache.h>
#import "StadiumManager.h"
#import "CADAlertManager.h"

NSString *const kCellIdentifier1 = @"siteListCellID";
NSString *const kTableCellNibName1 = @"CADSiteListCell";

@interface CADAllSiteListTableViewController ()

@end

@implementation CADAllSiteListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kTableCellNibName1 bundle:nil] forCellReuseIdentifier:kCellIdentifier1];
    
    // hide empty cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // 加载地图
    CGFloat width = self.view.frame.size.width;
    CGFloat height = ceil(width * 2/3);
    mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    mapView.zoomLevel = 14;
    
    self.tableView.tableHeaderView = mapView;
    
    // get singleton
//    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
//    
//    self.allSites = [[NSMutableArray alloc] init];
//    for (id key in stadiumManager.stadiumList) {
//        [self.allSites addObject:[stadiumManager.stadiumList objectForKey:key]];
//    }
//    [self.tableView reloadData];
//    [self loadData];
    
    self.afm = [AFHTTPSessionManager manager];
    
    // get all sport sites
    [self getSportSiteList:@""];
    
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
                    
                    self.allSites = [[NSMutableArray alloc] init];
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
                        
                        [self.allSites addObject:site];
                        [stadiumManager.stadiumList setValue:site forKey:id];
                    }
                    
                    [self.tableView reloadData];
                    [self loadData];
                    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [mapView viewWillAppear];
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [mapView viewWillDisappear];
    mapView.delegate = nil; // 不用时，置nil
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.allSites.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier1 forIndexPath:indexPath];
    StadiumRecord *site = self.allSites[indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = site.name;
    cell.detailTextLabel.text = site.distance;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CADSiteDetailViewController* vc = (CADSiteDetailViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Site" class:[CADSiteDetailViewController class]];
        
        [self.navigationController pushViewController:vc animated:YES];
        StadiumRecord *site = [self.allSites objectAtIndex:indexPath.row];
        [vc setStadiumId:site.idString];
        [vc setTitle:site.name];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
- (void)reloadData{
    [self.tableView reloadData];
    // 重新显示地图
    if (self.allSites.count > 0){
        // clear firstly
        if (!self.annotations){
            self.annotations = [[NSMutableArray alloc] init];
        }
        [mapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
        
        [self loadData];
    }
}
 */

/**
 * 显示查找结果中的所有场馆地点
 */
- (void)loadData{
    NSLog(@"loadData");
    
    BMKCoordinateRegion region = [self getCenterRegion];
    //百度地图的坐标范围转换成相对视图的位置
    CGRect fitRect = [mapView convertRegion:region toRectToView:mapView];
    //将地图视图的位置转换成地图的位置
    BMKMapRect fitMapRect = [mapView convertRect:fitRect toMapRectFromView:mapView];
    //设置地图可视范围为数据所在的地图位置
    [mapView setVisibleMapRect:fitMapRect animated:YES];
    
    if (!self.annotations){
        self.annotations = [[NSMutableArray alloc] init];
    }
    NSInteger stadiumCount = self.allSites.count;
    if (stadiumCount > 0){
        for (int i=0; i<stadiumCount; i++) {
            StadiumRecord *stadium = self.allSites[i];
            CADPointAnnotation * item = [[CADPointAnnotation alloc]init];
            CLLocationCoordinate2D coors;
            coors.latitude = [stadium.lat floatValue];
            coors.longitude = [stadium.lng floatValue];
            item.coordinate = coors;
            item.title = [stadium name];
            item.subtitle = [[NSString alloc] initWithFormat:@"评分:%@   PM2.5:%@",stadium.score,stadium.pms.count>0?stadium.pms[0]:@""];
            item.stadiumId = [stadium idString];
            //            NSLog(@"%@",item.title);
            [mapView addAnnotation:item];
            
            [self.annotations addObject:item];
        }
    }
    
}

/**
 * 根据所有坐标计算出显示范围和中心点，以便让所有地点都展示出来，有默认值
 */
- (BMKCoordinateRegion)getCenterRegion{
    CLLocationDegrees minLat = 25;
    CLLocationDegrees maxLat = 30;
    CLLocationDegrees minLng = 100;
    CLLocationDegrees maxLng = 120;
    
    NSInteger stadiumCount = self.allSites.count;
    if (stadiumCount > 0){
        int i=0;
        for (int j=0; j<stadiumCount; j++) {
            
            StadiumRecord *stadium = self.allSites[j];
            if (i == 0) {
                minLat = [stadium.lat floatValue];
                maxLat = [stadium.lat floatValue];
                minLng = [stadium.lng floatValue];
                maxLng = [stadium.lng floatValue];
            } else {
                //对比筛选出最小纬度，最大纬度；最小经度，最大经度
                minLat = MIN(minLat, [stadium.lat floatValue]);
                maxLat = MAX(maxLat, [stadium.lat floatValue]);
                minLng = MIN(minLng, [stadium.lng floatValue]);
                maxLng = MAX(maxLng, [stadium.lng floatValue]);
            }
            
            i++;
        }
        
    } else {
        NSLog(@"staisdum list is nil");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"抱歉，没有获取到场地信息。"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    //计算中心点
    float positionAdjust = 0.5f; // to make view move center point
    CLLocationCoordinate2D centCoor;
    centCoor.latitude = (CLLocationDegrees)((maxLat+minLat+positionAdjust) * 0.5f);
    centCoor.longitude = (CLLocationDegrees)((maxLng+minLng) * 0.5f);
    BMKCoordinateSpan span;
    //计算地理位置的跨度
    float offset = 0.8f; // to make annotation view will be shown more center
    span.latitudeDelta = maxLat - minLat + offset;
    span.longitudeDelta = maxLng - minLng;
    //得出数据的坐标区域
    BMKCoordinateRegion region = BMKCoordinateRegionMake(centCoor, span);
    
    return region;
}

#pragma mark implement BMKMapViewDelegate

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"stadiumMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        // 设置标注图片
        //        ((BMKPinAnnotationView*)annotationView).image = [UIImage imageNamed:@"icon_nav_point"];
        annotationView.image = [UIImage imageNamed:@"icon_nav_point"];
    }
    
    //    ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorGreen;
    // 设置重天上掉下的效果(annotation)
    ((BMKPinAnnotationView*)annotationView).animatesDrop = NO;
    ((BMKPinAnnotationView*)annotationView).draggable = NO;
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.2));
    
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    
    return annotationView;
}

/**
 * 响应点击百度地图标记
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    //    NSLog(@"annotation clicked %@", view.reuseIdentifier);
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    /*
     // set back title to blank
     UIBarButtonItem *blankButton =
     [[UIBarButtonItem alloc] initWithTitle:@""
     style:UIBarButtonItemStylePlain
     target:nil
     action:nil];
     [[self navigationItem] setBackBarButtonItem:blankButton];
     
     [self performSegueWithIdentifier:@"showDetail" sender:view];
     */
}

@end
