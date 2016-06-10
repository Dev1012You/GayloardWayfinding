//
//  CHAThreeSixtyImageViewController.m
//  InfiniteScrollView
//
//  Created by John Pacheco on 10/22/15.
//  Copyright (c) 2015 Chisel Apps. All rights reserved.
//

#import "CHAThreeSixtyImageViewController.h"
#import "CHAThreeSixtyCell.h"

#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

#import "UIView+AutoLayoutHelper.h"
#import "MBProgressHUD.h"

@interface CHAThreeSixtyImageViewController ()
@property (nonatomic, strong) UIImage *secondImage;
@end

@implementation CHAThreeSixtyImageViewController

- (instancetype)initWithURL:(NSURL *)imageURL delegate:(id<CHAThreeSixtyImageDelegate>)delegate infiniteScroll:(BOOL)infiniteScroll
{
    self = [[CHAThreeSixtyImageViewController alloc] init];
    if (self)
    {
        _currentImageURL = imageURL;
        _threeSixtyDelegate = delegate;
        _infiniteScroll = infiniteScroll;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    [self fetchImage:self.currentImageURL completionHandler:nil];
    self.threeSixtyCollectionView = [self configureThreeSixtyCollectionView:self.view dataSource:self flowDelegate:self];
}

- (void)fetchImage:(NSURL *)imageURL completionHandler:(void(^)(UIImage *))completionHandler
{
    __weak __typeof(&*self)weakSelf = self;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageURL
                                                          options:0
                                                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
    {
        if (expectedSize > 0)
        {
            if (self.threeSixtyDelegate && [self.threeSixtyDelegate respondsToSelector:@selector(threeSixtyView:didUpdateImageDownloadProgress:)])
            {
                CGFloat progress = (receivedSize/(CGFloat)expectedSize);
                [self.threeSixtyDelegate threeSixtyView:self didUpdateImageDownloadProgress:progress];
            }
        }
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        weakSelf.locationImage = image;
        weakSelf.secondImage = image;
        

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.threeSixtyCollectionView reloadData];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf scrollToCenter:weakSelf.threeSixtyCollectionView];
        });
        
        if (weakSelf.threeSixtyDelegate && [weakSelf.threeSixtyDelegate respondsToSelector:@selector(threeSixtyView:didLoadImage:imageURL:)])
        {
            [weakSelf.threeSixtyDelegate threeSixtyView:weakSelf didLoadImage:image imageURL:imageURL];
        }
        
        if (completionHandler)
        {
            completionHandler(image);
        }
    }];
}

- (void)scrollToCenter:(UICollectionView *)collectionView
{
    [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self targetIndexPath:collectionView]
                                                                inSection:0]
                           atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                   animated:false];
}

- (NSInteger)targetIndexPath:(UICollectionView *)collectionView
{
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:0];
    NSInteger targetIndexPath = (numberOfItems <= 1) ? 0 : numberOfItems/2;
    
    return targetIndexPath;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (UICollectionView *)configureThreeSixtyCollectionView:(UIView *)parentView
                                             dataSource:(id<UICollectionViewDataSource>)dataSource
                                           flowDelegate:(id<UICollectionViewDelegateFlowLayout>)flowDelegate
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    UICollectionView *threeSixtyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    threeSixtyCollectionView.translatesAutoresizingMaskIntoConstraints = false;

    threeSixtyCollectionView.dataSource = dataSource;
    threeSixtyCollectionView.delegate = flowDelegate;
    
    [threeSixtyCollectionView registerNib:[UINib nibWithNibName:@"CHAThreeSixtyCell" bundle:nil]
               forCellWithReuseIdentifier:[CHAThreeSixtyCell cellIdentifier]];
    
    [parentView addSubview:threeSixtyCollectionView];
    [parentView addConstraints:[threeSixtyCollectionView pinToSuperviewBounds]];
    
    return threeSixtyCollectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.locationImage == nil ? 0 : (self.infiniteScroll ? 20 : 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHAThreeSixtyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CHAThreeSixtyCell cellIdentifier] forIndexPath:indexPath];
    [cell.threeSixtyImageView setImage:self.locationImage];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat collectionViewHeight = CGRectGetHeight(collectionView.frame);
    CGFloat widthForImageCell = collectionViewHeight * (self.locationImage.size.width / MAX(1,self.locationImage.size.height));
    
    if (collectionViewHeight < 1)
    {
        collectionViewHeight = 1;
    }
    
    if (widthForImageCell < 1)
    {
        widthForImageCell = 1;
    }
    
    return CGSizeMake(widthForImageCell, collectionViewHeight);
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscape;
}


@end