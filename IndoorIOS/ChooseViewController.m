//
//  ChooseViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#define unitSize    48  // 0:00 - 24:00 minUnit is 30mins

#import "ChooseViewController.h"
#import "Cell.h"
#import "Utils.h"
#import "StadiumManager.h"
#import "SportDayRule.h"
#import "TimeSelectedView/TimeSelectedView.h"
#import "IconDescription.h"
#import "StatusByDayRecord.h"
#import "CustomCellBackground.h"

NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id
// the http URL used for fetching the sport day rules
static NSMutableString *jsonUrl;

static NSString *queryUrl = @"http://chinaairdome.com:9080/indoor/reservationStatus/query?sportId=%@&stadiumId=%@&date=%@";
// URL for save reservation status by day
static NSString *saveUrl = @"http://chinaairdome.com:9080/indoor/reservationStatus/saveInJson";

@interface ChooseViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *timeUnitCollectionView;
@property (nonatomic) int selectedDateListIndex;
@property (nonatomic,strong) SportDayRule *sportDayrule;

@property (nonatomic,strong) NSURLConnection *queryConn;
@property (nonatomic,strong) NSURLConnection *saveConn;

// ["20141208","20141209","20141210"...] selected cell index in CollectionView
@property (nonatomic,strong) NSMutableArray *selectedDateSortedArray;

// dictionary for commit by day
// key = "20141220" value = selected index of collectionview
@property (nonatomic,strong) NSMutableDictionary *dateToIndexDictionary;
// for keeping status fetching from remote server
// key format "yyyyMMdd" value is status string like "0,0,0,0,1,1,1,...,0,0,0"
// accoring this status,update collectionview cell
@property (nonatomic,strong) NSMutableDictionary *dateToStatusDictionary;
@property (nonatomic,strong) NSArray *currentStatusArray;

@property (retain, nonatomic) TimeSelectedView *timeSelectedView;
@property (retain, nonatomic) IconDescription *iconDescriptionView;

@property (nonatomic, strong) NSMutableData *jsonData;

@property (nonatomic) int screenWidth;
@property (nonatomic) int screenHeight;
@property (nonatomic) int iconDescriptionViewStartY;
@property (nonatomic) int maxCount;
@end

@implementation ChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int screen_width = [[UIScreen mainScreen] currentMode].size.width;
    int screen_height = [[UIScreen mainScreen] currentMode].size.height;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    self.screenWidth = screen_width/scale_screen;
    self.screenHeight = screen_height/scale_screen;
    
    self.timeUnitCollectionView.allowsMultipleSelection = YES;
    
    // get sport day rule
    // get singleton
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    self.sportDayrule = stadiumManager.sportDayRuleList[self.selectedSportIndex];
    self.maxCount = self.sportDayrule.maxCount.intValue;

    jsonUrl = [NSMutableString stringWithFormat:queryUrl,self.sportDayrule.sportId,self.sportDayrule.stadiumId,self.selectedDate];
    
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
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    int n;
    for (n=0;n<7; n=n+1) {
        NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow: +(24 * 60 * 60 * n)];
        comps = [calendar components:unitFlags fromDate:tmpDate];
        int week = [comps weekday];
        int month = [comps month];
        int day = [comps day];
        
        NSString *titleString = [NSString stringWithFormat:@"%i.%i",month,day];
        NSString *subTitleString = [Utils getWeekName:week];
        ListItem *item = [[ListItem alloc] initWithFrame:CGRectZero  title:titleString subTitle:subTitleString];
        NSString *dateString = [dateFormatter stringFromDate:tmpDate];
        item.objectTag = dateString;// save for next view after date view item clicked
        
        if ([dateString isEqualToString:self.selectedDate])
            self.selectedDateListIndex = n;
        
        [dateList addObject:item];
    }
    
    POHorizontalList *list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0, 0, 400.0, 82.0) items:dateList];
    [list setDelegate:self];
    [self.view addSubview:list];
    
    [list setItemSelectedAtIndex:self.selectedDateListIndex];
    
    self.selectedDateSortedArray = [[NSMutableArray alloc] init];
    self.dateToIndexDictionary = [[NSMutableDictionary alloc] init];
    self.dateToStatusDictionary = [[NSMutableDictionary alloc] init];
    self.currentStatusArray = [[NSArray alloc] init];
    
    self.iconDescriptionViewStartY = self.screenHeight - 200;
    self.iconDescriptionView = [[IconDescription alloc] initWithFrame:CGRectMake(0,self.iconDescriptionViewStartY, self.screenWidth, 40)];
    [self.view addSubview:self.iconDescriptionView];
    
    // add submit button
    UIBarButtonItem *submitButton =
    [[UIBarButtonItem alloc] initWithTitle:@"提交"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(submitButtonPressed)];
    self.navigationItem.rightBarButtonItem = submitButton;
}

