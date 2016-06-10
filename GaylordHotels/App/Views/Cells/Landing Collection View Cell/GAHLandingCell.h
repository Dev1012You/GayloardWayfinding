//
//  GAHLandingCell.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/6/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAHLandingCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *dimmingView;

@property (nonatomic, weak) IBOutlet UIImageView *bannerImage;
@property (nonatomic, weak) IBOutlet UILabel *landingItemTitle;
@property (nonatomic, weak) IBOutlet UILabel *iconLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;

- (void)loadImageForCategory:(NSString *)dataCategory;

@end


