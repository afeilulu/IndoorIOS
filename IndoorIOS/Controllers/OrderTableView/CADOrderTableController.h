//
//  CADOrderTableController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/28.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface CADOrderTableController : UITableViewController

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@property (nonatomic, strong) NSMutableArray* orders;
@property (nonatomic, strong) NSString* tomorrow;

@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSString* codeDesc;

@end
