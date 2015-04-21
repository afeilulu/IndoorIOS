#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define DISTANCE_BETWEEN_TEXT_ITEMS  5.0

@interface TimeSelectedView : UIView <UIScrollViewDelegate> {
    CGFloat scale;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *textItemToShow;
@property (nonatomic) int totalPage;

//- (id)initWithFrame:(CGRect)frame items:(NSMutableArray *)items;

- (id)initWithFrame:(CGRect)frame items:(NSMutableDictionary *)items dates:(NSMutableArray *) dates selectedSport:(int) selectedSport;

- (NSMutableArray *)getStringArrayByIndex:(NSMutableArray *) sortedArray;

@end
