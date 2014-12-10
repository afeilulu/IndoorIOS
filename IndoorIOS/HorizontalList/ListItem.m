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
        
        self.title = title;
        self.subTitle = subTitle;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 72.0, 72.0)];

        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:8.0];
        [roundCorner setBorderColor:[UIColor blackColor].CGColor];
        [roundCorner setBorderWidth:1.0];
        [roundCorner setBackgroundColor:[UIColor orangeColor].CGColor];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
        [titleLabel setOpaque: NO];
        [titleLabel setText:title];
        titleRect = CGRectMake(10.0, imageRect.origin.y + 10.0, 80.0, 20.0);
        [titleLabel setFrame:titleRect];
        
        UILabel *subTitleLabel = [[UILabel alloc] init];
        [subTitleLabel setBackgroundColor:[UIColor clearColor]];
        [subTitleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [subTitleLabel setOpaque: NO];
        [subTitleLabel setText:subTitle];
        subTitleRect = CGRectMake(20.0, imageRect.origin.y + 40.0, 80.0, 20.0);
        [subTitleLabel setFrame:subTitleRect];
        
        [self addSubview:imageView];
        [self addSubview:titleLabel];
        [self addSubview:subTitleLabel];
    }
    
    return self;
}

@end
