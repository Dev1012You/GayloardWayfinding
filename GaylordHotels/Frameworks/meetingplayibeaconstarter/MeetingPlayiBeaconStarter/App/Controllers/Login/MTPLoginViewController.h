//
//  MTPLoginViewController.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"

@class MTPLoginClient, MTPCustomRootNavigationViewController;

@interface MTPLoginViewController : MTPBaseViewController

@property (nonatomic, weak) MTPCustomRootNavigationViewController *rootNavigationController;

@property (nonatomic, strong) MTPLoginClient *loginClient;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, copy) void (^failureBlock)(void);

- (IBAction)didPressLogin:(id)sender;
- (void)showLoginFailure:(NSError *)loginError;

@end
