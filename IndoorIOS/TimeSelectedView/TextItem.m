#import "TextItem.h"

@implementation TextItem

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.title = title;
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 72.0, 72.0)];
//
//        CALayer *roundCorner = [imageView layer];
//        [roundCorner setMasksToBounds:YES];
//        [roundCorner setCornerRadius:8.0];
//        [roundCorner setBorderColor:[self tintColor].CGColor];
//        [roundCorner setBorderWidth:1.0];
//        [roundCorner setBackgroundColor:[UIColor clearColor].CGColor];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:20.0]];
        [titleLabel setOpaque: NO];
        [titleLabel setText:title];
        [titleLabel setTextColor:[self tintColor]];
        titleRect = CGRectMake(5, 5, 80.0, 20.0);
        [titleLabel setFrame:titleRect];
        
//        [self addSubview:imageView];
        [self addSubview:titleLabel];
    }
    
    return self;
}

@end
