
#import "CAD_NSString+UrlEncoding.h"

@implementation NSString (CAD_NSString_UrlEncoding)

-(NSString*)urlEncodedString{
    NSString* unEncodedString = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* encodedString = [unEncodedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return encodedString;
}

@end
