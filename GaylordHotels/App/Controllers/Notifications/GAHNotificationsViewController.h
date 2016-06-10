//
//  GAHNotificationsViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 6/25/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseHeaderStyleViewController.h"

@interface GAHNotificationsViewController : GAHBaseHeaderStyleViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *notificationsCollectionView;

@end

@interface GAHNotificationsCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIView *dotMarker;
@property (weak, nonatomic) IBOutlet UIView *finalDotMarker;

@property (nonatomic, strong) UIBezierPath *circlePath;

@property (nonatomic, weak) IBOutlet UIImageView *headerBackground;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UITextView *messageBodyTextView;
@property (nonatomic, weak) IBOutlet UILabel *messageBodyLabel;


@end