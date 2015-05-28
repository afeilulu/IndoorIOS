//
//  CADChooseViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#define timeSelectedViewHeight    100

#import "CADChooseViewController.h"
#import "Cell.h"
#import "Utils.h"
#import "StadiumManager.h"
#import "TimeSelectedView.h"
#import "IconDescription.h"
#import "CustomCellBackground.h"
#import "Constants.h"
#import "CADDateCollectionViewCell.h"
#import "CADContentCollectionViewCell.h"
#import "CADTimeCollectionViewCell.h"
#import "CADUserManager.h"
#import "CADUser.h"
#import "CADPayViewController.h"

NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id
// the http URL used for fetching the sport day rules
static NSMutableString *jsonUrl;

@interface CADChooseViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *timeUnitCollectionView;

@property (nonatomic,strong) NSURLConnection *jsonConnection;
@property (nonatomic,strong) NSURLConnection *saveConn;

// ["20141208","20141209","20141210"...] selected cell index in CollectionView
@property (nonatomic,strong) NSMutableArray *selectedDateSortedArray;

@property (nonatomic,strong) NSMutableDictionary *dateToIndexPathDictionary;

@property (retain, nonatomic) TimeSelectedView *timeSelectedView;
@property (retain, nonatomic) IconDescription *iconDescriptionView;

@property (nonatomic, strong) NSMutableData *jsonData;

@property (nonatomic) int screenWidth;
@property (nonatomic) int screenHeight;
@property (nonatomic) int iconDescriptionViewStartY;

@property (nonatomic,strong) NSString *dateCellIdentifier;
@property (nonatomic,strong) NSString *contentCellIdentifier;
@property (nonatomic,strong) NSString *timeCellIdentifier;

@end

@implementation CADChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int screen_width = [[UIScreen mainScreen] currentMode].size.width;
    int screen_height = [[UIScreen mainScreen] currentMode].size.height;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    self.screenWidth = screen_width/scale_screen;
    self.screenHeight = screen_height/scale_screen;
    self.iconDescriptionViewStartY = self.screenHeight - timeSelectedViewHeight * scale_screen + 35;
    
    self.timeUnitCollectionView.allowsMultipleSelection = YES;
    
    // date list init
    dateList = [[NSMutableArray alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    int n;
    for (n=0;n<7; n=n+1) {
        NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow: +(24 * 60 * 60 * n)];
        comps = [calendar components:unitFlags fromDate:tmpDate];
        int week = [comps weekday];
        int month = [comps month];
        int day = [comps day];
        
        self.currentHour = [comps hour];
        
        NSString *titleString = [NSString stringWithFormat:@"%i.%i",month,day];
        NSString *subTitleString = [Utils getWeekName:week];
        ListItem *item = [[ListItem alloc] initWithFrame:CGRectZero  title:titleString subTitle:subTitleString];
        NSString *dateString = [dateFormatter stringFromDate:tmpDate];
        item.objectTag = dateString;// save for next view after date view item clicked
        
        if (n==0){
            self.today = dateString;
        }
        
        [dateList addObject:item];
    }
    
    POHorizontalList *list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0, 0, 400.0, 82.0) items:dateList];
    [list setDelegate:self];
    [self.view addSubview:list];
    
    [list setItemSelectedAtIndex:0];
    
    self.selectedDateSortedArray = [[NSMutableArray alloc] init];
    self.dateToIndexPathDictionary = [[NSMutableDictionary alloc] init];
    self.orderParams = [[NSMutableDictionary alloc] init];
    
