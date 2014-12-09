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
    
    // set label text
    [_addressLabel setLineBreakMode:NSLineBreakByWordWrapping];
    _addressLabel.numberOfLines = 0;
    [_addressLabel sizeToFit];
    _addressLabel.text = _stadiumRecord.address;
    
    
//    self.imageScrollView.delegate = self;
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    CGSize size = self.imageScrollView.frame.size;
    [self.imageScrollView setContentSize:CGSizeMake(size.width * 6, size.height)];

    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:1];
    [self startIconDownload:_stadiumRecord forIndexPath:indexPath];
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

// 是否支持频幕旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return NO;
}


@end
