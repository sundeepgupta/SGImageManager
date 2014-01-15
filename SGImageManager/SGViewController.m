#import "SGViewController.h"
#import "SGCell.h"
#import "SGImageManager.h"


@interface SGViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *urlStrings;
@property (nonatomic, strong) SGImageManager *imageManager;
@end


@implementation SGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUrls];
    [self setupImageManager];
}

- (void)setupUrls {
    self.urlStrings = [NSArray arrayWithObjects:@"http://i.imgur.com/znnyB0u.jpg", @"http://i.imgur.com/M4Nzsvv.jpg", @"http://i.imgur.com/ffTU1Xn.jpg", @"http://i.imgur.com/aMmGy7H.jpg", @"http://i.imgur.com/NjSLp3a.jpg", @"http://i.imgur.com/v8tlJpk.jpg", @"http://i.imgur.com/VOLZ0c6.jpg", @"http://i.imgur.com/A9Cez50.jpg", @"http://i.imgur.com/smcFvBH.jpg", @"http://i.imgur.com/aTlzokV.jpg", @"http://i.imgur.com/oepSFKv.png", @"http://i.imgur.com/qRk6orr.jpg", @"http://i.imgur.com/MGL8JhE.jpg", @"http://i.imgur.com/cewbdoe.jpg", @"http://i.imgur.com/bn46nbU.jpg", @"http://i.imgur.com/jjtsk1S.png", @"http://i.imgur.com/rDWyklm.jpg", @"http://i.imgur.com/A9Cez50.jpg", @"http://i.imgur.com/eguoneJ.jpg", @"http://i.imgur.com/X8ho24P.jpg", nil];
}

- (void)setupImageManager {
    self.imageManager = [SGImageManager new];
}



#pragma mark - CollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.urlStrings.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SGCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SGCell class]) forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"placeholder"];
    NSString *imageUrlString = self.urlStrings[indexPath.item];
    cell.imageId = imageUrlString;
    SGFetchImageCompletionBlock completionBlock = ^(UIImage *image, NSString *urlString) {
        //Check the urlString against the cell's imageId in case the cell was re-used by the time the image was available.
        if ([cell.imageId isEqualToString:urlString]  &&  image) {
            cell.imageView.image = image;
        }
    };
    [self.imageManager fetchImageWithUrlString:imageUrlString completionBlock:completionBlock];
    
    return cell;
}


@end
