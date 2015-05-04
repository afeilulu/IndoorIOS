//
//  CADMeViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/30.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CADStretchableTableHeaderView.h"

@interface CADMeViewController : UITableViewController

//@property (weak, nonatomic) IBOutlet UIImageView *stretchView;
@property (weak, nonatomic) IBOutlet UIImageView *stretchView;
@property (nonatomic, strong) CADStretchableTableHeaderView* stretchableTableHeaderView;

@property (nonatomic, strong) NSMutableArray* sections;
@property (nonatomic, strong) NSMutableArray* headers;

@property (nonatomic, strong) NSMutableArray* personInfo;
@property (nonatomic, strong) NSMutableArray* orderInfo;

@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSOperationQueue *queue;

@end
