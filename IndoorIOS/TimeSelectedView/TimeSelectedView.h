#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define DISTANCE_BETWEEN_ITEMS  15.0
#define LEFT_PADDING            15.0
#define RIGHT_PADDING            80.0
#define ITEM_WIDTH              72.0
#define TITLE_HEIGHT            5.0

@interface TimeSelectedView : UIView <UIScrollViewDelegate> {
    CGFloat scale;
}

@property (nonatomic, retain) UIScrollView *scrollView;

//- (id)initWithFrame:(CGRect)frame items:(NSMutableArray *)items;

- (id)initWithFrame:(CGRect)frame items:(NSMutableDictionary *)items dates:(NSMutableArray *) dates;

- (NSMutableArray *)getStringArrayByIndex:(NSMutableArray *) sortedArray;
@end
