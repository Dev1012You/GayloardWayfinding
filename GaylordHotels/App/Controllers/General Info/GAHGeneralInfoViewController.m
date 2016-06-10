//
//  GAHGeneralInfoViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 6/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHGeneralInfoViewController.h"
#import "UIButton+GAHCustomButtons.h"

@interface GAHGeneralInfoViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonContainerHeight;
@end

@implementation GAHGeneralInfoViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.minimizeCloseBar = true;
    self.showToggleMenu = true;
    self.pageTitle = @"GENERAL INFORMATION";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view sendSubviewToBack:self.mainMenuContainer];
    
    [super setupConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:false];
    
    [self.navigationItem setTitle:self.pageTitle];
    
    if (self.showToggleMenu)
    {
        UIButton *menuButton = [UIButton menuNavigationButtonWithTarget:self selector:@selector(toggleMenu:)];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:menuButton]];
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MyriadPro-Bold" size:13.f],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor]}];

    if (self.minimizeCloseBar)
    {
        self.closeButtonContainerHeight.constant = 0;
    }
    else
    {
        self.view.backgroundColor = [UIColor blackColor];
        self.closeButtonContainerHeight.constant = 30;
    }

    [self.generalInfoWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.generalInfoURL]]];
}

- (IBAction)pressedClose:(id)sender
{
    if (self.presentingViewController)
    {
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }
}

@end