//    self.iconDescriptionView = [[IconDescription alloc] initWithFrame:CGRectMake(2,self.iconDescriptionViewStartY, self.screenWidth - 4, timeSelectedViewHeight)];
//    [self.view addSubview:self.iconDescriptionView];
    
    // add submit button
    UIBarButtonItem *submitButton =
    [[UIBarButtonItem alloc] initWithTitle:@"提交"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(submitButtonPressed)];
    self.navigationItem.rightBarButtonItem = submitButton;
    
    self.timeUnitCollectionView.delegate = self;
    self.timeUnitCollectionView.dataSource = self;

    self.dateCellIdentifier = @"DateCellIdentifier";
    self.contentCellIdentifier = @"ContentCellIdentifier";
    self.timeCellIdentifier = @"TimeCellIdentifier";

    UINib *nib = [UINib nibWithNibName:@"CADDateCollectionViewCell" bundle:nil];
    [self.timeUnitCollectionView registerNib:nib forCellWithReuseIdentifier:self.dateCellIdentifier];
    UINib *nib1 = [UINib nibWithNibName:@"CADContentCollectionViewCell" bundle:nil];
    [self.timeUnitCollectionView registerNib:nib1 forCellWithReuseIdentifier:self.contentCellIdentifier];
    UINib *nib2 = [UINib nibWithNibName:@"CADTimeCollectionViewCell" bundle:nil];
    [self.timeUnitCollectionView registerNib:nib2 forCellWithReuseIdentifier:self.timeCellIdentifier];
}

- (void)submitButtonPressed{
    
    if (self.selectedDateSortedArray.count == 0){
        UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"请预约时间" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    // 提交预订给服务器,返回订单详情
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kSubmitOrderJsonUrl]];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *timeStamp = [[CADUserManager sharedInstance] getTimeStamp];
    NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,timeStamp ];
    NSString *phone = [[CADUserManager sharedInstance] getUser].phone;
    
    [self.orderParams setObject:phone forKey:@"phone"];
    [self.orderParams setObject:timeStamp forKey:@"randTime"];
    [self.orderParams setObject:[Utils md5:beforeMd5] forKey:@"secret"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.orderParams
                                                       options:(NSJSONWritingOptions) 0
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString=%@",jsonString];
    [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];

    self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
    NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    /* POST in JSON format sample
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:saveUrl]];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (NSString *dateItem in [self.dateToIndexDictionary keyEnumerator]) {
        NSArray *selectedIndexs = [self.dateToIndexDictionary objectForKey:dateItem];
        NSMutableString *status=[[NSMutableString alloc] init];
        for (int i=0; i<unitSize; i++) {
            if ([selectedIndexs containsObject:[NSString stringWithFormat:@"%i",i]])
                [status appendString:@"1,"];
            else
                [status appendString:@"0,"];
        }
        
        StatusByDayRecord *statusByDayRecord = [[StatusByDayRecord alloc] init];
//        statusByDayRecord.stadiumId = self.sportDayrule.stadiumId;
//        statusByDayRecord.sportId = self.sportDayrule.sportId;
        statusByDayRecord.date = dateItem;
        statusByDayRecord.status = status;
        
        [dataArray addObject:statusByDayRecord.dictionary];
    }
    
    NSError* error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArray options:kNilOptions error:&error];
    [postRequest setHTTPBody: jsonData];
    
    // Initialize the NSURLConnection and proceed as described in
    // Retrieving the Contents of a URL
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.saveConn = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
     */
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

#pragma mark - collectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.places count] + 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return _end - _start + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // 表左上角单元格
            
            CADDateCollectionViewCell *dateCell = (CADDateCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:self.dateCellIdentifier forIndexPath:indexPath];
            dateCell.backgroundColor = [UIColor whiteColor];
            dateCell.dateLabel.font = [UIFont systemFontOfSize:13];
            dateCell.dateLabel.textColor = [UIColor blackColor];
            dateCell.dateLabel.text = @"";
            
            return dateCell;
        } else {
            // 表头
            
            CADTimeCollectionViewCell *timeCell = (CADTimeCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:self.timeCellIdentifier forIndexPath:indexPath];
            timeCell.timeLabel.font = [UIFont systemFontOfSize:13];
            timeCell.timeLabel.textColor = [UIColor blackColor];
            timeCell.timeLabel.text = [[NSString alloc] initWithFormat:@"%i:00", _start + indexPath.row - 1 ];
            timeCell.backgroundColor = [UIColor whiteColor];
            
            return timeCell;
        }
    } else {
        if (indexPath.row == 0) {
            // 表左边标题
            CADDateCollectionViewCell *dateCell = (CADDateCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:self.dateCellIdentifier forIndexPath:indexPath];
            dateCell.dateLabel.font = [UIFont systemFontOfSize:13];
            dateCell.dateLabel.textColor = [UIColor blackColor];
            dateCell.dateLabel.text = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"name"];
            dateCell.backgroundColor = [UIColor whiteColor];
            
            return dateCell;
        } else {
            // 表内容
            
            CADContentCollectionViewCell *contentCell = (CADContentCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:self.contentCellIdentifier forIndexPath:indexPath];
            contentCell.layer.cornerRadius = 5;
            contentCell.contentLabel.font = [UIFont systemFontOfSize:13];
            contentCell.contentLabel.textColor = [UIColor blackColor];
            contentCell.contentLabel.text = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"price"];
