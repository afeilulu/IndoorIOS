#import "TimeSelectedView.h"
#import "TextItem.h"
#import "StadiumManager.h"
#import "SportDayRule.h"

@implementation TimeSelectedView

- (id)initWithFrame:(CGRect)frame items:(NSMutableDictionary *)items dates:(NSMutableArray *) dates selectedSport:(int) selectedSport
{
    self = [super initWithFrame:frame];
    
    CALayer *roundCorner = [self layer];
    [roundCorner setMasksToBounds:YES];
    [roundCorner setCornerRadius:8.0];
    [roundCorner setBorderColor:[self tintColor].CGColor];
    [roundCorner setBorderWidth:1.0];
    
    int screen_width = [[UIScreen mainScreen] currentMode].size.width;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    int itemWidth = (screen_width/scale_screen - 20 ) / 3;
    
    self.totalPage = 1;
    
    int sum=0;
    if (self) {
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        CGSize pageSize = CGSizeMake(itemWidth, RECT_HEIGHT);
        NSUInteger pageOfDate = 0;
        NSUInteger page = 0;
        
        // init data
        self.textItemToShow =[[NSMutableDictionary alloc] init];
        for (NSString *dateitem in dates) {
            NSMutableArray *itemByIndex = [items objectForKey:dateitem];
            sum = sum + itemByIndex.count * 25;
            
            NSMutableArray *newItems = [self getStringArrayByIndex:itemByIndex];
            [self.textItemToShow setObject:newItems forKey:dateitem];
            self.totalPage = self.totalPage + (newItems.count-1)/2;
            
        }
//        NSLog(@"totalPage = %i",self.totalPage);
        
        // start to display
        for (NSString *dateitem in dates) {
            
            // show date
            NSString *titleString = [NSString stringWithFormat:@"%@月%@日",[dateitem substringWithRange:NSMakeRange(5, 2)],[dateitem substringWithRange:NSMakeRange(8, 2)]];
            TextItem *dateText = [[TextItem alloc] initWithFrame:CGRectZero title:titleString color:[self tintColor] size:16];
            [dateText setFrame:CGRectMake(0, (pageSize.height + DISTANCE_BETWEEN_TEXT_ITEMS) * page, pageSize.width, pageSize.height)];
            [self.scrollView addSubview:dateText];
            
            // show time text item
            NSMutableArray *newItems = [self.textItemToShow objectForKey:dateitem];
            int i;
            for (i=0; i<newItems.count; i++) {
                TextItem *timeText = [[TextItem alloc] initWithFrame:CGRectZero title:[newItems objectAtIndex:i] color:[UIColor grayColor] size:16];
                
                page = pageOfDate + i/2;
                int startX=0;
                if (i % 2 == 0)
                    startX = itemWidth + 10;
                else
                    startX = itemWidth * 2 + 15;
                
                [timeText setFrame:CGRectMake(startX, (pageSize.height + DISTANCE_BETWEEN_TEXT_ITEMS) * page, pageSize.width, pageSize.height)];
                [self.scrollView addSubview:timeText];
                
            }
            
            page++;
            pageOfDate = page;
        }
        
        // show total
        TextItem *sumLabel = [[TextItem alloc] initWithFrame:CGRectZero title:@"合计：" color:[UIColor grayColor] size:16];
        [sumLabel setFrame:CGRectMake(screen_width/scale_screen - 130, (pageSize.height + DISTANCE_BETWEEN_TEXT_ITEMS) * page, 40, 40)];
        [self.scrollView addSubview:sumLabel];
        
        TextItem *sumNumber = [[TextItem alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"￥%i",sum] color:[self tintColor] size:22];
        [sumNumber setFrame:CGRectMake(screen_width/scale_screen - 90, (pageSize.height + DISTANCE_BETWEEN_TEXT_ITEMS) * page, 40, 40)];
        [self.scrollView addSubview:sumNumber];
        
        
        self.scrollView.contentSize = CGSizeMake(screen_width/scale_screen - 4, RECT_HEIGHT * page + 100);
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self addSubview:self.scrollView];
    }

    return self;
}

/**
 * 获取显示日期列表
 */
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
