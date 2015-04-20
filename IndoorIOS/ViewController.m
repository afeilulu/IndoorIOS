//
//  ViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/20.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import "ViewController.h"
#import "StadiumRecord.h"
#import "StadiumManager.h"
#import "ParseOperation.h"
#import "DetailViewController.h"
#import "BMapKit.h"
#import "Constants.h"
#import "CADPointAnnotation.h"

@interface ViewController ()

@property (nonatomic, strong) NSURLConnection *stadiumsJsonConnection;
@property (nonatomic, strong) NSMutableData *stadiumJsonData;
// the queue to run our "ParseOperation"
@property (nonatomic, strong) NSOperationQueue *queue;

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
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        CLLocationManager  *locationManager = [[CLLocationManager alloc] init];
        //获取授权认证
        [locationManager requestAlwaysAuthorization];
    }
    
    // 初始化定位服务
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    //    _locService = [[BMKLocationService alloc]init];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    //    _locService.delegate = self;
    
    // 开始普通定位
    //    [_locService startUserLocationService];
    //    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    //    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    //    _mapView.showsUserLocation = YES;//显示定位图层
    
    // get singleton
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    if ([stadiumManager.stadiumList count] == 0) {
        
        // 从服务器获取地图信息
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kStadiumsJsonUrl]];
        [postRequest setHTTPMethod:@"POST"];
        NSString *params = [[NSString alloc] initWithFormat:@"jsonString="];
        [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
        _stadiumsJsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
        
        // Test the validity of the connection object. The most likely reason for the connection object
        // to be nil is a malformed URL, which is a programmatic error easily detected during development
        // If the URL is more dynamic, then you should implement a more flexible validation technique, and
        // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
        //
        NSAssert(self.stadiumsJsonConnection != nil, @"Failure to create URL connection.");
        
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    //    _locService.delegate = nil;
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
    [_mapView updateLocationData:userLocation];
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

/**
 * called from AppDelegate
 */
- (void)loadData{
    NSLog(@"loadData");
    
    BMKCoordinateRegion region = [self getCenterRegion];
    //百度地图的坐标范围转换成相对视图的位置
    CGRect fitRect = [_mapView convertRegion:region toRectToView:_mapView];
    //将地图视图的位置转换成地图的位置
    BMKMapRect fitMapRect = [_mapView convertRect:fitRect toMapRectFromView:_mapView];
    //设置地图可视范围为数据所在的地图位置
    [_mapView setVisibleMapRect:fitMapRect animated:YES];
    
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    int stadiumCount = stadiumManager.stadiumList.count;
    if (stadiumCount > 0){
        for (NSString *key in stadiumManager.stadiumList) {
            StadiumRecord *stadium = [stadiumManager.stadiumList objectForKey:key];
            CADPointAnnotation * item = [[CADPointAnnotation alloc]init];
            CLLocationCoordinate2D coors;
            coors.latitude = [stadium.lat floatValue];
            coors.longitude = [stadium.lng floatValue];
            item.coordinate = coors;
            item.title = [stadium name];
            item.stadiumId = [stadium idString];
            //            NSLog(@"%@",item.title);
            [_mapView addAnnotation:item];
        }
    }
    
}

/**
 * 根据所有坐标计算出显示范围和中心点，以便让所有地点都展示出来，有默认值
 */
- (BMKCoordinateRegion)getCenterRegion{
    CLLocationDegrees minLat = 25;
    CLLocationDegrees maxLat = 40;
    CLLocationDegrees minLng = 100;
    CLLocationDegrees maxLng = 120;
    
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    int stadiumCount = stadiumManager.stadiumList.count;
    if (stadiumCount > 0){
        int i=0;
        for (NSString *key in stadiumManager.stadiumList) {
            StadiumRecord *stadium = [stadiumManager.stadiumList objectForKey:key];
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
    CLLocationCoordinate2D centCoor;
    centCoor.latitude = (CLLocationDegrees)((maxLat+minLat) * 0.5f);
    centCoor.longitude = (CLLocationDegrees)((maxLng+minLng) * 0.5f);
    BMKCoordinateSpan span;
    //计算地理位置的跨度
    span.latitudeDelta = maxLat - minLat;
    span.longitudeDelta = maxLng - minLng;
    //得出数据的坐标区域
    BMKCoordinateRegion region = BMKCoordinateRegionMake(centCoor, span);
    
    return region;
}

#pragma mark -
#pragma mark implement BMKMapViewDelegate

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    NSLog(@"viewForAnnotation");
    
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"stadiumMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        // 设置标注图片
        ((BMKPinAnnotationView*)annotationView).image = [UIImage imageNamed:@"icon_nav_point"];
    }
    
    //    ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorGreen;
    // 设置重天上掉下的效果(annotation)
    ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    ((BMKPinAnnotationView*)annotationView).draggable = NO;
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    
    return annotationView;
}

/**
 * 响应点击百度地图标记
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    NSLog(@"annotation clicked %@", view.reuseIdentifier);
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
    
    
    [self.parentViewController.navigationItem setTitle:@"title"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *viewController = (DetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"detailview"];
    
    viewController.stadiumId = ((CADPointAnnotation*)view.annotation).stadiumId;
    [viewController.parentViewController.navigationItem setTitle:@"abcd"];
    [viewController.tabBarController setTitle:@"Title"];
    [viewController.navigationController setTitle:@"Live"];
    
    
//    self.title = ((CADPointAnnotation*)view.annotation).title;
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:((CADPointAnnotation*)view.annotation).title style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // hide UITabbarController
    viewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
    
}

// -------------------------------------------------------------------------------
//	handleError:error
//  handle connection error
//  Reports any error with an alert which was received from connection or loading failures.
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot connect to Server"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how
// the connection object,  which is working in the background, can asynchronously communicate back to
// its delegate on the thread from which it was started - in this case, the main thread.
//
#pragma mark - NSURLConnectionDelegate

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
//  Called when enough data has been read to construct an NSURLResponse object.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.stadiumJsonData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
//  Called with a single immutable NSData object to the delegate, representing the next
//  portion of the data loaded from the connection.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.stadiumJsonData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
//  Will be called at most once, if an error occurs during a resource load.
//  No other callbacks will be made after.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (error.code == kCFURLErrorNotConnectedToInternet)
    {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"No Connection Error"};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else
    {
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.stadiumsJsonConnection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
//  Called when all connection processing has completed successfully, before the delegate
//  is released by the connection.
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.stadiumsJsonConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data
    // so that the UI is not blocked
    ParseOperation *parser = [[ParseOperation alloc] initWithData:self.stadiumJsonData];
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:parseError];
        });
    };
    
    parser.completionBlock = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadData];
        });
    };
    
    [self.queue addOperation:parser]; // this will start the "ParseOperation"
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.stadiumJsonData = nil;
}

@end
