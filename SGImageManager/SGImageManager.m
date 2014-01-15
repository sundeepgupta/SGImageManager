#import "SGImageManager.h"


#define kDefaultMaxConcurrentFetches 5
#define kDefaultCacheCountLimit 30


@interface SGImageManager ()
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) NSOperationQueue *queue;
@end


@implementation SGImageManager

#pragma mark - Setup
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupCache];
        [self setupQueue];
    }
    return self;
}

- (void)setupCache {
    self.cache = [NSCache new];
    [self setupCacheCountLimit:kDefaultCacheCountLimit];
}
- (void)setupCacheCountLimit:(NSInteger)limit {
    self.cache.countLimit = limit;
}

- (void)setupQueue {
    self.queue = [NSOperationQueue new];
    [self setupMaxConcurrentFetches:kDefaultMaxConcurrentFetches];
}
- (void)setupMaxConcurrentFetches:(NSInteger)maxConcurrentFetches {
    self.queue.maxConcurrentOperationCount = maxConcurrentFetches;
}



#pragma mark - Fetching
- (void)fetchImageWithUrlString:(NSString *)urlString completionBlock:(SGFetchImageCompletionBlock)completionBlock {
    if([self.cache objectForKey:urlString]) {
        [self fetchCachedImageWithUrlString:urlString completionBlock:completionBlock];
    } else {
        [self fetchNonCachedImageWithUrlString:urlString completionBlock:completionBlock];
    }
}

- (void)fetchCachedImageWithUrlString:(NSString *)urlString completionBlock:(SGFetchImageCompletionBlock)completionBlock {
    UIImage *image = [self.cache objectForKey:urlString];
    if (image) {
        completionBlock(image, urlString);
    }
}

- (void)fetchNonCachedImageWithUrlString:(NSString *)urlString completionBlock:(SGFetchImageCompletionBlock)completionBlock {
    if([self isLocalUrl:urlString]) {
        [self fetchLocalImageWithUrlString:urlString completionBlock:completionBlock];
    } else {
        [self fetchRemoteImageWithUrlString:urlString completionBlock:completionBlock];
    }
}


//move this into the operation if need to handle queues.  This is done if a file read occurs (which I assume would block UI).
- (void)fetchLocalImageWithUrlString:(NSString *)urlString completionBlock:(SGFetchImageCompletionBlock)completionBlock {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        UIImage *image = [UIImage imageWithContentsOfFile:urlString];
        if (image) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                completionBlock(image, urlString);
            });
            [self cacheImage:image forUrlString:urlString];
        }
    });
}

- (void)fetchRemoteImageWithUrlString:(NSString *)urlString completionBlock:(SGFetchImageCompletionBlock)completionBlock {
    if (![self isFetchingImageForUrlString:urlString]) {
        SGFetchImageOperation *operation = [self operationForUrlString:urlString completionBlock:completionBlock];
        [self.queue addOperation:operation];
    }
}

- (SGFetchImageOperation *)operationForUrlString:(NSString *)urlString completionBlock:(SGFetchImageCompletionBlock)completionBlock {
    SGFetchImageOperation *operation = [SGFetchImageOperation new];
    operation.urlString = urlString;
    operation.sgCompletionBlock = ^(UIImage *operationImage, NSString *operationUrlString){
        completionBlock(operationImage, operationUrlString);
        [self cacheImage:operationImage forUrlString:operationUrlString];
    };
    return operation;
}




#pragma mark - Helpers
- (BOOL)isLocalUrl:(NSString *)imageUrl {
    return ![self isRemoteUrl:imageUrl];
}
- (BOOL)isRemoteUrl:(NSString *)imageUrl {
    BOOL isRemoteUrl = NO;
    char firstCharacter = [imageUrl characterAtIndex:0];
    if((firstCharacter == 'h' || firstCharacter == 'H')) {
        isRemoteUrl = YES;
    }
    return isRemoteUrl;
}

- (BOOL)isFetchingImageForUrlString:(NSString *)urlString {
    BOOL isFetching = NO;
    NSArray *operations = self.queue.operations;
    for (SGFetchImageOperation *operation in operations) {
        if ([operation.urlString isEqualToString:urlString]) {
            isFetching = YES;
            break;
        }
    }
    return isFetching;
}
                                  
- (void)cacheImage:(UIImage *)image forUrlString:(NSString *)urlString {
    @synchronized(self) {
        if (image  &&  urlString) {
            [self.cache setObject:image forKey:urlString];
        }
    }
}

//Borrowed from: http://stackoverflow.com/questions/4147311/finding-image-type-from-nsdata-or-uiimage
+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

@end
