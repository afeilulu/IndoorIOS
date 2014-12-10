//
//  DetailViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/6.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StadiumRecord.h"

@interface DetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (nonatomic,strong)NSString* stadiumRecordTitle;
@property (nonatomic,strong)StadiumRecord* stadiumRecord;

@property (nonatomic, retain) IBOutlet UITableView *stadiumPropertyTableView;

@end