//            if (indexPath.section % 2 != 0) {
//                contentCell.backgroundColor = [UIColor colorWithWhite:242/255.0 alpha:1.0];
//            } else {
//                contentCell.backgroundColor = [UIColor whiteColor];
//            }
            contentCell.backgroundColor = [UIColor colorWithWhite:242/255.0 alpha:1.0];
            
            // 异常内容处理
            NSDictionary *unitStatus = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"unitStatus"];
            if ([unitStatus count] > 0) {
                NSArray *keys = [unitStatus allKeys];
                for (NSString *key in keys) {
                    NSDictionary *abnomalContent = [unitStatus objectForKey:key];
                    // 找到正确位置
                    if ([key intValue] == indexPath.row - 1 + _start) {
                        if ([abnomalContent objectForKey:@"price"] != nil) {
                            contentCell.contentLabel.text = [abnomalContent objectForKey:@"price"];
                        }
                        if ([abnomalContent objectForKey:@"status"] != nil) {
                            // TODO:content exception handle
                        }
                        
                        if ([abnomalContent objectForKey:@"unitSize"] != nil) {
                            // TODO:content exception handle
                        }
                    }
                }
            }
            
            // 当天已过时间处理
            if ([self.selectedDate isEqualToString:self.today] && indexPath.row - 1 + _start < self.currentHour) {
                contentCell.backgroundColor = [UIColor colorWithWhite:235/256.0 alpha:1.0];
                contentCell.contentLabel.text = @"";
            }
            
            return contentCell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.selectedDateSortedArray containsObject:self.selectedDate]){
        [self.selectedDateSortedArray addObject:self.selectedDate];
        
        // sort using a selector
        self.selectedDateSortedArray = [NSMutableArray arrayWithArray:[self.selectedDateSortedArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    
    NSMutableArray *tmpArray = [self.dateToIndexPathDictionary objectForKey:self.selectedDate];
    if (tmpArray == nil){
        tmpArray = [[NSMutableArray alloc] init];
        [self.dateToIndexPathDictionary setObject:tmpArray forKey:self.selectedDate];
    }
    
    if (![tmpArray containsObject:indexPath]){
        [tmpArray addObject:indexPath];
        
        // sort
//        NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:YES]]]];
        
//        [self.dateToIndexPathDictionary setObject:sortedArray forKey:self.selectedDate];
    }
    
    [self.iconDescriptionView removeFromSuperview];
    self.iconDescriptionView = nil;
    if (self.timeSelectedView != nil){
        [self.timeSelectedView removeFromSuperview];
        self.timeSelectedView = nil;
    }
    
//    CGFloat collectionViewHeight = CGRectGetHeight(self.timeUnitCollectionView.bounds);
//    int startY = self.timeUnitCollectionView.frame.origin.y + collectionViewHeight;
    [self generateOrderParams];
    self.timeSelectedView = [[TimeSelectedView alloc] initWithFrame:CGRectMake(2, self.iconDescriptionViewStartY, self.screenWidth-4, timeSelectedViewHeight) params:self.orderParams selectedDate:_selectedDate];
    [self.view addSubview:self.timeSelectedView];
    
//    [self.view bringSubviewToFront:self.timeUnitCollectionView];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *tmpArray = [self.dateToIndexPathDictionary objectForKey:self.selectedDate];
    if (tmpArray == nil || ![tmpArray containsObject:indexPath]){
        return;
    }
    
    [tmpArray removeObject:indexPath];
    if (tmpArray.count == 0){
        [self.selectedDateSortedArray removeObject:self.selectedDate];
        [self.dateToIndexPathDictionary removeObjectForKey:self.selectedDate];
        // sort using a selector
        self.selectedDateSortedArray = [NSMutableArray arrayWithArray:[self.selectedDateSortedArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    } else {
        // sort
//        NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:YES]]]];
//        [self.dateToIndexPathDictionary setObject:sortedArray forKey:self.selectedDate];
    }
    
    if (self.timeSelectedView != nil){
        [self.timeSelectedView removeFromSuperview];
        self.timeSelectedView = nil;
    }
    
    if ([self.selectedDateSortedArray count] == 0 && self.iconDescriptionView == nil){
        self.iconDescriptionView = [[IconDescription alloc] initWithFrame:CGRectMake(2,self.iconDescriptionViewStartY, self.screenWidth - 4, timeSelectedViewHeight)];
        [self.view addSubview:self.iconDescriptionView];
    } else {
//        CGFloat collectionViewHeight = CGRectGetHeight(self.timeUnitCollectionView.bounds);
//        int startY = self.timeUnitCollectionView.frame.origin.y + collectionViewHeight;
        [self generateOrderParams];
        self.timeSelectedView = [[TimeSelectedView alloc] initWithFrame:CGRectMake(2, self.iconDescriptionViewStartY, self.screenWidth-4, timeSelectedViewHeight) params:self.orderParams selectedDate:self.selectedDate];
        [self.view addSubview:self.timeSelectedView];
    }
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 这里定义不能点击（选择）的单元
    
    // 正在加载状态数据时，不能选择
    if (self.isLoadingStatus) {
        return NO;
    }
    
    NSMutableArray *tmpArray = [self.dateToIndexPathDictionary objectForKey:self.selectedDate];
    if (tmpArray.count >= kMaxOrderPlace) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"当前场次组合\n最多可选4片场地！"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
    
    // if you want some cells to be unselectable, list them here
    if (indexPath.section == 0 || indexPath.row == 0) {
        return NO; // do nothing while header or left side clicked
    }
    
    // 当天已过时间处理
    if ([self.selectedDate isEqualToString:self.today] && indexPath.row - 1 + _start < self.currentHour) {
        return NO;
    }
    
    return YES;
}

#pragma mark  POHorizontalListDelegate

- (void) didSelectItem:(ListItem *)item {
    
    // clear selected while date changed
    [self.dateToIndexPathDictionary removeAllObjects];
    [self.selectedDateSortedArray removeAllObjects];
    
    if (self.iconDescriptionView != nil) {
        [self.iconDescriptionView removeFromSuperview];
        self.iconDescriptionView = nil;
    }
    
    if (self.timeSelectedView != nil){
        [self.timeSelectedView removeFromSuperview];
        self.timeSelectedView = nil;
    }
    
    // set new selectedDate
    self.selectedDate = [NSString stringWithFormat:@"%@",item.objectTag];
    
    /*
    // clear current select in collection view
    for (NSIndexPath *indexPath in [self.timeUnitCollectionView indexPathsForSelectedItems]){
        [self.timeUnitCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
    // 重新显示已经被选中的单元表现为被选中状态
    if ([self.selectedDateSortedArray containsObject:self.selectedDate]){
        // show already selected cell in collection view on selected date
        NSMutableArray *tmpArray = [self.dateToIndexPathDictionary objectForKey:self.selectedDate];
        for (NSIndexPath *indexPath in tmpArray) {
            [self.timeUnitCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
        }
    }
     */
    
    // get status of today by post
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kSportPlaceStatusJsonUrl]];
    [postRequest setHTTPMethod:@"POST"];
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'sportSiteId':'%@','sportTypeId':'%@','selectDate':'%@'}",_sportSiteId,_sportTypeId,_selectedDate];
    [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
    self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.isLoadingStatus = true;
    
}

#pragma mark - NSURLConnectionDelegate

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

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
//  Called when enough data has been read to construct an NSURLResponse object.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.jsonData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
//  Called with a single immutable NSData object to the delegate, representing the next
//  portion of the data loaded from the connection.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.jsonData appendData:data];  // append incoming data
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
    
    connection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
//  Called when all connection processing has completed successfully, before the delegate
//  is released by the connection.
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSError* error;
    
    if ([[connection.currentRequest.URL absoluteString] isEqualToString:kSportPlaceStatusJsonUrl]) {
        self.statusDictionary = [NSJSONSerialization
                                 JSONObjectWithData:self.jsonData
                                 options:kNilOptions
                                 error:&error];
        _start = [[self.statusDictionary objectForKey:@"startTime"] intValue];
        _end = [[self.statusDictionary objectForKey:@"endTime"] intValue];
        _places = [self.statusDictionary objectForKey:@"places"];
        
        [_timeUnitCollectionView reloadData];
        self.isLoadingStatus = false;
        
        // 显示图标描述
        if (self.iconDescriptionView == nil){
            self.iconDescriptionView = [[IconDescription alloc] initWithFrame:CGRectMake(2,self.iconDescriptionViewStartY, self.screenWidth - 4, timeSelectedViewHeight)];
            [self.view addSubview:self.iconDescriptionView];
        }
    }
    
    if ([[connection.currentRequest.URL absoluteString] isEqualToString:kSubmitOrderJsonUrl]) {
        NSDictionary *submitOrderResult = [NSJSONSerialization
                                           JSONObjectWithData:self.jsonData
                                           options:kNilOptions
                                           error:&error];
        
        if ([[submitOrderResult objectForKey:@"success"] boolValue] == true){
            
            NSLog(@"%@ - %@", NSStringFromClass([self class]), submitOrderResult);
            
            NSDictionary *orderInfoDic=[submitOrderResult objectForKey:@"orderInfo"];
            
            CADOrderListItem *orderInfo = [[CADOrderListItem alloc] init];
            [orderInfo setSiteTimeList:[orderInfoDic objectForKey:@"siteTimeList"]];
            [orderInfo setTotalMoney:[orderInfoDic objectForKey:@"totalMoney"]];
            [orderInfo setZflx:[orderInfoDic objectForKey:@"zflx"]];
            [orderInfo setRemainTime:[[orderInfoDic objectForKey:@"remainTime"] intValue]];
            [orderInfo setOrderTitle:[orderInfoDic objectForKey:@"orderTitle"]];
            [orderInfo setOrderStatus:[orderInfoDic objectForKey:@"orderStatus"]];
            [orderInfo setOrderSeq:[orderInfoDic objectForKey:@"orderSeq"]];
            [orderInfo setOrderId:[orderInfoDic objectForKey:@"orderId"]];
            [orderInfo setFpPrintYn:[orderInfoDic objectForKey:@"fpPrintYn"]];
            [orderInfo setCreateTime:[orderInfoDic objectForKey:@"createTime"]];
            [orderInfo setSportId:[orderInfoDic objectForKey:@"sportId"]];
            [orderInfo setSportTypeId:[orderInfoDic objectForKey:@"sportTypeId"]];
            
            // set back title
            UIBarButtonItem *blankButton =
            [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                             style:UIBarButtonItemStylePlain
                                            target:nil
                                            action:nil];
            [[self navigationItem] setBackBarButtonItem:blankButton];
            [self performSegueWithIdentifier:@"PayView" sender:orderInfo];
            
        } else {
            NSString *desc = [submitOrderResult objectForKey:@"msg"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"订单提交失败"
                                                                message:desc
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        }
    }
    
    /*
    if ([[NSString stringWithFormat:@"%@",[result objectForKey:@"action"]] isEqualToString:@"save"]) {
        if ([[result objectForKey:@"resultCode"] integerValue] == 1){
            // successfully saved
            
            // 这里会得到订单id
            
            // load payview
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CADChooseViewController *viewController = (CADChooseViewController *)[storyboard instantiateViewControllerWithIdentifier:@"payview"];
            
            // set back title
            UIBarButtonItem *newBackButton =
            [[UIBarButtonItem alloc] initWithTitle:@"订单确认"
                                             style:UIBarButtonItemStyleBordered
                                            target:nil
                                            action:nil];
            [[self navigationItem] setBackBarButtonItem:newBackButton];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
     */
    
    connection = nil;   // release our connection
}

- (void)generateOrderParams
{
    [self.orderParams removeAllObjects];
    float totalMoney = 0;
    NSMutableArray *sportPlaceTimeList = [[NSMutableArray alloc] init];
    
    for (int i=0; i < [self.selectedDateSortedArray count]; i++) {
        
        NSArray *oneDayData = [self.dateToIndexPathDictionary objectForKey:[self.selectedDateSortedArray objectAtIndex:i]];
        
        for (NSIndexPath *indexPath in oneDayData) {
            NSMutableDictionary *aUnit = [[NSMutableDictionary alloc] init];
            [aUnit setObject:[[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"id"] forKey:@"sportPlaceId"];
            [aUnit setObject:[[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"name"] forKey:@"sportPlaceName"];
            
            int unitSize = [[[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"unitSize"] intValue];
            NSString *startTime = [[NSString alloc] initWithFormat:@"%@ %i:00",self.selectedDate,indexPath.row - 1 + _start];
            NSString *endTime = [[NSString alloc] initWithFormat:@"%@ %i:00",self.selectedDate,indexPath.row - 1 + _start + unitSize];
            double price = [[[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"price"] floatValue];
            
            [aUnit setObject:startTime forKey:@"startTime"];
            
            // 异常内容处理
            NSDictionary *unitStatus = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"unitStatus"];
            if ([unitStatus count] > 0) {
                NSArray *keys = [unitStatus allKeys];
                NSString *aKey = [[NSString alloc] initWithFormat:@"%i",indexPath.row - 1 + _start ];
                if ([keys containsObject:aKey]) {
                    NSDictionary *abnomalContent = [unitStatus objectForKey:aKey];
                    
                    if ([abnomalContent objectForKey:@"price"] != nil) {
                        price = [[abnomalContent objectForKey:@"price"] floatValue];
                    }
                    
                    if ([abnomalContent objectForKey:@"unitSize"] != nil) {
                        unitSize = [[abnomalContent objectForKey:@"unitSize"] intValue];
                        endTime = [[NSString alloc] initWithFormat:@"%@ %i:00:",self.selectedDate,indexPath.row - 1 + _start + unitSize];
                    }
                    
                }
            }
            
            [aUnit setObject:endTime forKey:@"endTime"];
            [sportPlaceTimeList addObject:aUnit];
            totalMoney = totalMoney + price;
        }
        
    }
    
    [self.orderParams setObject:[[NSString alloc] initWithFormat:@"%.2f",totalMoney] forKey:@"pay"];
    [self.orderParams setObject:sportPlaceTimeList forKey:@"sportPlaceTimeList"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PayView"]){
        
        CADPayViewController *destination = [segue destinationViewController];
        [destination setOrderInfo:sender];
    }
}

@end
