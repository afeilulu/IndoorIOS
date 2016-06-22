//
//  CADStartCollectionViewHeader.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/18.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADStartCollectionViewHeader.h"

@implementation CADStartCollectionViewHeader

- (IBAction)moreButtonAction:(id)sender {
    NSLog(@"%@ - %ld", NSStringFromClass([self class]), (long)((UIButton*)sender).tag);
}

- (void)setHeaderWithTitle:(NSString *)title tag:(NSInteger)tag{
    self.sectionTitle.text = title;
    self.moreButton.tag = tag;
}
@end
