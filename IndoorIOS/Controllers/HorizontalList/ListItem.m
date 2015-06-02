//
//  ListItem.m
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import "ListItem.h"

@implementation ListItem

//- (id)initWithFrame:(CGRect)frame image:(UIImage *)image text:(NSString *)imageTitle
- (id)initWithFrame:(CGRect)frame title:(NSString *)title subTitle:(NSString *)subTitle;
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.isSelected = NO;
        self.title = title;
        self.subTitle = subTitle;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 72.0, 72.0)];

        CALayer *roundCorner = [self.imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:8.0];
        [roundCorner setBorderColor:[self tintColor].CGColor];
        [roundCorner setBorderWidth:1.0];
        [roundCorner setBackgroundColor:[UIColor clearColor].CGColor];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:22.0]];
        [_titleLabel setOpaque: NO];
        [_titleLabel setText:title];
        [_titleLabel setTextColor:[self tintColor]];
        titleRect = CGRectMake(20.0, imageRect.origin.y + 10.0, 80.0, 20.0);
        [_titleLabel setFrame:titleRect];
        
        _subTitleLabel = [[UILabel alloc] init];
        [_subTitleLabel setBackgroundColor:[UIColor clearColor]];
        [_subTitleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [_subTitleLabel setOpaque: NO];
        [_subTitleLabel setText:subTitle];
        [_subTitleLabel setTextColor:[self tintColor]];
        subTitleRect = CGRectMake(20.0, imageRect.origin.y + 40.0, 80.0, 20.0);
        [_subTitleLabel setFrame:subTitleRect];
        
        [self addSubview:self.imageView];
        [self addSubview:_titleLabel];
        [self addSubview:_subTitleLabel];
    }
    
    return self;
}

- (void)setSelected{
    self.isSelected = YES;
    CALayer *roundCorner = [self.imageView layer];
    [roundCorner setBackgroundColor:[[UIColor colorWithWhite:235.0/256.0 alpha:1.0] CGColor]];
}

- (void)setDeSelected{
    self.isSelected = NO;
    CALayer *roundCorner = [self.imageView layer];
    [roundCorner setBackgroundColor:[UIColor clearColor].CGColor];
}

@end
