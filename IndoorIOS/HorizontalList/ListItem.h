//
//  ListItem.h
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ListItem : UIView {
    CGRect textRect;
    CGRect imageRect;
    
    CGRect titleRect;
    CGRect subTitleRect;
}

@property (nonatomic, retain) NSObject *objectTag;

@property (nonatomic, retain) NSString *imageTitle;
@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title subTitle:(NSString *)subTitle;

@end
