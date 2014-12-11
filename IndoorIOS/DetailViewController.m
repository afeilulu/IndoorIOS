//
//  DetailViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/6.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import "DetailViewController.h"
#import "IconDownloader.h"
#import "StadiumManager.h"
#import "ListItem.h"
#import "Utils.h"
#import "ParseSportDayRule.h"

// the http URL used for fetching the sport day rules
static NSString *const jsonUrl = @"http://chinaairdome.com:9080/indoor/sportDayRule.json";

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *stadiumPropertyTableView;
@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSOperationQueue *queue;

// the set of IconDownloader objects for each image
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // get stadium information
    NSLog(@"title = %@ ",  _stadiumRecordTitle );
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    _stadiumRecord = [stadiumManager getStadiumRecordByTitle:_stadiumRecordTitle];
    
    // 从服务器获取信息
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonUrl]];
    self.jsonConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // init stadiumProperties
    self.stadiumProperties = [[NSMutableArray alloc] init];
    [self.stadiumProperties addObject:self.stadiumRecord.address];
    
    /*
    // set label text
    [_addressLabel setLineBreakMode:NSLineBreakByWordWrapping];
    _addressLabel.numberOfLines = 0;
    [_addressLabel sizeToFit];
    _addressLabel.text = _stadiumRecord.address;
     */
    
//    self.imageScrollView.delegate = self;
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    CGSize size = self.imageScrollView.frame.size;
    [self.imageScrollView setContentSize:CGSizeMake(size.width * 6, size.height)];

    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:1];
    [self startIconDownload:_stadiumRecord forIndexPath:indexPath];
    
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
        item.objectTag = tmpDate;// save for next view after date view item clicked
        [dateList addObject:item];
    }
    
    POHorizontalList *list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0.0, 200.0, 400.0, 82.0) items:dateList];
    [list setDelegate:self];
    [self.view addSubview:list];
    
    // remove table view divider
    [self.stadiumPropertyTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(StadiumRecord *)stadium forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.stadiumRecord = stadium;
        [iconDownloader setCompletionHandler:^{
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:stadium.image];
            imageView.contentMode = UIViewContentModeCenter;
            [self.imageScrollView addSubview:imageView];
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownload];
    }
}

#pragma mark-- UIScrollViewDelegate



#pragma mark-- UITableViewDelegate

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stadiumProperties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    /*
    UILabel *title = [[UILabel alloc] init];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setFont:[UIFont boldSystemFontOfSize:12.0]];
    [title setOpaque: NO];
    [title setText:[NSString stringWithFormat: @"测试文本 %i",indexPath.row]];
    CGRect textRect = CGRectMake(0.0, 0.0, 200.0, 50.0);
    [title setFrame:textRect];
    [cell.contentView addSubview:title];
     */
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.textLabel.text = [NSString stringWithFormat: @"测试文本%i",indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat: @"%@",[self.stadiumProperties objectAtIndex:indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
//    NSUInteger row = [indexPath row];
    
//    if (row == 0){
//        cell.textLabel.text = self.stadiumRecord.address;
//    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *rowString = [self.list objectAtIndex:[indexPath row]];
    NSString *rowString = [NSString stringWithFormat:@"选中行 %i", indexPath.row];
    UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"选中的行信息" message:rowString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}

#pragma mark  POHorizontalListDelegate

- (void) didSelectItem:(ListItem *)item {
    NSLog(@"Horizontal List Item %@ selected", item.title);
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
    
    self.jsonConnection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
//  Called when all connection processing has completed successfully, before the delegate
//  is released by the connection.
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.jsonConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    ParseSportDayRule *parser = [[ParseSportDayRule alloc] initWithData:self.jsonData];
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:parseError];
        });
    };
    
    parser.completionBlock = ^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // get singleton
                StadiumManager *stadiumManager = [StadiumManager sharedInstance];
                
                [self.stadiumProperties addObjectsFromArray:stadiumManager.sportDayRuleList];
                [self.stadiumPropertyTableView reloadData];
            });
        // we are finished with the queue and our ParseOperation
        self.queue = nil;
    };
    
    [self.queue addOperation:parser]; // this will start the "ParseOperation"
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.jsonData = nil;
}

@end
