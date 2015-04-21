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
#import "SportDayRule.h"
#import "ListItem.h"
#import "Utils.h"
#import "ParseStadiumDetail.h"
#import "ChooseViewController.h"
#import "Constants.h"
#import "CADPointAnnotation.h"
#import "BMKAnnotationView.h"

static NSAttributedString *cr;

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *stadiumPropertyTableView;
@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic) CGSize imageSize;
@property (nonatomic) int selectedSportIndex;

// the set of IconDownloader objects for each image
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // init
    self.selectedSportIndex = -1;
    
    cr = [[NSAttributedString alloc] initWithString:@"\n"];
    
    // 初始化图片大小
    //    self.imageScrollView.delegate = self;
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    _imageSize = self.imageScrollView.frame.size;
    [self.imageScrollView setContentSize:CGSizeMake(_imageSize.width * 6, _imageSize.height)];// width * 6 for scroll
    
    // get stadium information
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    _stadiumRecord = [stadiumManager getStadiumRecordById:_stadiumId];
    
    if ( !_stadiumRecord.gotDetail) {
        // 从服务器获取场馆详情
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kStadiumDetailJsonUrl]];
        [postRequest setHTTPMethod:@"POST"];
        NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'sportSiteId':'%@'}",_stadiumId];
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
        
        // 获取图片显示
        self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:1];
        [self startIconDownload:_stadiumRecord forIndexPath:indexPath];
    } else {
        if (_stadiumRecord.image){
            // 直接显示图片
            UIImageView *imageView = [[UIImageView alloc] initWithImage:_stadiumRecord.image];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self.imageScrollView addSubview:imageView];
        }
    }
    
    // init stadiumProperties
    self.stadiumProperties = [[NSMutableArray alloc] init];
    //    NSString *addressAndPhone = [[self.stadiumRecord.address stringByAppendingString:@"\n"] stringByAppendingString:self.stadiumRecord.phone];
    //    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:addressAndPhone];
    //    [self.stadiumProperties addObject:string];
    
    /*
     // set label text
     [_addressLabel setLineBreakMode:NSLineBreakByWordWrapping];
     _addressLabel.numberOfLines = 0;
     [_addressLabel sizeToFit];
     _addressLabel.text = _stadiumRecord.address;
     */
    
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
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self.imageScrollView addSubview:imageView];
            
            // 设置navigtionController背景图片
            //            [self.navigationController.navigationBar setBackgroundImage:stadium.image forBarMetrics:UIBarMetricsDefault];
            
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

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stadiumProperties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    static NSString *CellIdentifier = @"CellIdentifier";
    //
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    //    if (cell == nil) {
    //
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //
    //    }
    
    NSString *CellIdentifier = [NSString  stringWithFormat:@"Cell_%d",indexPath.row];
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
    
    //    cell.layoutMargins = UIEdgeInsetsZero;
    //    cell.preservesSuperviewLayoutMargins = NO;
    
    cell.textLabel.numberOfLines = 0;
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    cell.textLabel.text = [NSString stringWithFormat: @"%@",[self.stadiumProperties objectAtIndex:indexPath.row]];
    [cell.textLabel setAttributedText:[self.stadiumProperties objectAtIndex:indexPath.row]];
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    NSString *rowString = [NSString stringWithFormat:@"选中行 %i", indexPath.row];
    //    UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"选中的行信息" message:rowString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    //    [alter show];
    if (indexPath.row > 0){
        self.selectedSportIndex = indexPath.row - 1;
    } else {
        self.selectedSportIndex = -1;
    }
}

#pragma mark  POHorizontalListDelegate

- (void) didSelectItem:(ListItem *)item {
    
    if (self.selectedSportIndex < 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请选择运动项目"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChooseViewController *viewController = (ChooseViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chooseview"];
    
    NSString *dateString = [NSString stringWithFormat:@"%@", item.objectTag];
    viewController.selectedDate = dateString;
    viewController.selectedSportIndex = self.selectedSportIndex;
    viewController.selectedStadiumId = self.stadiumRecord.idString;
    
    // get singleton
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    SportDayRule *sportDayRule = [stadiumManager.sportDayRuleList objectAtIndex:self.selectedSportIndex];
    
    // set back title
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:sportDayRule.name
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    [self.navigationController pushViewController:viewController animated:YES];
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
    
    ParseStadiumDetail *parser = [[ParseStadiumDetail alloc] initWithData:self.jsonData];
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:parseError];
        });
    };
    
    parser.completionBlock = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // get singleton
            StadiumManager *stadiumManager = [StadiumManager sharedInstance];
            
            for (SportDayRule *rule in stadiumManager.sportDayRuleList) {
                NSData *data = [rule.ruleJson dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *ruleArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSMutableString * ruleString=[NSMutableString stringWithString:@""];
                [ruleString appendString:rule.name];
                //                    [ruleString appendString:@" "];
                //                    [ruleString appendFormat:@"%@",rule.maxCount];
                [ruleString appendString:@"\n"];
                for (int i=0; i<ruleArray.count; ++i) {
                    [ruleString appendString:[ruleArray[i] objectForKey:@"from"]];
                    [ruleString appendString:@"-"];
                    [ruleString appendString:[ruleArray[i] objectForKey:@"to"]];
                    [ruleString appendString:@" "];
                    [ruleString appendString:[ruleArray[i] objectForKey:@"cost"]];
                    [ruleString appendString:@"元 "];
                }
                
                NSRange range=[ruleString rangeOfString:rule.name];
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:ruleString];
                [string addAttribute:NSForegroundColorAttributeName value:[self.view tintColor] range:range];
                
                [self.stadiumProperties addObject:string];
            }
            
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
