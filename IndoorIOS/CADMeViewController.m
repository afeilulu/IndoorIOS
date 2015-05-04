//
//  CADMeViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/30.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADMeViewController.h"
#import "CADUserManager.h"
#import "CADUser.h"
#import "Constants.h"
#import "Utils.h"
#import "CADOrderListItem.h"
#import "CADParseOrderList.h"
#import "CADOrderTableViewCell.h"

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
        NSString *timeStamp = CADUserManager.sharedInstance.getTimeStamp;
        NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,timeStamp ];
        
        // 从服务器获取订单
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kOrderListJsonUrl]];
        [postRequest setHTTPMethod:@"POST"];
        
        // 日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow: +(24 * 60 * 60)];
        NSString *tomorrow = [dateFormatter stringFromDate:tmpDate];
        
//        NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'%@','startDate':'2015-01-01','endDate':'%@','randTime':'%@','secret':'%@'}",user.phone,tomorrow,timeStamp,[Utils md5:beforeMd5]];
                NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'14791188498','startDate':'2015-03-08','endDate':'2015-04-09','randTime':'43243243543','secret':'M89FFNNKMNJ894893NNNNN'}"];
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

/*
 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
 UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
 // Create custom view to display section header...
 UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
 [label setFont:[UIFont systemFontOfSize:18]];
 NSString *string =[_headers objectAtIndex:section];
 // Section header is in 0th index...
 [label setText:string];
 [view addSubview:label];
 
 if (section > 0){
 UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
 //set the position of the button
 button.frame = CGRectMake(tableView.frame.size.width - 100, 5, 100, 18);
 [button setTitle:@"预 订" forState:UIControlStateNormal];
 [button setTag:section];
 [button addTarget:self action:@selector(customActionPressed:) forControlEvents:UIControlEventTouchUpInside];
 button.backgroundColor= [UIColor clearColor];
 [view addSubview:button];
 }
 
 //    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
 
 return view;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
 return 30;
 }
 */

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    static NSString *CellIdentifier = @"CellIdentifier";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"normalCell"];
        
        cell.textLabel.text = (NSString*)[[_sections objectAtIndex:indexPath.section]
                                          objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    } else if (indexPath.section == 1){
        
        static NSString *CellIdentifier = @"OrderCell";
        CADOrderTableViewCell *cell = (CADOrderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        CADOrderListItem *listItem = (CADOrderListItem *)[[_sections objectAtIndex:indexPath.section]
                                                          objectAtIndex:indexPath.row];
        
        cell.sportImageView.image = [UIImage imageNamed:@"user_profile"];
        
        NSArray *tmpStrings = [[listItem.orderTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "];
        cell.timeLabel.text = [tmpStrings objectAtIndex:tmpStrings.count - 1];
        cell.siteLabel.text = [tmpStrings objectAtIndex:0];
        
        if ([listItem.siteTimeList count] == 4) {
            cell.unitLabel1.hidden = false;
            cell.unitLabel2.hidden = false;
            cell.unitLabel3.hidden = false;
            cell.unitLabel4.hidden = false;
            cell.unitLabel1.text = [listItem.siteTimeList objectAtIndex:0];
            cell.unitLabel2.text = [listItem.siteTimeList objectAtIndex:1];
            cell.unitLabel3.text = [listItem.siteTimeList objectAtIndex:2];
            cell.unitLabel4.text = [listItem.siteTimeList objectAtIndex:3];
        }
        
        if ([listItem.siteTimeList count] == 3) {
            cell.unitLabel1.hidden = false;
            cell.unitLabel2.hidden = false;
            cell.unitLabel3.hidden = false;
            cell.unitLabel4.hidden = true;
            cell.unitLabel1.text = [listItem.siteTimeList objectAtIndex:0];
            cell.unitLabel2.text = [listItem.siteTimeList objectAtIndex:1];
            cell.unitLabel3.text = [listItem.siteTimeList objectAtIndex:2];
        }
        
        if ([listItem.siteTimeList count] == 2) {
            cell.unitLabel1.hidden = false;
            cell.unitLabel2.hidden = false;
            cell.unitLabel3.hidden = true;
            cell.unitLabel4.hidden = true;
            cell.unitLabel1.text = [listItem.siteTimeList objectAtIndex:0];
            cell.unitLabel2.text = [listItem.siteTimeList objectAtIndex:1];
        }
        
        if ([listItem.siteTimeList count] == 1 ) {
            cell.unitLabel1.text = [listItem.siteTimeList objectAtIndex:0];
            cell.unitLabel1.hidden = false;
            cell.unitLabel2.hidden = true;
            cell.unitLabel3.hidden = true;
            cell.unitLabel4.hidden = true;
        }
        
        if ([listItem.siteTimeList count] == 0 ) {
            cell.unitLabel1.hidden = true;
            cell.unitLabel2.hidden = true;
            cell.unitLabel3.hidden = true;
            cell.unitLabel4.hidden = true;
        }
        
        cell.createTimeLabel.text = listItem.createTime;
        cell.statusLabel.text = listItem.orderStatus;
        
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    
    
    /*
     cell.textLabel.numberOfLines = 0;
     [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     cell.textLabel.text = [NSString stringWithFormat: @"%@",[self.stadiumProperties objectAtIndex:indexPath.row]];
     //    [cell.textLabel setAttributedText:[_stadiumProperties objectAtIndex:indexPath.row]];
     //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     */
    
    return nil;
}


 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {

     if (indexPath.section == 0) {
         return 44;
     } else {
         CADOrderListItem *listItem = (CADOrderListItem *)[[_sections objectAtIndex:indexPath.section]
                                                           objectAtIndex:indexPath.row];
         /*
         NSString *cellText = [_stadiumProperties objectAtIndex:indexPath.row];
         UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
         CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
         CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
         return labelSize.height + 20;
          */
         
//         return 164 - 22 * (4 - [listItem.siteTimeList count]);
         return 76 + 22 * [listItem.siteTimeList count];
     }
 }


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        NSString *rowString = [NSString stringWithFormat:@"选中行 %i", indexPath.row];
        UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"选中的行信息" message:rowString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        
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
            [self handleError:parseError];
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
                
                if (_sections == nil){
                    _sections = [[NSMutableArray alloc] init];
                } else {
                    [_sections removeAllObjects];
                }
                if (_headers == nil){
                    _headers = [[NSMutableArray alloc] initWithObjects:@"账户",@"订单", nil];
                }
                if (_personInfo == nil) {
                    _personInfo = [[NSMutableArray alloc] init];
                    
                } else {
                    [_personInfo removeAllObjects];
                }
                
                // 账户信息
                CADUser *user = CADUserManager.sharedInstance.getUser;
                
                if ((NSNull *)user.name != [NSNull null])
                    [_personInfo addObject:user.name];
                if ((NSNull *)user.phone != [NSNull null])
                    [_personInfo addObject:user.phone];
                if ((NSNull *)user.mail != [NSNull null])
                    [_personInfo addObject:user.mail];
                if ((NSNull *)user.qq != [NSNull null])
                    [_personInfo addObject:user.qq];
                if ((NSNull *)user.fee != [NSNull null])
                    [_personInfo addObject:user.fee];
                
                [_personInfo addObject:[[NSString alloc] initWithFormat:@"%@",user.score]];
                
                if ((NSNull *)user.sex_code != [NSNull null])
                    [_personInfo addObject:user.sex_code];
                if ((NSNull *)user.imgUrl != [NSNull null])
                    [_personInfo addObject:user.imgUrl];
                
                [_sections addObject:_personInfo];
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

@end
