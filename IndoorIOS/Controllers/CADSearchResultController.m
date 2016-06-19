//
//  CADSearchResultController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/12.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADSearchResultController.h"
#import "SiteDetailView/CADSiteDetailViewController.h"
#import "CADStoryBoardUtilities.h"

NSString *const kCellIdentifier = @"cellID";
NSString *const kTableCellNibName = @"CADSearchResultCell";

@implementation CADSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kTableCellNibName bundle:nil] forCellReuseIdentifier:kCellIdentifier];
}

- (void)configureCell:(UITableViewCell *)cell forResult:(StadiumRecord *)site {
    
    cell.textLabel.text = site.name;
    cell.detailTextLabel.text = site.distance;
    
    // build the price and year string
    // use NSNumberFormatter to get the currency format out of this NSNumber (product.introPrice)
    //
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
//    NSString *priceString = [numberFormatter stringFromNumber:product.introPrice];
    
//    NSString *detailedStr = [NSString stringWithFormat:@"%@ | %@", priceString, (product.yearIntroduced).stringValue];
//    cell.detailTextLabel.text = detailedStr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    StadiumRecord *site = self.filteredResults[indexPath.row];  
    [self configureCell:cell forResult:site];
    
    return cell;
}

@end
