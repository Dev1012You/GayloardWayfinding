//
//  MTPLandingViewController.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"

@protocol MTPChildViewControllerLoading <NSObject>
- (void)addViewControllerToStack:(UIViewController *)newChildViewController;
@end

@interface MTPLandingViewController : MTPBaseViewController <MTPChildViewControllerLoading>

@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (weak, nonatomic) IBOutlet UIView *menuContainerView;


@end
