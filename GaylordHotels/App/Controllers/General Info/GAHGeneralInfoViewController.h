//
//  GAHGeneralInfoViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 6/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseHeaderStyleViewController.h"

@interface GAHGeneralInfoViewController : GAHBaseHeaderStyleViewController

@property (weak, nonatomic) IBOutlet UIWebView *generalInfoWebView;
@property (weak, nonatomic) IBOutlet UIView *closeButtonContainer;

@property (nonatomic, strong) NSString *generalInfoURL;
@property (nonatomic, strong) NSString *pageTitle;

@property (nonatomic, assign) BOOL minimizeCloseBar;
@property (nonatomic, assign) BOOL showToggleMenu;

- (IBAction)pressedClose:(id)sender;

@end
