#import <Foundation/Foundation.h>


typedef void(^SGFetchImageCompletionBlock)(UIImage *image, NSString *urlString);


@interface SGFetchImageOperation : NSOperation
@property (nonatomic, strong) NSString *urlString;
@property (copy) SGFetchImageCompletionBlock sgCompletionBlock;
@end
