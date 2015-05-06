//
//  CADContentCollectionViewCell.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/5/5.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADContentCollectionViewCell.h"
#import "CustomCellBackground.h"

@implementation CADContentCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = backgroundView;
    }
    return self;
}

@end