- (void)submitButtonPressed{
    NSLog(@"submit button pressed");
    if (self.selectedDateSortedArray.count == 0){
        UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"请预约时间" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    // submit
    
    /*
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/indoor/reservationStatus/save"]];
    // Set the request's content type to application/x-www-form-urlencoded
    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *bodyData = [NSString stringWithFormat:@"stadiumId=%@&sportId=%@&date=%@&status=%@",sportDayrule.stadiumId,sportDayrule.sportId,self.selectedDate,];
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
     */
    
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
        statusByDayRecord.stadiumId = self.sportDayrule.stadiumId;
        statusByDayRecord.sportId = self.sportDayrule.sportId;
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

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return unitSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    // make the cell's title the actual NSIndexPath value
    cell.label.text = [NSString stringWithFormat:@"%i:%@", indexPath.row / 2, indexPath.row % 2 == 0?@"00":@"30"];
    cell.label.textColor = [UIColor grayColor];
    [cell.label setFont:[UIFont systemFontOfSize:16.0]];
    cell.backgroundColor = [UIColor colorWithWhite:235.0/256.0 alpha:1.0]; // need to be set dynamically
    CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
    cell.selectedBackgroundView = backgroundView;
    
    if (self.currentStatusArray != nil && (self.currentStatusArray.count > indexPath.row) && [[self.currentStatusArray objectAtIndex:indexPath.row] integerValue] >= self.maxCount){
        cell.backgroundColor = [UIColor redColor];
        cell.selectedBackgroundView = nil;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"collectionView clicked : %i",indexPath.row);
    
    if (![self.selectedDateSortedArray containsObject:self.selectedDate]){
        [self.selectedDateSortedArray addObject:self.selectedDate];
        
        // sort using a selector
        self.selectedDateSortedArray = [NSMutableArray arrayWithArray:[self.selectedDateSortedArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    
    NSString *selectedIndex = [NSString stringWithFormat:@"%i",indexPath.row];
    
    NSMutableArray *tmpArray = [self.dateToIndexDictionary objectForKey:self.selectedDate];
    if (tmpArray == nil){
        tmpArray = [[NSMutableArray alloc] init];
        [self.dateToIndexDictionary setObject:tmpArray forKey:self.selectedDate];
    }
    
    if (![tmpArray containsObject:selectedIndex]){
        [tmpArray addObject:selectedIndex];
        
        // sort
        NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:YES]]]];
        
        [self.dateToIndexDictionary setObject:sortedArray forKey:self.selectedDate];
    }
    
    [self.iconDescriptionView removeFromSuperview];
    if (self.timeSelectedView != nil){
        [self.timeSelectedView removeFromSuperview];
        self.timeSelectedView = nil;
    }
    
    CGFloat collectionViewHeight = CGRectGetHeight(self.timeUnitCollectionView.bounds);
    int startY = self.timeUnitCollectionView.frame.origin.y + collectionViewHeight;
    NSLog(@"starty=%i",startY);
    self.timeSelectedView = [[TimeSelectedView alloc] initWithFrame:CGRectMake(2, startY+5, self.screenWidth-4, 173) items:self.dateToIndexDictionary dates:self.selectedDateSortedArray selectedSport:self.selectedSportIndex];
    [self.view addSubview:self.timeSelectedView];
    
//    [self.view bringSubviewToFront:self.timeUnitCollectionView];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectItemAtIndexPath : %i",indexPath.row);
    
    NSString *selectedIndex = [NSString stringWithFormat:@"%i",indexPath.row];
    
    NSMutableArray *tmpArray = [self.dateToIndexDictionary objectForKey:self.selectedDate];
    if (tmpArray == nil || ![tmpArray containsObject:selectedIndex]){
        return;
    }
    
    [tmpArray removeObject:selectedIndex];
    if (tmpArray.count == 0){
        [self.selectedDateSortedArray removeObject:self.selectedDate];
        [self.dateToIndexDictionary removeObjectForKey:self.selectedDate];
        // sort using a selector
        self.selectedDateSortedArray = [NSMutableArray arrayWithArray:[self.selectedDateSortedArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    } else {
        // sort
        NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:YES]]]];
        [self.dateToIndexDictionary setObject:sortedArray forKey:self.selectedDate];
    }
    
    if (self.timeSelectedView != nil){
        [self.timeSelectedView removeFromSuperview];
        self.timeSelectedView = nil;
    }
    
    if ([self.selectedDateSortedArray count] == 0){
        self.iconDescriptionView = [[IconDescription alloc] initWithFrame:CGRectMake(0,self.iconDescriptionViewStartY, self.screenWidth, 40)];
        [self.view addSubview:self.iconDescriptionView];
    } else {
        CGFloat collectionViewHeight = CGRectGetHeight(self.timeUnitCollectionView.bounds);
        int startY = self.timeUnitCollectionView.frame.origin.y + collectionViewHeight;
        self.timeSelectedView = [[TimeSelectedView alloc] initWithFrame:CGRectMake(2, startY+5, self.screenWidth-4, 173) items:self.dateToIndexDictionary dates:self.selectedDateSortedArray selectedSport:self.selectedSportIndex];
        [self.view addSubview:self.timeSelectedView];
    }
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // if you want some cells to be unselectable, list them here
    if (self.currentStatusArray != nil && (self.currentStatusArray.count > indexPath.row) && [[self.currentStatusArray objectAtIndex:indexPath.row] integerValue] >= self.maxCount){
        return NO;
    }
    
    return YES;
}

