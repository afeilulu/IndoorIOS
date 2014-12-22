#import "TimeSelectedView.h"

@implementation TimeSelectedView

- (id)initWithFrame:(CGRect)frame items:(NSMutableDictionary *)items dates:(NSMutableArray *) dates
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.scrollView.frame.size.height);
        NSUInteger page = 0;
        
        for (NSString *dateitem in dates) {
            NSMutableArray *itemValue = [items objectForKey:dateitem];
            
            NSMutableArray *stringForDisplay =  [self getStringArrayByIndex:itemValue];
            for (NSString *item in stringForDisplay) {
                NSLog(@"%@",item);
            }
        }
        
        /*
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
         
         */

    }

    return self;
}

- (NSMutableArray *)getStringArrayByIndex:(NSMutableArray *) sortedArray
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    int lastNumber = -100;
    NSMutableString *oneString;
    int count = [sortedArray count];
    for (int i = 0; i<count; i++) {
        int intValue = ((NSNumber *)[sortedArray objectAtIndex:i]).intValue;
        if (sortedArray.count == 1){
            oneString = [[NSMutableString alloc] init];
            [oneString appendString:[NSString stringWithFormat:@"%i:%@-%i:%@", intValue / 2, intValue % 2 == 0?@"00":@"30",(intValue + 1) / 2, (intValue + 1) % 2 == 0?@"00":@"30"]];
            
            [result addObject:oneString];
            oneString = nil;
        } else {
            if (lastNumber != intValue - 1){
                // complete last item
                if (oneString != nil){
                    [oneString appendString:[NSString stringWithFormat:@"%i:%@", (lastNumber+1) / 2, (lastNumber + 1) % 2 == 0?@"00":@"30"]];
                    [result addObject:oneString];
                    oneString = nil;
                    
                    // handle new oneString
                    oneString = [[NSMutableString alloc] init];
                    [oneString appendString:[NSString stringWithFormat:@"%i:%@-", intValue / 2, intValue % 2 == 0?@"00":@"30"]];
                    
                    if (i == count - 1){
                        [oneString appendString:[NSString stringWithFormat:@"%i:%@", (intValue + 1) / 2, (intValue + 1) % 2 == 0?@"00":@"30"]];
                        [result addObject:oneString];
                        oneString = nil;
                    }
                } else {
                    // handle new oneString
                    oneString = [[NSMutableString alloc] init];
                    [oneString appendString:[NSString stringWithFormat:@"%i:%@-", intValue / 2, intValue % 2 == 0?@"00":@"30"]];
                }
            } else {
                if (i == count - 1){
                    [oneString appendString:[NSString stringWithFormat:@"%i:%@", (intValue + 1) / 2, (intValue + 1) % 2 == 0?@"00":@"30"]];
                    [result addObject:oneString];
                    oneString = nil;
                }
            }
        }
        
        lastNumber = intValue;
    }
    
    return result;
}

@end
