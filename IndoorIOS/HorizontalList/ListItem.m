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
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:20.0]];
        [titleLabel setOpaque: NO];
        [titleLabel setText:title];
        [titleLabel setTextColor:[self tintColor]];
        titleRect = CGRectMake(10.0, imageRect.origin.y + 10.0, 80.0, 20.0);
        [titleLabel setFrame:titleRect];
        
        UILabel *subTitleLabel = [[UILabel alloc] init];
        [subTitleLabel setBackgroundColor:[UIColor clearColor]];
        [subTitleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [subTitleLabel setOpaque: NO];
        [subTitleLabel setText:subTitle];
        [subTitleLabel setTextColor:[self tintColor]];
        subTitleRect = CGRectMake(20.0, imageRect.origin.y + 40.0, 80.0, 20.0);
        [subTitleLabel setFrame:subTitleRect];
        
        [self addSubview:self.imageView];
        [self addSubview:titleLabel];
        [self addSubview:subTitleLabel];
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
