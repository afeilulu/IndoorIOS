//
//  CADGillSansLabel.m
//  BigCentral
//
//

#import "CADGillSansLabel.h"
#import "UIFont+GillSansFonts.h"

@implementation CADGillSansLabel

- (void)resizeFontToFit{
    
    UIFont* font = self.font;
    
    CGSize constraintSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
    CGFloat minSize = self.minimumScaleFactor;
    CGFloat maxSize = self.font.pointSize;
    
    // start with maxSize and keep reducing until it doesn't clip
    for (int i = maxSize; i >= minSize; i--) {
        font = [font fontWithSize:i];
        
        // This step checks how tall the label would be with the desired font.
        CGRect labelRect = [self.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        if(labelRect.size.height <= self.frame.size.height)
            break;
    }
    // Set the font to the newly adjusted font.
    self.font = font;
    
}

@end


@interface CADGillSansBoldLabel ()

- (void)configureWithGillSansFont;

@end

@implementation CADGillSansBoldLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureWithGillSansFont];
    }
    return self;
}

- (void)setFontSize:(CGFloat)size {
    self.font = [UIFont gillSansBoldFontWithSize:size];
}

- (void)awakeFromNib{
    [self configureWithGillSansFont];
}

- (void)configureWithGillSansFont {
    self.font = [UIFont gillSansBoldFontWithSize:self.font.pointSize];
}

@end

@interface CADGillSansMediumLabel ()

- (void)configureWithGillSansFont;

@end

@implementation CADGillSansMediumLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureWithGillSansFont];
    }
    return self;
}

- (void)setFontSize:(CGFloat)size {
    self.font = [UIFont gillSansMediumFontWithSize:size];
}

- (void)awakeFromNib{
    [self configureWithGillSansFont];
}

- (void)configureWithGillSansFont {
    self.font = [UIFont gillSansMediumFontWithSize:self.font.pointSize];
}

@end

@implementation CADGillSansRegularLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureWithGillSansFont];
    }
    return self;
}

- (void)setFontSize:(CGFloat)size {
    self.font = [UIFont gillSansRegularFontWithSize:size];
}

- (void)awakeFromNib{
    [self configureWithGillSansFont];
}

- (void)configureWithGillSansFont {
    self.font = [UIFont gillSansRegularFontWithSize:self.font.pointSize];
}

@end

@implementation CADGillSansLightLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureWithGillSansFont];
    }
    return self;
}

- (void)setFontSize:(CGFloat)size {
    self.font = [UIFont gillSansLightFontWithSize:size];
}

- (void)awakeFromNib{
    [self configureWithGillSansFont];
}

- (void)configureWithGillSansFont {
    self.font = [UIFont gillSansLightFontWithSize:self.font.pointSize];
}

@end