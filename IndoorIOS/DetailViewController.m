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

@interface DetailViewController ()

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
    return 5;
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
    cell.textLabel.text = [NSString stringWithFormat: @"测试文本%i",indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //    NSUInteger row = [indexPath row];
    
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

@end
