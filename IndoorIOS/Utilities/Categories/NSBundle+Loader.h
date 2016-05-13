
#import <Foundation/Foundation.h>

@interface NSBundle (Loader)

- (id)dataFromResource:(NSString *)resource;
- (id)jsonFromResource:(NSString *)resource;

@end