#pragma mark  POHorizontalListDelegate

- (void) didSelectItem:(ListItem *)item {
    NSLog(@"%@",item.objectTag);
    
    self.selectedDate = [NSString stringWithFormat:@"%@",item.objectTag];
    
    // clear current select in collection view
    for (NSIndexPath *indexPath in [self.timeUnitCollectionView indexPathsForSelectedItems]){
        [self.timeUnitCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
    // get status of current selected date
    jsonUrl = [NSMutableString stringWithFormat:queryUrl,self.sportDayrule.sportId,self.sportDayrule.stadiumId,self.selectedDate];
    
    // we need fetch status every time date seleted in case some other people update on different device
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // 从服务器获取状态信息
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonUrl]];
    self.queryConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if ([self.selectedDateSortedArray containsObject:self.selectedDate]){
        // show already selected cell in collection view on selected date
        NSMutableArray *tmpArray = [self.dateToIndexDictionary objectForKey:self.selectedDate];
        for (NSString *item in tmpArray) {
            int index = item.intValue;
            [self.timeUnitCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
        }
    }
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
    connection = nil;   // release our connection
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSError* error;
    NSDictionary *result = [NSJSONSerialization
                      JSONObjectWithData:self.jsonData
                      options:kNilOptions
                      error:&error];
    
    NSLog(@"result=%@",result);
    
    if ([[NSString stringWithFormat:@"%@",[result objectForKey:@"action"]] isEqualToString:@"query"]) {
    
        if ([[result objectForKey:@"resultCode"] integerValue] == 1){
            // successfully queried
        
            // confirm we get status this time
            NSString *date = [NSString stringWithFormat:@"%@",[result objectForKey:@"date"]];
            NSString *statusValue = [NSString stringWithFormat:@"%@",[result objectForKey:@"status"]];
            NSArray *statusArray = [statusValue componentsSeparatedByString:@","];
            [self.dateToStatusDictionary setObject:statusArray forKey:date];
            [self updateCollectionViewCells];
        } else if ([[result objectForKey:@"resultCode"] integerValue] == 0){
            NSString *statusValue = @"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0";
            NSArray *statusArray = [statusValue componentsSeparatedByString:@","];
            [self.dateToStatusDictionary setObject:statusArray forKey:self.selectedDate];
            [self updateCollectionViewCells];
        }
    }
    
    if ([[NSString stringWithFormat:@"%@",[result objectForKey:@"action"]] isEqualToString:@"save"]) {
        if ([[result objectForKey:@"resultCode"] integerValue] == 1){
            // successfully saved
            // TODO
        }
    }
}

-(void)updateCollectionViewCells
{
    NSArray *statusArray = [self.dateToStatusDictionary objectForKey:self.selectedDate];
    if (statusArray == nil)
        return;
    
    self.currentStatusArray = statusArray;
    
    for (int i=0; i<unitSize; i++) {
        if ((statusArray.count > i)){
            UICollectionViewCell *cell = [self.timeUnitCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if ([[statusArray objectAtIndex:i] integerValue] >= self.maxCount){
                cell.backgroundColor = [UIColor redColor];
                cell.selectedBackgroundView=nil;
            } else {
                cell.backgroundColor = [UIColor colorWithWhite:235.0/256.0 alpha:1.0];
                CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
                cell.selectedBackgroundView = backgroundView;
            }
        }
    }
    
}
@end
