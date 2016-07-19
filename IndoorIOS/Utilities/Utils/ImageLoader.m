//
//  ImageLoader.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/19.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "ImageLoader.h"

#define maxImageWidth 200.0f

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
    
    CGSize originalSize = image.size;
    CGFloat width = originalSize.width;
    CGFloat height = originalSize.height;
    
    if (originalSize.width > originalSize.height * 2) {
        // do nothing
    }else if (originalSize.width > maxImageWidth) {
        width = maxImageWidth;
        height = maxImageWidth * 3 / 4; 
    }
    
    CGSize imageSize = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(imageSize);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
