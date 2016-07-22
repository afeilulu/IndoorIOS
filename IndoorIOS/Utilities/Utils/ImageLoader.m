//
//  ImageLoader.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/19.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "ImageLoader.h"
#import "Constants.h"

@implementation ImageLoader

+ (instancetype)sharedImageLoader
{
    static ImageLoader* loader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[ImageLoader alloc] init];
    });
    
    return loader;
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager
 transformDownloadedImage:(UIImage *)image
                  withURL:(NSURL *)imageURL
{
    // Place your image size here
//    CGFloat width = 200.0f;
//    CGFloat height = 200.0f;
//    CGSize imageSize = CGSizeMake(width, height);
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    CGSize originalSize = image.size;
    CGFloat width = originalSize.width;
    CGFloat height = originalSize.height;
    
    if (originalSize.width > originalSize.height * 2.5) {
        // do nothing
    }else if (originalSize.width > screenWidth) {
        width = screenWidth;
        height = screenWidth * gRatio;
    }
    
    CGSize imageSize = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(imageSize);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
