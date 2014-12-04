//
//  ViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/20.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import "ViewController.h"
#import "BMapKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 加载地图
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.view = _mapView;
//    [self.view addSubview:_mapView];
    
//
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
//        //由于IOS8中定位的授权机制改变 需要进行手动授权
//        CLLocationManager  *locationManager = [[CLLocationManager alloc] init];
//        //获取授权认证
//        [locationManager requestAlwaysAuthorization];
//    }
    
    // 初始化定位服务
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    _locService = [[BMKLocationService alloc]init];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
    [_mapView setZoomLevel:13];
    
    // 开始普通定位
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"start locate");
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
#pragma mark mapViewDelegate 代理方法
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
//    BMKCoordinateRegion region;
//    region.center.latitude = userLocation.location.coordinate.latitude;
//    region.center.longitude = userLocation.location.coordinate.longitude;
//    region.span.latitudeDelta = 0.2;
//    region.span.longitudeDelta = 0.2;
//    
//    if (_mapView){
//        _mapView.region = region;
//        NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
//    }
    
//    [_mapView setRegion:region animated:YES];
//    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    [_mapView updateLocationData:userLocation];

}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
//    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

- (void)loadData{
    NSLog(@"loadData");
}

@end
