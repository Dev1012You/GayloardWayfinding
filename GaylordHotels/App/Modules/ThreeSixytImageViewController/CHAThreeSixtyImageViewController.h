//
//  CHAThreeSixtyImageViewController.h
//  InfiniteScrollView
//
//  Created by John Pacheco on 10/22/15.
//  Copyright (c) 2015 Chisel Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHAThreeSixtyImageViewController;

@protocol CHAThreeSixtyImageDelegate <NSObject>
@optional
- (void)threeSixtyView:(CHAThreeSixtyImageViewController *)threeSixty didLoadImage:(UIImage *)fetchedImage imageURL:(NSURL *)imageURL;
- (void)threeSixtyView:(CHAThreeSixtyImageViewController *)threeSixty didUpdateImageDownloadProgress:(CGFloat)downloadProgress;
@end


@interface CHAThreeSixtyImageViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id <CHAThreeSixtyImageDelegate> threeSixtyDelegate;
@property (nonatomic, strong) UICollectionView *threeSixtyCollectionView;
@property (nonatomic, assign) BOOL infiniteScroll;

@property (nonatomic, strong) NSURL *currentImageURL;
@property (nonatomic, strong) UIImage *locationImage;

- (instancetype)initWithURL:(NSURL *)imageURL delegate:(id<CHAThreeSixtyImageDelegate>)delegate infiniteScroll:(BOOL)infiniteScroll;
- (void)fetchImage:(NSURL *)imageURL completionHandler:(void(^)(UIImage *))completionHandler;

@end
