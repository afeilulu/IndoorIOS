

#import "NSBundle+Loader.h"

@implementation NSBundle (Loader)

- (id)dataFromResource:(NSString *)resource {
    NSString *path = [self pathForResource:resource ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        @throw @"Could not load data.";
    }
    return data;
}

- (id)jsonFromResource:(NSString *)resource {
    NSData *jsonData = [self dataFromResource:resource];
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    if (!json) {
        @throw @"Could not load JSON.";
    }
    return json;
}

@end
