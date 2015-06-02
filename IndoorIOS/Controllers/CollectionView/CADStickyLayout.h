//
//  CADStickyLayout.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/5/5.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADStickyLayout : UICollectionViewFlowLayout

@property (strong, nonatomic) NSMutableArray *itemAttributes;
//@property (strong, nonatomic) NSMutableArray *itemsSize;
@property (strong, nonatomic) NSMutableDictionary *itemsSizeInSections;
@property (nonatomic, assign) CGSize contentSize;

@end
