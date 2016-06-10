//
//  GAHMeetingLoginViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 6/12/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHMeetingLoginViewController.h"
#import "GAHGeneralInfoViewController.h"
#import "UIView+AutoLayoutHelper.h"

@interface GAHMeetingLoginViewController () <UITextFieldDelegate>

@end

@implementation GAHMeetingLoginViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupHeaderView];
    [self setupContentView];
    [self setupConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MyriadPro-Bold" size:13.f],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationItem setTitle:@"MEETINGS AND EVENTS"];

}

#pragma mark - Protocol Conformance
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

#pragma mark - IBActions
- (IBAction)pressedLogin:(id)sender
{
    if (self.termsSwitch.on)
    {
        GAHGeneralInfoViewController *generalInfo = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GAHGeneralInfoViewController"];
        generalInfo.generalInfoURL = @"http://deploy.meetingplay.com/gaylord/events/";
        generalInfo.pageTitle = @"MY EVENTS";
        generalInfo.showToggleMenu = false;
        [self.navigationController pushViewController:generalInfo animated:true];
    }
    else
    {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionAutoreverse
                         animations:^{
            self.termsSwitch.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            self.termsSwitch.transform = CGAffineTransformIdentity;
        }];
    }
}

- (IBAction)pressedShowTerms:(id)sender
{
    
}

#pragma mark - Helper Methods
#pragma mark - Initial Setup
- (void)setupHeaderView
{
    if (self.headerBackground == nil)
    {
        self.headerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"meetingLoginHeaderBackground"]];
        self.headerBackground.translatesAutoresizingMaskIntoConstraints = false;
        [self.headerContainer addSubview:self.headerBackground];
    }
    
    self.headerLabel.font = [UIFont fontWithName:@"MyriadPro-Bold" size:21.f];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.textColor = [UIColor whiteColor];
    self.headerLabel.numberOfLines = 0;
    
    NSMutableParagraphStyle *headerStyle = [[NSMutableParagraphStyle alloc] init];
    headerStyle.lineSpacing = 2.f;
    headerStyle.alignment = NSTextAlignmentCenter;
    
    self.headerLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Please Login to Your Meeting or Event Below".uppercaseString attributes:@{NSParagraphStyleAttributeName: headerStyle}];;
    
    [self.headerContainer bringSubviewToFront:self.headerLabel];
    
    self.headerContainer.clipsToBounds = false;
    
    self.headerBackground.layer.shadowColor = [UIColor blackColor].CGColor;
    self.headerBackground.layer.shadowOffset = CGSizeMake(0, 1);
    self.headerBackground.layer.shadowOpacity = 0.4f;
    self.headerBackground.layer.shadowRadius = 1.f;
}

- (void)setupContentView
{
    self.loginBackground.layer.shadowColor = [UIColor blackColor].CGColor;
    self.loginBackground.layer.shadowOffset = CGSizeMake(0, 1);
    self.loginBackground.layer.shadowOpacity = 0.4f;
    self.loginBackground.layer.shadowRadius = 1.f;
    
    self.emailTextField.delegate = self;
    
    [self.loginButton addTarget:self
                         action:@selector(pressedLogin:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.showTermsButton addTarget:self
                             action:@selector(pressedShowTerms:)
                   forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    [self.headerContainer.superview addConstraint:[self.headerContainer height:(CGRectGetHeight(self.view.frame) * 0.2f)]];
    [self.headerContainer.superview addConstraints:[self.headerContainer pinSides:@[@(NSLayoutAttributeTop),
                                                                                    @(NSLayoutAttributeLeading),
                                                                                    @(NSLayoutAttributeTrailing)]
                                                                         constant:0]];
    
    [self.contentContainer.superview addConstraint:[self.contentContainer pinSide:NSLayoutAttributeTop
                                                                           toView:self.headerContainer
                                                                   secondViewSide:NSLayoutAttributeBottom]];
    
    [self.contentContainer.superview addConstraints:[self.contentContainer pinLeadingTrailing]];
    [self.contentContainer.superview addConstraint:[self.contentContainer pinToBottomSuperview]];
    
    [self.headerBackground.superview addConstraints:[self.headerBackground pinToSuperviewBounds]];
    [self.headerLabel.superview addConstraints:@[[self.headerLabel pinToTopSuperview],
                                                 [self.headerLabel pinToBottomSuperview]]];
    [self.headerLabel.superview addConstraints:[self.headerLabel pinLeadingTrailing:20.f]];
}

@end
