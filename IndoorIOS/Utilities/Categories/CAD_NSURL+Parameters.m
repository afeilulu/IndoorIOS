
#import "CAD_NSURL+Parameters.h"


@implementation NSURL (CAD_NSURL_Parameters)

+ (NSURL*)URLWithString:(NSString*)urlString additionalParameters:(NSString*)additionalParameters{
    
    NSURL* url = [NSURL URLWithString:urlString];

    BOOL alreadyHasParameters = url.query.length;
    if (alreadyHasParameters){
        urlString = [urlString stringByAppendingString:@"&"];
    } else {
        urlString = [urlString stringByAppendingString:@"?"];
    }

    urlString = [urlString stringByAppendingString:additionalParameters];

    return [NSURL URLWithString:urlString];
}


@end
