//
//  CADChooseViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#define timeSelectedViewHeight    100

#import "CADPreOrderViewController.h"
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
#import "CADAlertManager.h"
#import "CADStoryBoardUtilities.h"


NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id
// the http URL used for fetching the sport day rules
static NSMutableString *jsonUrl;

@interface CADPreOrderViewController ()

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

@implementation CADPreOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.afm = [AFHTTPSessionManager manager];
    
    // 适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    [self.commitButton setHidden:true];
    self.commitButton.layer.cornerRadius = 5.0;
    
    int screen_width = [[UIScreen mainScreen] currentMode].size.width;
    int screen_height = [[UIScreen mainScreen] currentMode].size.height;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    self.screenWidth = screen_width/scale_screen;
    self.screenHeight = screen_height/scale_screen;
//    self.iconDescriptionViewStartY = self.screenHeight - timeSelectedViewHeight * scale_screen + 35;
    self.iconDescriptionViewStartY = self.screenHeight - timeSelectedViewHeight - 65;
    
    self.timeUnitCollectionView.allowsMultipleSelection = YES;
    
    // date list init
    dateList = [[NSMutableArray alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |
    NSCalendarUnitDay |
    NSCalendarUnitWeekday |
    NSCalendarUnitHour |
    NSCalendarUnitMinute |
    NSCalendarUnitSecond;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    int n;
    for (n=0;n<7; n=n+1) {
        NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow: +(24 * 60 * 60 * n)];
        comps = [calendar components:unitFlags fromDate:tmpDate];
        NSInteger week = [comps weekday];
        NSInteger month = [comps month];
        NSInteger day = [comps day];
        
        self.currentHour = [comps hour];
        
        NSString *titleString = [NSString stringWithFormat:@"%td.%td",month,day];
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
    /*
    UIBarButtonItem *submitButton =
    [[UIBarButtonItem alloc] initWithTitle:@"提交"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(submitButtonPressed)];
    self.navigationItem.rightBarButtonItem = submitButton;
    */
    
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

- (IBAction)submitOrder:(id)sender {
    [self submitButtonPressed];
}

- (void)submitButtonPressed{
    
    if (self.selectedDateSortedArray.count == 0){
        UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"请预约时间" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    [self submitOrder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.places count] + 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    if (section > 0) {
        int unitSize = [[[self.places objectAtIndex:section - 1] objectForKey:@"unitSize"] intValue];
        if (unitSize == 0) {
            unitSize = 1;
        }
        int numberOfItemsInSection = (_end - _start)/unitSize + 1;
        return  numberOfItemsInSection;
    } else {
        return _end - _start + 1;
    }
    
//    return _end - _start + 1;
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
            timeCell.timeLabel.text = [[NSString alloc] initWithFormat:@"%td:00", _start + indexPath.row - 1 ];
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
            
            // 状态为0 不可用
            NSString *status=[[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"status"];
            if ([status isEqualToString:@"0"]) {
                contentCell.backgroundColor = [UIColor colorWithWhite:kUnSelectableColor/256.0 alpha:1.0];
                contentCell.contentLabel.text = @"";
                return contentCell;
            }
            
            // 开始和结束时间不同不可用
            NSString *open_time = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"open_time"];
            NSString *close_time = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"close_time"];
            int open_int=self.start;
            int close_int=self.end;
            if ([open_time rangeOfString:@":"].location != NSNotFound) {
                open_int = [[open_time componentsSeparatedByString:@":"][0] intValue];
            }
            if ([close_time rangeOfString:@":"].location != NSNotFound) {
                close_int = [[close_time componentsSeparatedByString:@":"][0] intValue];
            }
            if ((open_int < self.start && indexPath.row - 1 + self.start < open_int)
                || (close_int < self.end && indexPath.row - 1 + self.start >= close_int))
            {
                contentCell.backgroundColor = [UIColor colorWithWhite:kUnSelectableColor/256.0 alpha:1.0];
                contentCell.contentLabel.text = @"";
                return contentCell;
            }
            
            // 无价格不可用
            id price = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"price"];
            if (price == (id)[NSNull null] || [[NSString alloc] initWithFormat:@"%@",price ].length == 0) {
                contentCell.backgroundColor = [UIColor colorWithWhite:kUnSelectableColor/256.0 alpha:1.0];
                contentCell.contentLabel.text = @"";
            } else {
                contentCell.backgroundColor = [UIColor colorWithWhite:kSelectableColor/255.0 alpha:1.0];
                contentCell.contentLabel.text = price;
            }
            
            // 异常内容处理
            NSDictionary *unitStatus = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"unitStatus"];
            if ([unitStatus count] > 0) {
                NSArray *keys = [unitStatus allKeys];
                for (NSString *key in keys) {
                    NSDictionary *abnomalContent = [unitStatus objectForKey:key];
                    // 找到正确位置
                    if ([key intValue] == indexPath.row - 1 + _start) {
                        id price = [abnomalContent objectForKey:@"price"];
                        if (price == (id)[NSNull null] || [[NSString alloc] initWithFormat:@"%@",price ].length == 0) {
                            contentCell.backgroundColor = [UIColor colorWithWhite:kUnSelectableColor/256.0 alpha:1.0];
                            contentCell.contentLabel.text = @"";
                        } else {
                            contentCell.backgroundColor = [UIColor colorWithWhite:kSelectableColor/255.0 alpha:1.0];
                            contentCell.contentLabel.text = price;
                        }
                        
                        if ([abnomalContent objectForKey:@"status"] != nil) {
                            // status could be 'stated' or 'disable'
                            contentCell.backgroundColor = [UIColor colorWithWhite:kUnSelectableColor/256.0 alpha:1.0];
                            contentCell.contentLabel.text = @"";
                        }
                        
                        if ([abnomalContent objectForKey:@"unitSize"] != nil) {
                            // TODO:content exception handle
                        }
                    }
                }
            }
            
            // 当天已过时间处理
            if ([self.selectedDate isEqualToString:self.today] && indexPath.row - 1 + _start < self.currentHour) {
                contentCell.backgroundColor = [UIColor colorWithWhite:kUnSelectableColor/256.0 alpha:1.0];
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
    self.timeSelectedView = [[TimeSelectedView alloc] initWithFrame:CGRectMake(2, self.iconDescriptionViewStartY, self.screenWidth-4, timeSelectedViewHeight - 48) params:self.orderParams selectedDate:_selectedDate];
    [self.view addSubview:self.timeSelectedView];
    [self.commitButton setHidden:false];
    [self.commitButton setTitle:[[NSString alloc] initWithFormat:@"提交订单(%@元)",[self.orderParams objectForKey:@"pay" ]] forState:UIControlStateNormal];
    
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
        self.iconDescriptionView = [[IconDescription alloc] initWithFrame:CGRectMake(2,self.iconDescriptionViewStartY, self.screenWidth - 4, timeSelectedViewHeight - 48)];
        [self.view addSubview:self.iconDescriptionView];
        [self.commitButton setHidden:true];
    } else {
//        CGFloat collectionViewHeight = CGRectGetHeight(self.timeUnitCollectionView.bounds);
//        int startY = self.timeUnitCollectionView.frame.origin.y + collectionViewHeight;
        [self generateOrderParams];
        self.timeSelectedView = [[TimeSelectedView alloc] initWithFrame:CGRectMake(2, self.iconDescriptionViewStartY, self.screenWidth-4, timeSelectedViewHeight - 48) params:self.orderParams selectedDate:self.selectedDate];
        [self.view addSubview:self.timeSelectedView];
        [self.commitButton setHidden:false];
        [self.commitButton setTitle:[[NSString alloc] initWithFormat:@"提交订单(%@元)",[self.orderParams objectForKey:@"pay" ]] forState:UIControlStateNormal];
    }
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 这里定义不能点击（选择）的单元
    
    // 正在加载状态数据时，不能选择
    if (self.isLoadingStatus) {
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
    
    // 状态为0 不可用
    NSString *status=[[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"status"];
    if ([status isEqualToString:@"0"]) {
            return NO;
    }
    
    // 开始和结束时间不同不可用
    NSString *open_time = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"open_time"];
    NSString *close_time = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"close_time"];
    int open_int=self.start;
    int close_int=self.end;
    if ([open_time rangeOfString:@":"].location != NSNotFound) {
        open_int = [[open_time componentsSeparatedByString:@":"][0] intValue];
    }
    if ([close_time rangeOfString:@":"].location != NSNotFound) {
        close_int = [[close_time componentsSeparatedByString:@":"][0] intValue];
    }
    if ((open_int < self.start && indexPath.row - 1 + self.start < open_int)
        || (close_int < self.end && indexPath.row - 1 + self.start >= close_int))
    {
        return NO;
    }
    
    // 如果没有价格显示，不能选择 ***************************************
    id price = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"price"];
    if (price == (id)[NSNull null] || [[NSString alloc] initWithFormat:@"%@",price ].length == 0) {
        return NO;
    }
    
    // 异常内容处理
    NSDictionary *unitStatus = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"unitStatus"];
    if ([unitStatus count] > 0) {
        NSArray *keys = [unitStatus allKeys];
        for (NSString *key in keys) {
            NSDictionary *abnomalContent = [unitStatus objectForKey:key];
            // 找到正确位置
            if ([key intValue] == indexPath.row - 1 + _start) {
                id price = [abnomalContent objectForKey:@"price"];
                if (price == (id)[NSNull null] || [[NSString alloc] initWithFormat:@"%@",price ].length == 0) {
                    return NO;
                }
                
                if ([abnomalContent objectForKey:@"status"] != nil) {
                    // status could be 'stated' or 'disable'
                    return NO;
                }
                
                if ([abnomalContent objectForKey:@"unitSize"] != nil) {
                    // TODO:content exception handle
                }
            }
        }
    }
    // **************************************
    
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
    
    return YES;
}

