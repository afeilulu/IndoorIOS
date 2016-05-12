//
//  CADStoryBoardUtilities.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/1/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
@interface CADStoryBoardUtilities : NSObject

+ (UIViewController*)viewControllerForStoryboardName:(NSString*)storyboardName class:(id)aclass ;

@end