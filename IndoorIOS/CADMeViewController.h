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
@property (nonatomic, strong) NSMutableArray* setting;
@property (nonatomic, strong) NSMutableArray* orderInfo;

@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic) int maxTimeUnitCount;

// the set of IconDownloader objects for each image
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@property (nonatomic, strong) UIButton* monthButton;
@property (nonatomic, strong) UIButton* yearButton;
@property (nonatomic, strong) UIButton* allButton;

@property (nonatomic, strong) NSString* tomorrow;
@property (nonatomic) int whichButtonIsClicked;

@end
