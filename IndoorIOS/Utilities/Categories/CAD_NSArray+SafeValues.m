

#import "CAD_NSArray+SafeValues.h"

@implementation NSArray (CAD_NSArray_SafeValues)

- (NSString*)cad_safeStringAtIndex:(NSUInteger)index {
    NSString* string = nil;
    
    if (index < self.count){
        id obj = [self objectAtIndex:index];
        if ([obj isKindOfClass:[NSString class]]){
            string = obj;
        }
    }
    
    if (!string) {
        string = @"";
    }
    return string;
}

- (NSNumber*)cad_safeNumberAtIndex:(NSUInteger)index {
    NSNumber* number = nil;
    
    if (index < self.count){
        id obj = [self objectAtIndex:index];
        if ([obj isKindOfClass:[NSNumber class]]){
            number = obj;
        }
    }
    
    if (!number) {
        number = [NSNumber numberWithInt:0];
    }
    return number;
}


- (NSDictionary*)cad_safeDictionaryAtIndex:(NSUInteger)index {
    NSDictionary* dictionary = nil;
    
    if (index < self.count){
        id obj = [self objectAtIndex:index];
        if ([obj isKindOfClass:[NSDictionary class]]){
            dictionary = obj;
        }
    }
    
    if (!dictionary) {
        dictionary = [NSDictionary dictionary];
    }
    return dictionary;
}

@end
