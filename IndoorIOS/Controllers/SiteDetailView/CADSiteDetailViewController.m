//
//  CADSiteDetailViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 16/6/16.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//
#define heightOfHeaderInSection 30

#import "CADSiteDetailViewController.h"
#import "IconDownloader.h"
#import "StadiumManager.h"
#import "SportDayRule.h"
#import "ListItem.h"
#import "Utils.h"
#import "ParseStadiumDetail.h"
#import "Constants.h"
#import "CADPointAnnotation.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "CADUser.h"
#import "CADUserManager.h"
#import "CADAlertManager.h"
#import "CADPreOrderViewController.h"
#import "CADLoginController.h"
#import "CADStoryBoardUtilities.h"
#import <UIImageView+WebCache.h>

static NSAttributedString *cr;

@interface CADSiteDetailViewController ()

@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic) CGSize imageSize;
@property (nonatomic) NSInteger selectedSportIndex;

// the set of IconDownloader objects for each image
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation CADSiteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.afm = [AFHTTPSessionManager manager];
    
    [_stretchView setContentMode:UIViewContentModeScaleAspectFill];
    _stretchableTableHeaderView = [CADStretchableTableHeaderView new];
    [_stretchableTableHeaderView stretchHeaderForTableView:self.tableView withView:_stretchView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // init
    self.selectedSportIndex = -1;
    
    cr = [[NSAttributedString alloc] initWithString:@"\n"];
    
    // get stadium information
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    _stadiumRecord = [stadiumManager getStadiumRecordById:_stadiumId];
    
    if ( !_stadiumRecord.gotDetail || _stadiumRecord.productTypes.count == 0) {
        // 从服务器获取场馆详情
        
        [self getDetail];
    } else {
        // 直接组织数据
        [self loadTableViewData];
    }
    
    [_stretchView sd_setImageWithURL:[NSURL URLWithString:_stadiumRecord.imageURLString]];
    
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
            
            if ([sportTypeId length]<10) { // the length for distingwish image of stadium or of sport type
                _stretchView.image = stadium.image;
            }
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:sportTypeId];
            
            [self.tableView reloadData];
        }];
        (self.imageDownloadsInProgress)[sportTypeId] = iconDownloader;
        [iconDownloader startDownloadWithSportTypeId:sportTypeId];
    }
}

