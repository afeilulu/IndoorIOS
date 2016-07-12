//
//  CADStartCollectionViewHeader.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/18.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADStartCollectionViewHeader.h"
#import "CADAllSiteListTableViewController.h"
#import "CADStoryBoardUtilities.h"

@implementation CADStartCollectionViewHeader

- (IBAction)moreButtonAction:(id)sender {
    NSLog(@"%@ - %ld", NSStringFromClass([self class]), (long)((UIButton*)sender).tag);
    if ((long)((UIButton*)sender).tag == 0) {
        CADAllSiteListTableViewController * vc = (CADAllSiteListTableViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"AllSiteList" class:[CADAllSiteListTableViewController class]];
        
        UINavigationController *nc = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nc pushViewController:vc animated:YES];
    }
}

- (void)setHeaderWithTitle:(NSString *)title tag:(NSInteger)tag{
    self.sectionTitle.text = title;
    self.moreButton.tag = tag;
}
@end
