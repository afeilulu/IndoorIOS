//
//  ChooseViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POHorizontalList.h"

@interface ChooseViewController : UIViewController<UICollectionViewDataSource,POHorizontalListDelegate>{
    NSMutableArray *dateList;
}
@property (nonatomic, strong) NSString *selectedDate;
@property (nonatomic, strong) NSString *selectedStadiumId;
@property (nonatomic) int selectedSportIndex;

@property (nonatomic, strong) NSString *sportSiteId;
@property (nonatomic, strong) NSString *sportTypeId;

@end
