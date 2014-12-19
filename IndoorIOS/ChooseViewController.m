//
//  ChooseViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import "ChooseViewController.h"
#import "Cell.h"

NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id
// the http URL used for fetching the sport day rules
static NSMutableString *jsonUrl;

@interface ChooseViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *timeUnitCollectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSwitchSegment;

@end

@implementation ChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"selectedDate = %@",self.selectedDate);
    
    self.timeUnitCollectionView.allowsMultipleSelection = YES;
    
    // http://localhost:8080/indoor/reservationStatus/query?sportId=1&stadiumId=1&date=20141208
    jsonUrl = [NSMutableString stringWithString:@"http://chinaairdome.com:9080/indoor/reservationStatus/query?"];
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
    return 32;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    // make the cell's title the actual NSIndexPath value
    cell.label.text = [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"collectionView clicked : %i",indexPath.row);
    
}
@end
