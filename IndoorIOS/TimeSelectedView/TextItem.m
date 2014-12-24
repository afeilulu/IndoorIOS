#import "TextItem.h"

@implementation TextItem

- (id)initWithFrame:(CGRect)frame title:(NSString *)title color:(UIColor *)color size:(int)size
{
    self = [super initWithFrame:frame];
    
    int screen_width = [[UIScreen mainScreen] currentMode].size.width;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    int itemWidth = (screen_width/scale_screen - 20 ) / 3;
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.title = title;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:size]];
        [titleLabel setOpaque: NO];
        [titleLabel setText:title];
        [titleLabel setTextColor:color];
        titleRect = CGRectMake(5, 5, itemWidth, RECT_HEIGHT);
        [titleLabel setFrame:titleRect];
        
//        [self addSubview:imageView];
        [self addSubview:titleLabel];
    }
    
    return self;
}

@end
