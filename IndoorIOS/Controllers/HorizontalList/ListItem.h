//
//  ListItem.h
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define ITEM_WIDTH              72.0
#define ITEM_HEIGHT              72.0

@interface ListItem : UIView {
    CGRect textRect;
    CGRect imageRect;
    
    CGRect titleRect;
    CGRect subTitleRect;
}

@property (nonatomic, retain) NSObject *objectTag;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subTitleLabel;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic) BOOL isSelected;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title subTitle:(NSString *)subTitle;

- (void)setSelected;

- (void)setDeSelected;

@end
