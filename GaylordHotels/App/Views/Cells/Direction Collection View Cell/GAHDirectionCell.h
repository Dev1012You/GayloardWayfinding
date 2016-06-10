//
//  GAHDirectionCell.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAHDirectionCell;

@protocol GAHDirectionCellDelegate <NSObject>
@optional
- (void)directionCell:(GAHDirectionCell *)directionCell didSelectLocation:(NSIndexPath *)cellIndex;
@end

@interface GAHDirectionCell : UICollectionViewCell

@property (nonatomic, weak) id <GAHDirectionCellDelegate> directionCellDelegate;
@property (nonatomic, strong) NSIndexPath *cellIndex;

@property (weak, nonatomic) IBOutlet UILabel *directionTextLabel;

@property (weak, nonatomic) IBOutlet UIView *stepNumberContainer;
@property (weak, nonatomic) IBOutlet UILabel *stepNumberLabel;

@property (weak, nonatomic) IBOutlet UIImageView *stepLocationImage;
@property (weak, nonatomic) IBOutlet UIScrollView *locationImageContainer;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLocationImageWidth;

@end
