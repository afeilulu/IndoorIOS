

#import <Foundation/Foundation.h>

@interface NSArray (CAD_NSArray_SafeValues)

- (NSString*)cad_safeStringAtIndex:(NSUInteger)index;
- (NSNumber*)cad_safeNumberAtIndex:(NSUInteger)index;
- (NSDictionary*)cad_safeDictionaryAtIndex:(NSUInteger)index;

@end
