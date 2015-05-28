//
//  CADDetailDownloader.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/5/28.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "StadiumRecord.h"

@interface CADDetailDownloader : NSObject

@property (nonatomic, strong) StadiumRecord *stadiumRecord;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancelDownload;

@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;

@property (nonatomic, strong) NSOperationQueue *queue;

@end
