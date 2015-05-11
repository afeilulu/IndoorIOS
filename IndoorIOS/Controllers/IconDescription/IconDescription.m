//
//  IconDescription.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/23.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IconDescription.h"

@implementation IconDescription

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    CALayer *roundCorner = [self layer];
    [roundCorner setMasksToBounds:YES];
    [roundCorner setCornerRadius:8.0];
    [roundCorner setBorderColor:[self tintColor].CGColor];
    [roundCorner setBorderWidth:1.0];
    
    if (self) {
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(50.0, 10.0, 30.0, 18.0)];
        CALayer *roundCorner = [imageView1 layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:2.0];
        [roundCorner setBackgroundColor:[UIColor colorWithWhite:235.0/256.0 alpha:1.0].CGColor];
        [self addSubview:imageView1];
        
        UILabel *titleLabel1 = [[UILabel alloc] init];
        [titleLabel1 setBackgroundColor:[UIColor clearColor]];
        [titleLabel1 setFont:[UIFont systemFontOfSize:16.0]];
        [titleLabel1 setOpaque: NO];
        [titleLabel1 setText:@"可选"];
        [titleLabel1 setTextColor:[UIColor grayColor]];
        [titleLabel1 setFrame:CGRectMake(85.0, 10, 40.0, 20.0)];
        [self addSubview:titleLabel1];

        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(130.0, 10.0, 30.0, 18.0)];
        roundCorner = [imageView2 layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:2.0];
        [roundCorner setBackgroundColor:[UIColor greenColor].CGColor];
        [self addSubview:imageView2];
        
        UILabel *titleLabel2 = [[UILabel alloc] init];
        [titleLabel2 setBackgroundColor:[UIColor clearColor]];
        [titleLabel2 setFont:[UIFont systemFontOfSize:16.0]];
        [titleLabel2 setOpaque: NO];
        [titleLabel2 setText:@"已选"];
        [titleLabel2 setTextColor:[UIColor grayColor]];
        [titleLabel2 setFrame:CGRectMake(165.0, 10, 40.0, 20.0)];
        [self addSubview:titleLabel2];
        
        UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(210.0, 10.0, 30.0, 18.0)];
        roundCorner = [imageView3 layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:2.0];
        [roundCorner setBackgroundColor:[UIColor redColor].CGColor];
        [self addSubview:imageView3];
        
        UILabel *titleLabel3 = [[UILabel alloc] init];
        [titleLabel3 setBackgroundColor:[UIColor clearColor]];
        [titleLabel3 setFont:[UIFont systemFontOfSize:16.0]];
        [titleLabel3 setOpaque: NO];
        [titleLabel3 setText:@"已售"];
        [titleLabel3 setTextColor:[UIColor grayColor]];
        [titleLabel3 setFrame:CGRectMake(245.0, 10, 40.0, 20.0)];
        [self addSubview:titleLabel3];
    }
    return self;
}


@end