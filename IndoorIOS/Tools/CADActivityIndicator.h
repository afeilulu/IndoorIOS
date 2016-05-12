//
//  CADActivityIndicator.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/1/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CADActivityIndicator : UIView

@property (nonatomic) BOOL hidesWhenStopped;
@property (nonatomic, strong) UIColor *color;

-(void)startAnimating;
-(void)stopAnimating;
-(BOOL)isAnimating;

@end
