//
//  GAHMeetingsLandingViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/28/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHMeetingsLandingViewController.h"
#import "GAHMeetingLoginViewController.h"
#import "GAHGeneralInfoViewController.h"
#import "UIView+AutoLayoutHelper.h"
#import "UIButton+MTPNavigationBar.h"
#import "UIButton+GAHCustomButtons.h"
#import "MBProgressHUD.h"

@interface GAHMeetingsLandingViewController () <UIWebViewDelegate>

@end

@implementation GAHMeetingsLandingViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupHeaderView];
    [self setupContentView];
    
    [self setupConstraints];
    
    [self.view sendSubviewToBack:self.mainMenuContainer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:false];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MyriadPro-Bold" size:13.f],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationItem setTitle:@"MEETINGS AND EVENTS"];
}

#pragma mark - Protocol Conformance
#pragma mark - IBActions
- (IBAction)pressedAttendee:(id)sender
{
    GAHMeetingLoginViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"GAHMeetingLoginViewController"];
    [self.navigationController pushViewController:login animated:true];
}

- (IBAction)pressedInquire:(id)sender
{
    GAHGeneralInfoViewController *generalInfo = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GAHGeneralInfoViewController"];
    generalInfo.generalInfoURL = @"http://www.marriott.com/meetings/group-travel/schedule-groupBooking.mi?marshaCode=wasgn&directRFP=true&RFPmvtON=true";
    generalInfo.pageTitle = @"INQUIRE ABOUT MEETINGS";
    generalInfo.showToggleMenu = false;
    [self.navigationController pushViewController:generalInfo animated:true];
}

#pragma mark - Helper Methods
#pragma mark Web View Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self toggleProgressHUDVisiblity:true];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)toggleProgressHUDVisiblity:(BOOL)visible
{
    if (self.meetingInfoWebView)
    {
        if (visible)
        {
            [MBProgressHUD showHUDAddedTo:self.meetingInfoWebView animated:true];
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.meetingInfoWebView animated:true];
        }
    }
    else
    {
        NSLog(@"%s\n[%s]: Line %i] %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
              @"no feedback container found");
    }
}
#pragma mark - Initial Setup
- (void)setupHeaderView
{
    self.headerContainer.backgroundColor = [UIColor redColor];
    self.headerContainer.translatesAutoresizingMaskIntoConstraints = false;

    if (self.headerBackground == nil)
    {
        self.headerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"meetingHeaderBackground"]];
        self.headerBackground.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    UIFont *buttonFont = [UIFont fontWithName:@"MyriadPro-Bold" size:14.f];
    
    UIButton *attendeeAccessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    attendeeAccessButton.translatesAutoresizingMaskIntoConstraints = false;
    attendeeAccessButton.backgroundColor = UIColorFromRGB(0x002c77);
    attendeeAccessButton.titleLabel.font = buttonFont;
    [attendeeAccessButton setTitle:@"I'M HERE FOR A MEETING" forState:UIControlStateNormal];
    [attendeeAccessButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [attendeeAccessButton addTarget:self action:@selector(pressedAttendee:) forControlEvents:UIControlEventTouchUpInside];
    attendeeAccessButton.lineBreakMode = NSLineBreakByClipping;
    self.attendeeAccessButton = attendeeAccessButton;
    
    self.attendeeAccessButton.hidden = true;
    
    UIButton *meetingInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    meetingInfoButton.translatesAutoresizingMaskIntoConstraints = false;
    meetingInfoButton.backgroundColor = UIColorFromRGB(0x82786f);
    meetingInfoButton.titleLabel.font = buttonFont;
    [meetingInfoButton setTitle:@"INQUIRE ABOUT MEETINGS" forState:UIControlStateNormal];
    [meetingInfoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [meetingInfoButton addTarget:self action:@selector(pressedInquire:) forControlEvents:UIControlEventTouchUpInside];
    meetingInfoButton.lineBreakMode = NSLineBreakByClipping;
    self.meetingInformationButton = meetingInfoButton;
    
    [self.headerContainer addSubview:self.headerBackground];
    [self.headerContainer addSubview:self.attendeeAccessButton];
    [self.headerContainer addSubview:self.meetingInformationButton];
}

- (void)setupContentView
{
    self.contentContainer.backgroundColor = [UIColor orangeColor];
    self.contentContainer.translatesAutoresizingMaskIntoConstraints = false;
    
    if (self.meetingInfoWebView == nil)
    {
        self.meetingInfoWebView = [UIWebView new];
        self.meetingInfoWebView.translatesAutoresizingMaskIntoConstraints = false;
        self.meetingInfoWebView.delegate = self;
        [self.meetingInfoWebView loadRequest:[NSURLRequest requestWithURL:
                                              [NSURL URLWithString:@"http://deploy.meetingplay.com/gaylord/meeting-information/"]]];
    }
    [self.contentContainer addSubview:self.meetingInfoWebView];
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    [super setupConstraints];
    
//    [self.headerContainer.superview addConstraint:[self.headerContainer height:(CGRectGetHeight(self.view.frame) * 0.2f)]];
    [self.headerContainer.superview addConstraint:[self.headerContainer height:0]];
    [self.headerContainer.superview addConstraints:[self.headerContainer pinSides:@[@(NSLayoutAttributeTop),
                                                                                    @(NSLayoutAttributeLeading),
                                                                                    @(NSLayoutAttributeTrailing)]
                                                                         constant:0]];
    
    [self.contentContainer.superview addConstraint:[self.contentContainer pinSide:NSLayoutAttributeTop
                                                                           toView:self.headerContainer
                                                                   secondViewSide:NSLayoutAttributeBottom]];
    
    [self.contentContainer.superview addConstraints:[self.contentContainer pinLeadingTrailing]];
    [self.contentContainer.superview addConstraint:[self.contentContainer pinToBottomSuperview]];
    
    [self.meetingInfoWebView.superview addConstraints:[self.meetingInfoWebView pinToSuperviewBounds]];
    [self.headerBackground.superview addConstraints:[self.headerBackground pinToSuperviewBounds]];
    
    
    static CGFloat headerButtonMargin = 10.f;
//    [self.attendeeAccessButton.superview addConstraints:[self.attendeeAccessButton pinSides:@[@(NSLayoutAttributeTop),
//                                                                                              @(NSLayoutAttributeLeading),
//                                                                                              @(NSLayoutAttributeTrailing)]
//                                                                                   constant:headerButtonMargin]];
    
    [self.meetingInformationButton.superview addConstraints:[self.meetingInformationButton pinSides:@[/*@(NSLayoutAttributeBottom),*/
                                                                                                      @(NSLayoutAttributeLeading),
                                                                                                      @(NSLayoutAttributeTrailing)]
                                                                                   constant:headerButtonMargin]];
    
//    [self.attendeeAccessButton.superview addConstraint:[self.attendeeAccessButton pinSide:NSLayoutAttributeBottom
//                                                                                   toView:self.meetingInformationButton
//                                                                           secondViewSide:NSLayoutAttributeTop
//                                                                                 constant:-headerButtonMargin]];
    
//    [self.attendeeAccessButton.superview addConstraint:[self.attendeeAccessButton equalHeightToView:self.meetingInformationButton]];
    [self.attendeeAccessButton addConstraint:[self.attendeeAccessButton height:0]];
    [self.meetingInformationButton addConstraint:[self.meetingInformationButton height:44]];
    
    [self.meetingInformationButton.superview addConstraint:[self.meetingInformationButton alignCenterVerticalSuperview]];

}

@end