#pragma mark  POHorizontalListDelegate

- (void) didSelectItem:(ListItem *)item {
    
    if (self.isLoadingStatus) {
        return;
    }
    
    [self.timeUnitCollectionView setHidden:true];
    
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
    
    
    [self getSiteStatus];
    self.isLoadingStatus = true;
    
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
            NSString *startTime = [[NSString alloc] initWithFormat:@"%@ %td:00:00",self.selectedDate,indexPath.row - 1 + _start];
            NSString *endTime = [[NSString alloc] initWithFormat:@"%@ %td:00:00",self.selectedDate,indexPath.row - 1 + _start + unitSize];
            double price = [[[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"price"] floatValue];
            
            [aUnit setObject:startTime forKey:@"startTime"];
            
            // 异常内容处理
            NSDictionary *unitStatus = [[self.places objectAtIndex:indexPath.section - 1] objectForKey:@"unitStatus"];
            if ([unitStatus count] > 0) {
                NSArray *keys = [unitStatus allKeys];
                NSString *aKey = [[NSString alloc] initWithFormat:@"%td",indexPath.row - 1 + _start ];
                if ([keys containsObject:aKey]) {
                    NSDictionary *abnomalContent = [unitStatus objectForKey:aKey];
                    
                    if ([abnomalContent objectForKey:@"price"] != nil) {
                        price = [[abnomalContent objectForKey:@"price"] floatValue];
                    }
                    
                    if ([abnomalContent objectForKey:@"unitSize"] != nil) {
                        unitSize = [[abnomalContent objectForKey:@"unitSize"] intValue];
                        endTime = [[NSString alloc] initWithFormat:@"%@ %td:00:00",self.selectedDate,indexPath.row - 1 + _start + unitSize];
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

#pragma mark - ajax interface

/*
 * 获取场馆场地状态
 */
- (void) getSiteStatus {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','sportSiteId':'%@','sportTypeId':'%@','selectDate':'%@'}",self.timeStamp,[Utils md5:beforeMd5],_sportSiteId,_sportTypeId,_selectedDate]};
            
            [self.afm POST:kSportPlaceStatusJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                
                if ([responseObject objectForKey:@"success"] != nil){

                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取场馆场地状态错误" setMessage:errmsg];

                } else {
                    // NSLog(@"JSON: %@", responseObject);
                    
                    self.statusDictionary = responseObject;
                    
                    if (self.statusDictionary) {
                        _start = [[self.statusDictionary objectForKey:@"startTime"] intValue];
                        _end = [[self.statusDictionary objectForKey:@"endTime"] intValue];
                        _places = [[NSMutableArray alloc] initWithArray:[self.statusDictionary objectForKey:@"places"]];
                        
                        if (_start >= _end) {
                            [CADAlertManager showAlert:self setTitle:@"获取场馆场地状态错误" setMessage:@"未知异常"];
                        } else {
                            
                            [_timeUnitCollectionView reloadData];
                            [self.timeUnitCollectionView setHidden:false];
                            
                            // scroll to top left
                            [self.timeUnitCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally|UICollectionViewScrollPositionCenteredVertically animated:true];
                        }
                    }
                    
                    // 显示图标描述
                    if (self.iconDescriptionView == nil){
                        self.iconDescriptionView = [[IconDescription alloc] initWithFrame:CGRectMake(2,self.iconDescriptionViewStartY, self.screenWidth - 4, timeSelectedViewHeight - 48)];
                        [self.view addSubview:self.iconDescriptionView];
                        [self.commitButton setHidden:true];
                    }
                }
                
                self.isLoadingStatus = false;
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取场馆场地状态错误" setMessage:[error localizedDescription]];
                self.isLoadingStatus = false;
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
            
            self.isLoadingStatus = false;
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
        
        self.isLoadingStatus = false;
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/**
 * 提交订单
 */
-(void) submitOrder{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            CADUser *user = CADUserManager.sharedInstance.getUser;
            if (user == nil || user.phone == nil){
                NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [defaults objectForKey:@"user"];
                user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if (user != nil){
                    [CADUserManager.sharedInstance setUser:user];
                }
            }
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            [self.orderParams setObject:user.phone forKey:@"phone"];
            [self.orderParams setObject:self.timeStamp forKey:@"randTime"];
            [self.orderParams setObject:[Utils md5:beforeMd5] forKey:@"secret"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.orderParams
                                                               options:(NSJSONWritingOptions) 0
                                                                 error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"%@",jsonString]};
            
            [self.afm POST:kSubmitOrderJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"提交订单错误" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
                    NSLog(@"JSON: %@", responseObject);
                    NSDictionary *orderInfoDic=[responseObject objectForKey:@"orderInfo"];
                    
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
                    [orderInfo setSportTypeName:[orderInfoDic objectForKey:@"sportTypeName"]];
                    [orderInfo setSportTypeSmallImage:[orderInfoDic objectForKey:@"sportTypeSmallImage"]];
                    
                    // set back title
                    UIBarButtonItem *blankButton =
                    [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                     style:UIBarButtonItemStylePlain
                                                    target:nil
                                                    action:nil];
                    [[self navigationItem] setBackBarButtonItem:blankButton];
                    
                    CADPayViewController* vc = (CADPayViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Pay" class:[CADPayViewController class]];
                    [vc setOrderInfo:orderInfo];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }
                
                self.isLoadingStatus = false;
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"提交订单错误" setMessage:[error localizedDescription]];
                self.isLoadingStatus = false;
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
            
            self.isLoadingStatus = false;
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
        
        self.isLoadingStatus = false;
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

@end
