//
//  CADMeViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/30.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//
#define heightOfHeaderInSection 30
#define month 0
#define year 1
#define all 2

#import "CADMeViewController.h"
#import "CADUserManager.h"
#import "CADUser.h"
#import "Constants.h"
#import "Utils.h"
#import "CADOrderListItem.h"
#import "CADParseOrderList.h"
#import "CADOrderTableViewCell.h"
#import "CADPayViewController.h"
#import "StadiumManager.h"
#import "IconDownloader.h"
#import <QuartzCore/QuartzCore.h>

@implementation CADMeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // init yourself data
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _stretchableTableHeaderView = [CADStretchableTableHeaderView new];
    [_stretchableTableHeaderView stretchHeaderForTableView:self.tableView withView:_stretchView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    // 结束时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow: +(24 * 60 * 60)];
    self.tomorrow = [dateFormatter stringFromDate:tmpDate];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    CADUser *user = CADUserManager.sharedInstance.getUser;
    if (user == nil || user.phone == nil){
        // set back title to blank
        UIBarButtonItem *blankButton =
        [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        [[self navigationItem] setBackBarButtonItem:blankButton];
        
        [self performSegueWithIdentifier:@"login" sender:nil];
    } else {
        // 默认本月
        if (!self.monthButton) {
            [self monthPressed];
        } else {
            if (self.monthButton.selected) {
                [self.monthButton sendActionsForControlEvents: UIControlEventTouchUpInside];
            } else if (self.yearButton.selected){
                [self.yearButton sendActionsForControlEvents: UIControlEventTouchUpInside];
            } else if (self.allButton.selected){
                [self.allButton sendActionsForControlEvents: UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_stretchableTableHeaderView scrollViewDidScroll:scrollView];
}

- (void)viewDidLayoutSubviews
{
    [_stretchableTableHeaderView resizeView];
}

#pragma mark-- UITableViewDelegate

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return _headers.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_headers objectAtIndex:section];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, heightOfHeaderInSection)];
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont systemFontOfSize:18]];
    NSString *string =[_headers objectAtIndex:section];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    
    if (section == 2) {
        if (!self.monthButton){
            self.monthButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            //set the position of the button
            self.monthButton.frame = CGRectMake(tableView.frame.size.width - 55, 5, 50, 18);
            [self.monthButton setTitle:@"本月" forState:UIControlStateNormal];
            [self.monthButton setTag:0];
            [self.monthButton addTarget:self action:@selector(monthPressed) forControlEvents:UIControlEventTouchUpInside];
            self.monthButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        }
        
        [view addSubview:self.monthButton];
        
        if (!self.yearButton){
            self.yearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            //set the position of the button
            self.yearButton.frame = CGRectMake(tableView.frame.size.width - 110, 5, 50, 18);
            [self.yearButton setTitle:@"本年" forState:UIControlStateNormal];
            [self.yearButton setTag:0];
            [self.yearButton addTarget:self action:@selector(yearPressed) forControlEvents:UIControlEventTouchUpInside];
            self.yearButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        }
        
        [view addSubview:self.yearButton];
        
        if (!self.allButton){
            self.allButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            //set the position of the button
            self.allButton.frame = CGRectMake(tableView.frame.size.width - 165, 5, 50, 18);
            [self.allButton setTitle:@"所有" forState:UIControlStateNormal];
            [self.allButton setTag:0];
            [self.allButton addTarget:self action:@selector(allPressed) forControlEvents:UIControlEventTouchUpInside];
            self.allButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        }
        
        [view addSubview:self.allButton];
        
        switch (self.whichButtonIsClicked) {
            case month:
                self.monthButton.selected = true;
                self.yearButton.selected = false;
                self.allButton.selected = false;
                break;
                
            case year:
                self.monthButton.selected = false;
                self.yearButton.selected = true;
                self.allButton.selected = false;
                break;
            
            case all:
                self.monthButton.selected = false;
                self.yearButton.selected = false;
                self.allButton.selected = true;

                break;
        }
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return heightOfHeaderInSection;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 详细信息
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"normalCell"];
        
        cell.textLabel.text = (NSString*)[[_sections objectAtIndex:indexPath.section]
                                          objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    } else if (indexPath.section == 1){
        // 设置
        // 修改密码
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"normalCell"];
        
        cell.textLabel.text = (NSString*)[[_sections objectAtIndex:indexPath.section]
                                          objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == 2){
        
        id unknownItem = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        // 无订单的显示
        if ([unknownItem isKindOfClass:[NSString class]]) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"normalCell"];
            
            cell.textLabel.text = (NSString *)unknownItem;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
        
        // 正常订单显示
        if ([unknownItem isKindOfClass:[CADOrderListItem class]]) {
            
            CADOrderListItem *listItem = (CADOrderListItem *)unknownItem;
            static NSString *CellIdentifier = @"OrderCell";
            CADOrderTableViewCell *cell = (CADOrderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // 图片
            //        cell.sportImageView.image = [UIImage imageNamed:@"user_profile"];
            // TODO:load image
            StadiumManager *stadiumManager = [StadiumManager sharedInstance];
            StadiumRecord *stadiumRecord = [stadiumManager getStadiumRecordById:listItem.sportId];
            if (stadiumRecord.gotDetail) {
                if ([stadiumRecord.imagesOfSportType objectForKey:listItem.sportTypeId]) {
                    cell.sportImageView.image = [stadiumRecord.imagesOfSportType objectForKey:listItem.sportTypeId];
                } else {
                    cell.sportImageView.image = [UIImage imageNamed:@"user_profile"];
                    // download sport type image
                    if (![stadiumRecord.imagesOfSportType objectForKey:listItem.sportTypeId]) {
                        [self startIconDownload:stadiumRecord forSport:listItem.sportTypeId];
                    }
                }
            }
            /*
             // Only load cached images; defer new downloads until scrolling ends
             if (!appRecord.appIcon)
             {
             if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
             {
             [self startIconDownload:appRecord forIndexPath:indexPath];
             }
             // if a download is deferred or in progress, return a placeholder image
             cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
             }
             else
             {
             cell.imageView.image = appRecord.appIcon;
             }
             */
            
            // 订单创建时间
            cell.createTimeLabel.text = listItem.createTime;
            
            // 金额
            cell.moneyLabel.text = listItem.totalMoney;
            
            // 订单状态
            cell.statusLabel.text = listItem.orderStatus;
            cell.statusLabel.layer.cornerRadius = 5;
            if ([listItem.orderStatus isEqualToString:@"已支付"]){
                [cell.statusLabel setBackgroundColor:[UIColor greenColor]];
            }
            if ([listItem.orderStatus isEqualToString:@"支付中"]){
                if (listItem.remainTime > 0) {
                    [cell.statusLabel setBackgroundColor:[UIColor magentaColor]];
                } else {
                    cell.statusLabel.text = @"未支付";
                    [cell.statusLabel setBackgroundColor:[UIColor lightGrayColor]];
                }
                
            }
            if ([listItem.orderStatus isEqualToString:@"未支付"]){
                [cell.statusLabel setBackgroundColor:[UIColor lightGrayColor]];
            }
            
            // 场馆名称 和 预订时间
            NSArray *tmpStrings = [[listItem.orderTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "];
            cell.timeLabel.text = [tmpStrings objectAtIndex:tmpStrings.count - 1];
            cell.siteLabel.text = [tmpStrings objectAtIndex:0];
            
            if (_maxTimeUnitCount < [listItem.siteTimeList count]){
                _maxTimeUnitCount = [listItem.siteTimeList count];
            }
            
            // 因为可能会被重用，先删除无用的lableView
            for (int i = [listItem.siteTimeList count]; i < _maxTimeUnitCount; i++) {
                UILabel *aLabel = (UILabel *)[cell viewWithTag:100 + i];
                if (aLabel != nil){
                    [aLabel removeFromSuperview];
                }
            }
            
            // 重用已有的lavelView
            for (int i = 0; i < [listItem.siteTimeList count]; i++) {
                
                UILabel *aLabel;
                aLabel = (UILabel *)[cell viewWithTag:100 + i];
                if (aLabel == nil) {
                    aLabel = [[UILabel alloc] init];
                }
                
                aLabel.frame = CGRectMake(80, 50 + i * 22, 250, 22);
                aLabel.text = [NSString stringWithString:[listItem.siteTimeList objectAtIndex:i]];
                aLabel.textColor = [UIColor lightGrayColor];
                [aLabel setFont:[UIFont systemFontOfSize:14.0]];
                aLabel.tag = 100 + i;//tag the labels
                [cell.contentView addSubview:aLabel];
            }
            
            //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    }
    
    return nil;
}


 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {

     if (indexPath.section == 2) {
         
         id unknownItem = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
         
         // 无订单的显示
         if ([unknownItem isKindOfClass:[NSString class]]) {
             return 44;
         }
         
         if ([unknownItem isKindOfClass:[CADOrderListItem class]]) {
             CADOrderListItem *listItem = (CADOrderListItem *)unknownItem;
             /*
              NSString *cellText = [_stadiumProperties objectAtIndex:indexPath.row];
              UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
              CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
              CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
              return labelSize.height + 20;
              */
             return 76 + 22 * [listItem.siteTimeList count];
         }
         
     }
     
     return 44;
 }


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 修改密码
    if (indexPath.section == 1 && indexPath.row == 0) {
        // set back title
        UIBarButtonItem *blankButton =
        [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        [[self navigationItem] setBackBarButtonItem:blankButton];
        [self performSegueWithIdentifier:@"changePassword" sender:nil];
    }
    
    // 退出登录
    if (indexPath.section == 1 && indexPath.row == 1) {
        [CADUserManager.sharedInstance clear];
        
        // 清除表数据
        [_headers removeAllObjects];
        [_sections removeAllObjects];
        [self.tableView reloadData];
        
        // 清除数据
        self.monthButton = nil;
        
        // 重新显示本页
        [self viewWillAppear:true];
    }
    
    if (indexPath.section == 2) {
        CADOrderListItem *listItem = (CADOrderListItem *)[[_sections objectAtIndex:indexPath.section]
                                                          objectAtIndex:indexPath.row];
        
        if ([listItem.orderStatus isEqualToString:@"未支付"] && listItem.remainTime == 0){
            NSString *rowString = [NSString stringWithFormat:@"%@已过期，请重新预订。", listItem.orderSeq];
            UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"订单" message:rowString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
        } else {
            // set back title
            UIBarButtonItem *blankButton =
            [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                             style:UIBarButtonItemStylePlain
                                            target:nil
                                            action:nil];
            [[self navigationItem] setBackBarButtonItem:blankButton];
            [self performSegueWithIdentifier:@"PayView" sender:listItem];
        }
        
    }
    
}

// yyyy-MM-dd
- (void)getOrderListFrom:(NSString *)fromDateString to:(NSString *)toDateString
{
    CADUser *user = CADUserManager.sharedInstance.getUser;
    NSString *timeStamp = CADUserManager.sharedInstance.getTimeStamp;
    NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,timeStamp ];
    
    // 从服务器获取订单
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kOrderListJsonUrl]];
    [postRequest setHTTPMethod:@"POST"];
    
    /*
    // 日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow: +(24 * 60 * 60)];
    NSString *tomorrow = [dateFormatter stringFromDate:tmpDate];
    */
    
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'%@','startDate':'%@','endDate':'%@','randTime':'%@','secret':'%@'}",user.phone,fromDateString, toDateString,timeStamp,[Utils md5:beforeMd5]];
    //                NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'14791188498','startDate':'2015-03-08','endDate':'2015-04-09','randTime':'43243243543','secret':'M89FFNNKMNJ894893NNNNN'}"];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"不能连接服务器"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
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
    
    CADParseOrderList *parser = [[CADParseOrderList alloc] initWithData:self.jsonData];
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *errorMessage = [parseError localizedDescription];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取订单异常"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            [alertView show];
        });
    };
    
    // Referencing parser from within its completionBlock would create a retain cycle.
    __weak CADParseOrderList *weakParser = parser;
    
    parser.completionBlock = ^(void) {
        CADParseOrderList *strongParser = weakParser;
        if (strongParser && strongParser.orderList) {
            // The completion block may execute on any thread.  Because operations
            // involving the UI are about to be performed, make sure they execute
            // on the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                
//                _orderInfo = [NSMutableArray arrayWithArray:strongParser.orderList];
                
                // 账户信息
                CADUser *user = CADUserManager.sharedInstance.getUser;
                
                if (_sections == nil){
                    _sections = [[NSMutableArray alloc] init];
                } else {
                    [_sections removeAllObjects];
                }
                
                _headers = [[NSMutableArray alloc] initWithObjects:@"账户",@"设置",@"订单", nil];
                
                if (_personInfo == nil) {
                    _personInfo = [[NSMutableArray alloc] init];
                } else {
                    [_personInfo removeAllObjects];
                }
                
                if ((NSNull *)user.phone != [NSNull null])
                    [_personInfo addObject:[NSString stringWithFormat:@"手机：%@",user.phone]];
                if ((NSNull *)user.mail != [NSNull null])
                    [_personInfo addObject:[NSString stringWithFormat:@"邮箱：%@",user.mail]];
                if ((NSNull *)user.qq != [NSNull null])
                    [_personInfo addObject:[NSString stringWithFormat:@"QQ：%@",user.qq]];
                if ((NSNull *)user.fee != [NSNull null])
                    [_personInfo addObject:[NSString stringWithFormat:@"余额：%@",user.fee]];
                
                [_personInfo addObject:[NSString stringWithFormat:@"积分：%@",user.score]];
                
//                if ((NSNull *)user.sex_code != [NSNull null])
//                    [_personInfo addObject:user.sex_code];
//                if ((NSNull *)user.imgUrl != [NSNull null])
//                    [_personInfo addObject:user.imgUrl];
                
                // 增加设置section
                if (_setting == nil){
                    _setting = [[NSMutableArray alloc] init];
                } else {
                    [_setting removeAllObjects];
                }
                [_setting addObject:@"修改密码"];
                [_setting addObject:@"退出登录"];
                
                [_sections addObject:_personInfo];
                [_sections addObject:_setting];
                [_sections addObject:strongParser.orderList];
                
                [self.tableView reloadData];
                
            });
        }
        
        // we are finished with the queue and our ParseOperation
        self.queue = nil;
    };
    
    [self.queue addOperation:parser]; // this will start the "ParseOperation"
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.jsonData = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PayView"]){
        
        CADPayViewController *destination = [segue destinationViewController];
        [destination setOrderInfo:sender];
    }
}

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(StadiumRecord *)stadium forSport:(NSString *)sportTypeId
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[sportTypeId];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.stadiumRecord = stadium;
        [iconDownloader setCompletionHandler:^{
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:sportTypeId];
            
            [self.tableView reloadData];
        }];
        (self.imageDownloadsInProgress)[sportTypeId] = iconDownloader;
        [iconDownloader startDownloadWithSportTypeId:sportTypeId];
    }
}

- (void)monthPressed
{
    self.whichButtonIsClicked = month;
    
    // 开始时间
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-01"];
    NSString *from = [dateFormatter1 stringFromDate:[NSDate date]];
    
    [self getOrderListFrom:from to:self.tomorrow];
}

- (void)yearPressed
{
    self.whichButtonIsClicked = year;
    
    // 开始时间
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-01-01"];
    NSString *from = [dateFormatter1 stringFromDate:[NSDate date]];
    
    [self getOrderListFrom:from to:self.tomorrow];
}

- (void)allPressed
{
    self.whichButtonIsClicked = all;
    [self getOrderListFrom:@"2015-01-01" to:self.tomorrow];
}

@end
