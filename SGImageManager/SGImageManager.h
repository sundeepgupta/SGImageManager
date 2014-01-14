#import <Foundation/Foundation.h>
#import "SGFetchImageOperation.h"


@interface SGImageManager : NSObject
- (void)setupCacheCountLimit:(NSInteger)limit;
- (void)setupMaxConcurrentFetches:(NSInteger)maxConcurrentFetches;
- (void)fetchImageWithUrlString:(NSString *)urlString completionBlock:(SGFetchImageCompletionBlock)completionBlock;
@end
