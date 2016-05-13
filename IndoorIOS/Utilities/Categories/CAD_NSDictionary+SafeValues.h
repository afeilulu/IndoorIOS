
#import <UIKit/UIKit.h>

@interface NSDictionary (CAD_NSDictionary_SafeValues)

- (NSString*)cad_safeStringForKey:(id)key;
- (NSNumber*)cad_safeNumberForKey:(id)key;
- (NSArray*)cad_safeArrayForKey:(id)key;
- (NSDictionary*)cad_safeDictionaryForKey:(id)key;
- (UIImage*)cad_safeImageForKey:(id)key;

@end
