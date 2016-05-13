

#import "UIFont+GillSansFonts.h"

@implementation UIFont (RotoboFonts)

+ (UIFont*)gillSansBoldFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"GillSans-Bold" size:fontSize];
}

+ (UIFont*)gillSansMediumFontWithSize:(CGFloat)fontSize
{
    return  [UIFont fontWithName:@"GillSans-Medium" size:fontSize];
}

+ (UIFont*)gillSansRegularFontWithSize:(CGFloat)fontSize
{
    return  [UIFont fontWithName:@"GillSans-Regular" size:fontSize];
}

+ (UIFont*)gillSansLightFontWithSize:(CGFloat)fontSize;
{
    return  [UIFont fontWithName:@"GillSans-Light" size:fontSize];
}

@end
