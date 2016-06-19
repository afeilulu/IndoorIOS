//
//  CADChooseViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/11.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POHorizontalList.h"

@interface CADPreOrderViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,POHorizontalListDelegate>{
    NSMutableArray *dateList;
}
@property (nonatomic, strong) NSString *selectedDate;
@property (nonatomic, strong) NSString *selectedStadiumId;
@property (nonatomic) int selectedSportIndex;

@property (nonatomic, strong) NSString *sportSiteId;
@property (nonatomic, strong) NSString *sportTypeId;

@property (nonatomic) int start;
@property (nonatomic) int end;
@property (nonatomic, strong) NSDictionary *statusDictionary;
@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic) NSInteger currentHour;
@property (nonatomic, strong) NSString *today;

@property (nonatomic, strong) NSMutableDictionary *orderParams;

@property (nonatomic) BOOL isLoadingStatus;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@end
