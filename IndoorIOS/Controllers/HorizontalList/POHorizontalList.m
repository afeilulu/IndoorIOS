//
//  POHorizontalList.m
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import "POHorizontalList.h"

@implementation POHorizontalList

- (id)initWithFrame:(CGRect)frame items:(NSMutableArray *)items
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, TITLE_HEIGHT, self.frame.size.width, self.frame.size.height)];

        CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.scrollView.frame.size.height);
        NSUInteger page = 0;
        
        for(ListItem *item in items) {
            [item setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, 0, pageSize.width, pageSize.height)];
            
            UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
            [item addGestureRecognizer:singleFingerTap];

            [self.scrollView addSubview:item];
        }
        
        self.scrollView.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * [items count] + RIGHT_PADDING, pageSize.height);
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [self addSubview:self.scrollView];
        
        // Background shadow
        CAGradientLayer *dropshadowLayer = [CAGradientLayer layer];
        dropshadowLayer.contentsScale = scale;
        dropshadowLayer.startPoint = CGPointMake(0.0f, 0.0f);
        dropshadowLayer.endPoint = CGPointMake(0.0f, 1.0f);
        dropshadowLayer.opacity = 1.0;
        dropshadowLayer.frame = CGRectMake(1.0f, 1.0f, self.frame.size.width - 2.0, self.frame.size.height - 2.0);
        dropshadowLayer.locations = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.0f],
                                     [NSNumber numberWithFloat:1.0f], nil];
         dropshadowLayer.colors = [NSArray arrayWithObjects:
                                   (id)[[UIColor colorWithWhite:224.0/256.0 alpha:1.0] CGColor],
                                   (id)[[UIColor colorWithWhite:235.0/256.0 alpha:1.0] CGColor], nil];
         
//         [self.layer insertSublayer:dropshadowLayer below:self.scrollView.layer];

    }

    return self;
}

- (void)itemTapped:(UITapGestureRecognizer *)recognizer {
    ListItem *item = (ListItem *)recognizer.view;
    
    for (id viewItem in self.scrollView.subviews) {
        ListItem *listItem = (ListItem *)viewItem;
        if (listItem.isSelected)
            [listItem setDeSelected];
        
        if (listItem == item && !item.isSelected)
            [item setSelected];
    }

    if (item != nil) {
        [self.delegate didSelectItem:item];
    }
}

- (void)setItemSelectedAtIndex:(int) index
{
    for (id viewItem in self.scrollView.subviews) {
        ListItem *listItem = (ListItem *)viewItem;
        if (listItem.isSelected)
            [listItem setDeSelected];
    }
    
    ListItem *item = (ListItem *)self.scrollView.subviews[index];
    [item setSelected];
    
    // scroll to visible
    int scrollTo = index * 110;
    CGRect frame = CGRectMake(scrollTo, 0, 82, 82); //wherever you want to scroll
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    if (item != nil) {
        [self.delegate didSelectItem:item];
    }
}

@end
