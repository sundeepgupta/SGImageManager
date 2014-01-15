#import "SGFetchImageOperation.h"

@implementation SGFetchImageOperation

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }
        
        UIImage *image = [self image];
        
        if (self.isCancelled) {
            return;
        }
        
        if(self.sgCompletionBlock  &&  self.urlString  && image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sgCompletionBlock(image, self.urlString);
            });
        }
    }
}

- (UIImage *)image{
    UIImage *image;
    if(self.urlString){
        NSURL *url = [NSURL URLWithString:self.urlString];
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedAlways error:&error];
        if (data) {
            image = [UIImage imageWithData:data];
        } else {
            NSLog(@"Error downloading image. %@", error.localizedDescription);
        }
    }
    return image;
}

@end
