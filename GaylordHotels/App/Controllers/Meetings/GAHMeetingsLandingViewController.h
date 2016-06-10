//
//  GAHMeetingsLandingViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/28/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseHeaderStyleViewController.h"

@interface GAHMeetingsLandingViewController : GAHBaseHeaderStyleViewController

@property (nonatomic, strong) UIImageView *headerBackground;
@property (nonatomic, strong) UIButton *attendeeAccessButton;
@property (nonatomic, strong) UIButton *meetingInformationButton;

@property (nonatomic, strong) UIWebView *meetingInfoWebView;

@end
