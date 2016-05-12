//
//  CADStoryBoardUtilities.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/1/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADStoryBoardUtilities.h"

@implementation CADStoryBoardUtilities

+ (UIViewController*)viewControllerForStoryboardName:(NSString *)storyboardName class:(id)aclass {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
    NSString* className = nil;
    
    if ([aclass isKindOfClass:[NSString class]])
        className = [NSString stringWithFormat:@"%@", aclass];
    else
        className = [NSString stringWithFormat:@"%s", class_getName([aclass class])];
    
    UIViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@", className]];
    
    return viewController;
}

@end