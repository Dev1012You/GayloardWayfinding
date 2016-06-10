//
//  GAHMeetingLoginViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 6/12/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseHeaderStyleViewController.h"

@interface GAHMeetingLoginViewController : GAHBaseHeaderStyleViewController

@property (nonatomic, strong) UIImageView *headerBackground;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (weak, nonatomic) IBOutlet UIView *loginBackground;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UISwitch *termsSwitch;
@property (weak, nonatomic) IBOutlet UIButton *showTermsButton;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end
