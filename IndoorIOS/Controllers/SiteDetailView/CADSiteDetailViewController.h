//
//  DetailViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/6.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POHorizontalList.h"
#import "StadiumRecord.h"
#import "CADStretchableTableHeaderView.h"
#import "AFNetworking.h"

@interface CADSiteDetailViewController : UITableViewController<POHorizontalListDelegate>{
    NSMutableArray *dateList;
}

@property (nonatomic,assign)NSString* stadiumId;
@property (nonatomic,strong)StadiumRecord* stadiumRecord;

@property (weak, nonatomic) IBOutlet UIImageView *stretchView;
@property (nonatomic, strong) CADStretchableTableHeaderView* stretchableTableHeaderView;

@property (nonatomic, strong) NSMutableArray* sections;
@property (nonatomic, strong) NSMutableArray* headers;
@property (nonatomic, strong) NSMutableArray* sportTypeIds;

@property (nonatomic, strong) NSMutableArray* iconNames;

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@end
