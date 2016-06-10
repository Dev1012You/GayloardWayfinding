//
//  MTPBaseViewController.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPViewControllerDataSource.h"

#import "UIViewController+MTPAppearanceHelpers.h"
#import "NSObject+EventDefaultsHelpers.h"

#import "EventKeys.h"

@interface MTPBaseViewController : UIViewController

@property (nonatomic, strong) MTPViewControllerDataSource *configurationDataSource;

/**
 @description Configure the view controller with the settings contained in the supplied object.<br><br>NOTE: Subclasses should override this method and provide their own implementations.
 @param controllerDataSource The configuration object for the view controller
 */
- (void)configureWithDataSource:(MTPViewControllerDataSource *)controllerDataSource;

@end
