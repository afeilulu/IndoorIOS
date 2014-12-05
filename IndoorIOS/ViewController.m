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
#import "BMapKit.h"

// the http URL used for fetching the stadiums
static NSString *const StadiumsJsonUrl = @"http://chinaairdome.com:9080/indoor/stadium.json";

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
    
    // 从服务器获取地图信息
    // setup url connection
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:StadiumsJsonUrl]];
    _stadiumsJsonConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.stadiumsJsonConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
/*- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
//    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    NSLog(@"heading is %@",userLocation.heading);
}
 */

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
    
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    int stadiumCount = stadiumManager.stadiumList.count;
    if (stadiumCount > 0){
        for (NSString *key in stadiumManager.stadiumList) {
            StadiumRecord *stadium = [stadiumManager.stadiumList objectForKey:key];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coors;
            coors.latitude = [stadium.lat floatValue];
            coors.longitude = [stadium.lng floatValue];
            item.coordinate = coors;
            item.title = [stadium name];
            NSLog(@"%@",item.title);
            [_mapView addAnnotation:item];
        }
    } else {
        NSLog(@"staisdum list is nil");
    }
}

/**
 * 响应点击百度地图标记
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    NSLog(@"annotation clicked %@", view.reuseIdentifier);
    
    [_mapView bringSubviewToFront:view];
    [_mapView setNeedsDisplay];
}

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
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
        ((BMKPinAnnotationView*)annotationView).draggable = NO;
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = NO;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    return annotationView;
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
    
    /*
    // Referencing parser from within its completionBlock would create a retain cycle.
    __weak ParseOperation *weakParser = parser;
    
    parser.completionBlock = ^(void) {
        if (weakParser.stadiumRecordList) {
            // The completion block may execute on any thread.  Because operations
            // involving the UI are about to be performed, make sure they execute
            // on the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                // The root rootViewController is the only child of the navigation
                // controller, which is the window's rootViewController.
                //                ViewController *viewController = (ViewController*)[(UINavigationController*)self.window.rootViewController topViewController];
                
//                ViewController *viewController = (ViewController*)[[(UITabBarController*)self.window.rootViewController viewControllers][0] topViewController];
//                
//                _entries = [NSArray arrayWithArray:weakParser.stadiumRecordList ];
                [self loadData];
            });
        }
        
        // we are finished with the queue and our ParseOperation
        self.queue = nil;
    };
     */
    
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
