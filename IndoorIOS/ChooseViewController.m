//
//  ChooseViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import "ChooseViewController.h"
#import "Cell.h"
#import "Utils.h"
#import "StadiumManager.h"
#import "SportDayRule.h"
#import "TimeSelectedView/TimeSelectedView.h"

NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id
// the http URL used for fetching the sport day rules
static NSMutableString *jsonUrl;

@interface ChooseViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *timeUnitCollectionView;
@property (nonatomic) int selectedDateListIndex;

// ["20141208","20141209","20141210"...] selected cell index in CollectionView
@property (nonatomic,strong) NSMutableArray *selectedDateSortedArray;

// dictionary for commit by day
// key = "20141220" value = "0,0,0,1,2,3,....0,0" length = 48
@property (nonatomic,strong) NSMutableDictionary *dateToIndexDictionary;

@property (nonatomic,strong) NSSortDescriptor *dateDescriptor;
@property (nonatomic,strong) NSArray *sortDescriptors;

@property (retain, nonatomic) TimeSelectedView *timeSelectedView;
@end

@implementation ChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"selectedDate = %@",self.selectedDate);
    
    self.timeUnitCollectionView.allowsMultipleSelection = YES;
    
    // http://localhost:8080/indoor/reservationStatus/query?sportId=1&stadiumId=1&date=20141208
    jsonUrl = [NSMutableString stringWithString:@"http://chinaairdome.com:9080/indoor/reservationStatus/query?"];
    
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
    
    // init content of UICollectionView depending on sport day rule
    // get sport day rule
    
    // get singleton
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    SportDayRule *sportDayrule = stadiumManager.sportDayRuleList[self.selectedSportIndex];
    
    
    self.dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    self.sortDescriptors = @[self.dateDescriptor];
    
    self.selectedDateSortedArray = [[NSMutableArray alloc] init];
    self.dateToIndexDictionary =[[NSMutableDictionary alloc] init];
    [self.selectedDateSortedArray addObject:self.selectedDate];
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
    // 0:00 - 24:00 minUnit is 30mins
    return 48;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    // make the cell's title the actual NSIndexPath value
    cell.label.text = [NSString stringWithFormat:@"%i:%@", indexPath.row / 2, indexPath.row % 2 == 0?@"00":@"30"];
    cell.label.textColor = [UIColor lightGrayColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"collectionView clicked : %i",indexPath.row);
    
    NSString *selectedIndex = [NSString stringWithFormat:@"%i",indexPath.row];
    
    NSMutableArray *tmpArray = [self.dateToIndexDictionary objectForKey:self.selectedDate];
    if (tmpArray == nil){
        tmpArray = [[NSMutableArray alloc] init];
        [self.dateToIndexDictionary setObject:tmpArray forKey:self.selectedDate];
    }
    
    if (![tmpArray containsObject:selectedIndex]){
        [tmpArray addObject:selectedIndex];
        
        // sort
        NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        [self.dateToIndexDictionary setObject:sortedArray forKey:self.selectedDate];
    }
    
    if (self.timeSelectedView != nil){
        [self.timeSelectedView removeFromSuperview];
        self.timeSelectedView = nil;
    }
    self.timeSelectedView = [[TimeSelectedView alloc] initWithFrame:CGRectMake(0.0, 400.0, 400.0, 82.0) items:self.dateToIndexDictionary dates:self.selectedDateSortedArray];
    [self.view addSubview:self.timeSelectedView];
    
    [self.view bringSubviewToFront:self.timeUnitCollectionView];
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
    // sort
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [self.dateToIndexDictionary setObject:sortedArray forKey:self.selectedDate];
    
    if (self.timeSelectedView != nil){
        [self.timeSelectedView removeFromSuperview];
        self.timeSelectedView = nil;
    }
    
    self.timeSelectedView = [[TimeSelectedView alloc] initWithFrame:CGRectMake(0.0, 400.0, 400.0, 82.0) items:self.dateToIndexDictionary dates:self.selectedDateSortedArray];
    [self.view addSubview:self.timeSelectedView];
    
    [self.view bringSubviewToFront:self.timeUnitCollectionView];
}

#pragma mark  POHorizontalListDelegate

- (void) didSelectItem:(ListItem *)item {
    NSLog(@"%@",item.objectTag);
    
    self.selectedDate = [NSString stringWithFormat:@"%@",item.objectTag];
    
    // clear current select in collection view
    for (NSIndexPath *indexPath in [self.timeUnitCollectionView indexPathsForSelectedItems]){
        [self.timeUnitCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
    if (![self.selectedDateSortedArray containsObject:self.selectedDate]){
        [self.selectedDateSortedArray addObject:self.selectedDate];
        
        // sort using a selector
        self.selectedDateSortedArray = [NSMutableArray arrayWithArray:[self.selectedDateSortedArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    } else {
        // show already selected cell in collection view on selected date
        NSMutableArray *tmpArray = [self.dateToIndexDictionary objectForKey:self.selectedDate];
        for (NSString *item in tmpArray) {
            int index = item.intValue;
            [self.timeUnitCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
        }
    }
}

@end