#pragma mark-- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [_headers objectAtIndex:section];
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, heightOfHeaderInSection)];
    
    if (section == 0){
        
        /* Create custom view to display section header... */
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
        [label setFont:[UIFont systemFontOfSize:18]];
        NSString *string =[_headers objectAtIndex:section];
        /* Section header is in 0th index... */
        [label setText:string];
        [view addSubview:label];
        
        // create score label as section header
        if ((NSNull *)_stadiumRecord.score != [NSNull null]){
            UILabel *score = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 60, 5, 60, 20)];
            [score setFont:[UIFont systemFontOfSize:20]];
            [score setTextColor:[UIColor orangeColor]];
            [score setText:_stadiumRecord.score];
            [view addSubview:score];
        }
    }
    
    if (section > 0){
        
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, 40.0, 40.0)];
        UIImage *image = [_stadiumRecord.imagesOfSportType objectForKey:[self.sportTypeIds objectAtIndex:section-1]];
        [imageView1 setImage:image];
        [view addSubview:imageView1];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, tableView.frame.size.width, 18)];
        [label setFont:[UIFont systemFontOfSize:18]];
        NSString *string =[_headers objectAtIndex:section];
        /* Section header is in 0th index... */
        [label setText:string];
        [view addSubview:label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //set the position of the button
        button.frame = CGRectMake(tableView.frame.size.width - 100, 5, 100, 18);
        [button setTitle:@"预 订" forState:UIControlStateNormal];
        [button setTag:section];
        [button addTarget:self action:@selector(customActionPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor= [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [view addSubview:button];
    }
    
    //    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return heightOfHeaderInSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    cell.textLabel.text = (NSString*)[[_sections objectAtIndex:indexPath.section]
//                                      objectAtIndex:indexPath.row];
    
    id info = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([info isKindOfClass:[NSString class]]) {
        cell.textLabel.text = info;
    }
    if ([info isKindOfClass:[NSMutableAttributedString class]]) {
        [cell.textLabel setAttributedText:info];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UILabel *attr = (UILabel *)[cell viewWithTag:1000];
    
    if (indexPath.section == 0) {
        cell.imageView.image = [UIImage imageNamed:_iconNames[indexPath.row]];
        
//        [attr removeFromSuperview];
    } else {
        cell.imageView.image = nil;
        
        /*
        if (!attr) {
            attr = [[UILabel alloc] init];
            attr.textAlignment = NSTextAlignmentCenter;
            [attr setBackgroundColor:[UIColor orangeColor]];
            [attr setFont:[UIFont systemFontOfSize:17.0]];
            attr.textColor = [UIColor whiteColor];
            CGRect textRect = CGRectMake(cell.contentView.frame.size.width - 110, 5.0, 100.0, cell.contentView.frame.size.height - 10);
            [attr setFrame:textRect];
            [attr setTag:1000];
            [attr.layer setMasksToBounds:YES];
            attr.layer.cornerRadius = 5;
            [cell.contentView addSubview:attr];
        }
        [attr setText:[NSString stringWithFormat: @"测试文本 %i",indexPath.row]];
         */
        
    }
    
    
    
    /*
     cell.textLabel.numberOfLines = 0;
     [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     cell.textLabel.text = [NSString stringWithFormat: @"%@",[self.stadiumProperties objectAtIndex:indexPath.row]];
     //    [cell.textLabel setAttributedText:[_stadiumProperties objectAtIndex:indexPath.row]];
     //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     */
    
    return cell;
}

/*
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 NSString *cellText = [_stadiumProperties objectAtIndex:indexPath.row];
 UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
 CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
 CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
 
 return labelSize.height + 20;
 }
 */

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

-(void)customActionPressed :(id)sender
{
    // set back title
    UIBarButtonItem *blankButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:blankButton];
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"user"];
    CADUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (user != nil){
        [CADUserManager.sharedInstance setUser:user];
    }
    
    if (user == nil){
        CADLoginController* vc = (CADLoginController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Login" class:[CADLoginController class]];
        
        [self.navigationController pushViewController:vc animated:YES];
        [vc setSportTypeId:[_sportTypeIds objectAtIndex:[sender tag] - 1]];
        [vc setSportSiteId:_stadiumId];
        [vc setNextView:@"PreOrder"];
        [vc setNextClass:[CADPreOrderViewController class]];
        
    }else {
        CADPreOrderViewController* vc = (CADPreOrderViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"PreOrder" class:[CADPreOrderViewController class]];
        
        [self.navigationController pushViewController:vc animated:YES];
        [vc setSportTypeId:[_sportTypeIds objectAtIndex:[sender tag] - 1]];
        [vc setSportSiteId:_stadiumId];
        
    }
}

#pragma mark  POHorizontalListDelegate

- (void) didSelectItem:(ListItem *)item {
    /* useless currently
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
    CADChooseViewController *viewController = (CADChooseViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chooseview"];
    
    NSString *dateString = [NSString stringWithFormat:@"%@", item.objectTag];
    viewController.selectedDate = dateString;
    viewController.selectedSportIndex = self.selectedSportIndex;
    viewController.selectedStadiumId = self.stadiumRecord.idString;
    
    // set back title
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"aaa"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    [self.navigationController pushViewController:viewController animated:YES];
     */
}

- (void)loadTableViewData
{
    // get stadium information
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    _stadiumRecord = [stadiumManager getStadiumRecordById:_stadiumId];
    
    if (!_stadiumRecord.gotDetail)
        return;
    
    if (_iconNames==nil) {
        _iconNames = [[NSMutableArray alloc] init];
    }
    
    if (_sections==nil) {
        _sections = [[NSMutableArray alloc] init];
    }
    
    if (_headers==nil){
        _headers = [[NSMutableArray alloc] init];
    }
    
    if (_sportTypeIds == nil) {
        _sportTypeIds = [[NSMutableArray alloc] init];
    }
    
    [_iconNames removeAllObjects];
    [_sections removeAllObjects];
    [_headers removeAllObjects];
    [_sportTypeIds removeAllObjects];
    
    // 详细信息
    NSMutableArray* addressInfo = [[NSMutableArray alloc] init];
    NSMutableString *timePeriod=[NSMutableString stringWithString:@""];
    
    // 场馆时间
    [timePeriod appendString:_stadiumRecord.open_time];
    [timePeriod appendString:@"-"];
    [timePeriod appendString:_stadiumRecord.close_time];
    [addressInfo addObject:timePeriod];
    [_iconNames addObject:@"ic_clock"];
    
    // 场馆地址
    NSMutableString *address=[NSMutableString stringWithString:@""];
//    [address appendString:_stadiumRecord.area_code];
//    [address appendString:@" "];
//    [address appendString:_stadiumRecord.area_name];
//    [address appendString:@" "];
    [address appendString:_stadiumRecord.address];
    [addressInfo addObject:address];
    [_iconNames addObject:@"ic_location"];
    
    // 场馆公交
    if ((NSNull *)_stadiumRecord.bus_road != [NSNull null]) {
        [addressInfo addObject:_stadiumRecord.bus_road];
        [_iconNames addObject:@"ic_bus"];
    }
    
    // 场馆空气质量
    if (_stadiumRecord.pms && _stadiumRecord.pms.count > 0) {
        [addressInfo addObject:[[NSString alloc] initWithFormat:@"PM2.5 %@", _stadiumRecord.pms[0]]];
        [_iconNames addObject:@"ic_filter_drama"];
    }
    
    
    // 场馆电话
    if ((NSNull *)_stadiumRecord.phone != [NSNull null]) {
        [addressInfo addObject:_stadiumRecord.phone];
        [_iconNames addObject:@"ic_phone_black"];
    }
    
    [_sections addObject:addressInfo];
    [_headers addObject:@"场馆信息"];
    
    // 运动信息
    for (NSDictionary *sport in _stadiumRecord.productTypes) {
        NSMutableArray *sportInfo = [[NSMutableArray alloc] init];
        
        NSArray *attrsOfSport = [sport objectForKey:@"attributes"];
        for (NSDictionary *item in attrsOfSport) {
            NSMutableString *itemInfo=[NSMutableString stringWithString:@""];
            [itemInfo appendString:[item objectForKey:@"attr_name"]];
            while ([itemInfo sizeWithAttributes:nil].width <80) {
                [itemInfo appendString:@" "];
            }
            [itemInfo appendString:[item objectForKey:@"attr_value"]];
            
            NSMutableAttributedString *itemAttributedString = [[NSMutableAttributedString alloc] initWithString:itemInfo];
            [itemAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, ((NSString *)[item objectForKey:@"attr_name"]).length) ];
            [sportInfo addObject:itemAttributedString];
//            [sportInfo addObject:itemInfo];
        }
        
        [_sections addObject:sportInfo];
        [_headers addObject:[sport objectForKey:@"name"]];
        [_sportTypeIds addObject:[sport objectForKey:@"id"]];
        
    }
    
    // download sport type image
    for (NSDictionary *sport in _stadiumRecord.productTypes) {
        if (![_stadiumRecord.imagesOfSportType objectForKey:[sport objectForKey:@"id"]]) {
                [self startIconDownload:_stadiumRecord forSport:[sport objectForKey:@"id"]];
        }
    }
    
    [self.tableView reloadData];
}

/*
 * 获取场馆详情
 */
- (void) getDetail {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','sportSiteId':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.stadiumId]};
            
            [self.afm POST:kStadiumDetailJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] boolValue] == true){
//                    NSLog(@"JSON: %@", responseObject);
                    
                    NSDictionary *sportSiteInfo = [responseObject objectForKey:@"sportSiteInfo"];
                    NSString *id = [sportSiteInfo objectForKey:@"id"];
                    
                    // get singleton
                    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
                    StadiumRecord *stadium = [stadiumManager.stadiumList objectForKey:id];
                    
                    if (!stadium) {
                        stadium = [[StadiumRecord alloc] init];
                    }
                    
                    [stadium setGotDetail:TRUE];
                    
                    //        [stadium setImageURLString:[sportSiteInfo objectForKey:@"logo_url"]];
                    
                    [stadium setOpen_time:[sportSiteInfo objectForKey:@"open_time"]];
                    [stadium setClose_time:[sportSiteInfo objectForKey:@"close_time"]];
                    [stadium setScore:[sportSiteInfo objectForKey:@"score"]];
                    [stadium setSummary:[sportSiteInfo objectForKey:@"summary"]];
                    [stadium setAddress:[sportSiteInfo objectForKey:@"address"]];
                    [stadium setBus_road:[sportSiteInfo objectForKey:@"bus_road"]];
                    [stadium setPhone:[sportSiteInfo objectForKey:@"phone"]];
                    
                    [stadium setArea_code:[sportSiteInfo objectForKey:@"area_code"]];
                    [stadium setArea_name:[sportSiteInfo objectForKey:@"area_name"]];
                    
                    [stadium setAttributes:[sportSiteInfo objectForKey:@"attributes"]];
                    [stadium setProductTypes:[sportSiteInfo objectForKey:@"productTypes"]];
                    [stadium setPms:[sportSiteInfo objectForKey:@"pms"]];
                    
                    [stadiumManager.stadiumList setValue:stadium forKey:id];
                    
                    [self loadTableViewData];
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取场馆详情错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取场馆详情错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"msg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
