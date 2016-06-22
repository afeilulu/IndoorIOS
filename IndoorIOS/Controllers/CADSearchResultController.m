//
//  CADSearchResultController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/12.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADSearchResultController.h"
#import "SiteDetailView/CADSiteDetailViewController.h"
#import "CADStoryBoardUtilities.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "CADPointAnnotation.h"
#import <UIImageView+WebCache.h>

NSString *const kCellIdentifier = @"cellID";
NSString *const kTableCellNibName = @"CADSearchResultCell";

@implementation CADSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kTableCellNibName bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    
    // 加载地图
    CGFloat width = self.view.frame.size.width;
    CGFloat height = ceil(width * 2/3);
    mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    mapView.zoomLevel = 14;
    
    self.tableView.tableHeaderView = mapView;
    
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

- (void)configureCell:(UITableViewCell *)cell forResult:(StadiumRecord *)site {
    
    cell.textLabel.text = site.name;
    cell.detailTextLabel.text = site.distance;
    
//    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:site.imageURLString]];
    
    // build the price and year string
    // use NSNumberFormatter to get the currency format out of this NSNumber (product.introPrice)
    //
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
//    NSString *priceString = [numberFormatter stringFromNumber:product.introPrice];
    
//    NSString *detailedStr = [NSString stringWithFormat:@"%@ | %@", priceString, (product.yearIntroduced).stringValue];
//    cell.detailTextLabel.text = detailedStr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    StadiumRecord *site = self.filteredResults[indexPath.row];  
    [self configureCell:cell forResult:site];
    
    return cell;
}

- (void)reloadData{
    [self.tableView reloadData];
    // 重新显示地图
    if (self.filteredResults.count > 0){
        // clear firstly
        if (!self.annotations){
            self.annotations = [[NSMutableArray alloc] init];
        }
        [mapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
        
        [self loadData];
    }
}

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
    NSInteger stadiumCount = self.filteredResults.count;
    if (stadiumCount > 0){
        for (int i=0; i<stadiumCount; i++) {
            StadiumRecord *stadium = self.filteredResults[i];
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
    
    NSInteger stadiumCount = self.filteredResults.count;
    if (stadiumCount > 0){
        int i=0;
        for (int j=0; j<stadiumCount; j++) {
            
            StadiumRecord *stadium = self.filteredResults[j];
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
