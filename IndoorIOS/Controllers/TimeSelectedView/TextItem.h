//
//  ListItem.h
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define RECT_HEIGHT            20.0

@interface TextItem : UIView {
    CGRect titleRect;
}

@property (nonatomic, retain) NSObject *objectTag;
@property (nonatomic, retain) NSString *title;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title color:(UIColor *)color size:(int)size;

@end
