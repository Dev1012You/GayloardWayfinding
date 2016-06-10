//
//  GAHDirectionDetailViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 6/11/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHAThreeSixtyImageViewController;

@interface GAHDirectionDetailViewController : UIViewController

@property (nonatomic, strong) CHAThreeSixtyImageViewController *threeSixtyImageViewController;
@property (nonatomic, assign) BOOL infiniteScroll;

@property (nonatomic, strong) NSURL *imageURL;

- (void)configureThreeSixtyViewImageURL:(NSURL *)imageURL parentView:(UIView *)parentView infiniteScroll:(BOOL)infiniteScroll;

@end
