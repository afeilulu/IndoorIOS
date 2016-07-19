//
//  ImageLoader.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/19.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImageManager.h>

@interface ImageLoader : NSObject<SDWebImageManagerDelegate>
+ (instancetype)sharedImageLoader;
@end
