//
//  GAHUserSettingsViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 6/26/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHUserSettingsViewController.h"
#import "GAHPanelView.h"
#import "UIView+AutoLayoutHelper.h"
#import "UIButton+GAHCustomButtons.h"
#import "GAHAPIDataInitializer.h"
#import "MBProgressHUD.h"

@interface GAHUserSettingsViewController ()
@property (nonatomic, strong) GAHPanelView *notificationsPanel;
@property (nonatomic, strong) GAHPanelView *userLocationPanel;
@property (nonatomic, strong) UIButton *clearCacheButton;
@property (nonatomic, strong) UIButton *reloadMapsButton;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) NSLayoutConstraint *userLocationPanelHeight;
@end

@implementation GAHUserSettingsViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createPanelViews];
    [self setupNotificationsPanel];
    [self setupUserLocationPanel];
    [self createClearCacheButton];
    [self createReloadMapsButton];
    [self createVersionLabel];
    [self createDebugSwitch];
    
    [self.view sendSubviewToBack:self.mainMenuContainer];
    
    [self.detailContainer setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultTexture"]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:false];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MyriadPro-Bold" size:13.f],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationItem setTitle:@"NOTIFICATIONS"];

}

#pragma mark - Protocol Conformance
#pragma mark - IBActions
#pragma mark - Helper Methods
#pragma mark - Initial Setup
- (void)createPanelViews
{
    self.notificationsPanel = [[[NSBundle mainBundle] loadNibNamed:@"GAHPanelView" owner:self options:0] firstObject];
    self.notificationsPanel.translatesAutoresizingMaskIntoConstraints = false;
    self.notificationsPanel.backgroundColor = [UIColor clearColor];
    self.notificationsPanel.panelContainer.layer.shadowOpacity = 0.5f;
    self.notificationsPanel.panelContainer.layer.shadowRadius = 3.f;
    self.notificationsPanel.panelContainer.layer.cornerRadius = 3.f;
//    self.notificationsPanel.panelContainer.layer.masksToBounds = true;

    
    self.notificationsPanel.panelTitle.backgroundColor = [UIColor lightGrayColor];//UIColorFromRGB(0x002c77);
    self.notificationsPanel.panelTitle.textColor = [UIColor whiteColor];
    self.notificationsPanel.panelTitle.text = @"Handicap Accessible Directions";
    
    [self.settingsScrollView addSubview:self.notificationsPanel];
    
    [self.notificationsPanel addConstraints:@[[self.notificationsPanel height:120.f],
                                         [self.notificationsPanel width:self.view.frame.size.width * 0.9f]]];
    
    [self.notificationsPanel.superview addConstraints:@[[self.notificationsPanel alignSide:NSLayoutAttributeTop constant:10.f],
                                                        [self.notificationsPanel alignCenterHorizontalSuperview]]];
    
    self.userLocationPanel = [[[NSBundle mainBundle] loadNibNamed:@"GAHPanelView" owner:self options:0] firstObject];
    self.userLocationPanel.translatesAutoresizingMaskIntoConstraints = false;
    self.userLocationPanel.backgroundColor = [UIColor clearColor];
    self.userLocationPanel.panelContainer.layer.shadowOpacity = 0.5f;
    self.userLocationPanel.panelContainer.layer.shadowRadius = 3.f;
    self.userLocationPanel.panelContainer.layer.cornerRadius = 3.f;
//    self.userLocationPanel.panelContainer.layer.masksToBounds = true;
    
    
    self.userLocationPanel.panelTitle.backgroundColor = [UIColor lightGrayColor];// UIColorFromRGB(0x002c77);
    self.userLocationPanel.panelTitle.textColor = [UIColor whiteColor];
    self.userLocationPanel.panelTitle.text = @"User Location";
    [self.settingsScrollView addSubview:self.userLocationPanel];
    
    self.userLocationPanelHeight = [self.userLocationPanel height:NSLayoutRelationGreaterThanOrEqual constant:60.f];
    [self.userLocationPanel addConstraints:@[self.userLocationPanelHeight,
                                             [self.userLocationPanel width:self.view.frame.size.width * 0.9f]]];
    
    [self.userLocationPanel.superview addConstraints:@[[self.userLocationPanel alignSide:NSLayoutAttributeTop toView:self.notificationsPanel secondSide:NSLayoutAttributeBottom constant:10.f],
                                                       [self.userLocationPanel alignCenterHorizontalSuperview]]];
}

- (void)setupNotificationsPanel
{
    UIView *containerView = [UIView new];
    containerView.translatesAutoresizingMaskIntoConstraints = false;
    [self.notificationsPanel.panelContainer addSubview:containerView];
    [containerView.superview addConstraints:@[[containerView pinSide:NSLayoutAttributeTop
                                                              toView:self.notificationsPanel.panelTitleContainer
                                                      secondViewSide:NSLayoutAttributeBottom
                                                            constant:10.f],
                                              [containerView pinLeading:10.f],
                                              [containerView pinTrailing:10.f],
                                              [containerView pinToBottomSuperview:10.]]];
    
    UILabel *notificationSetting = [UILabel new];
    notificationSetting.translatesAutoresizingMaskIntoConstraints = false;
    notificationSetting.font = [UIFont fontWithName:@"MyriadPro-Regular" size:17.f];
    notificationSetting.text = @"Handicap Accessible-Only Directions";
    notificationSetting.lineBreakMode = NSLineBreakByWordWrapping;
    
    [containerView addSubview:notificationSetting];
    [notificationSetting.superview addConstraints:@[[notificationSetting pinToTopSuperview],
                                                    [notificationSetting pinLeading]]];
    
    UISwitch *notificationSwitch = [UISwitch new];
    notificationSwitch.onTintColor = UIColorFromRGB(0x002C77);
    notificationSwitch.translatesAutoresizingMaskIntoConstraints = false;
    [containerView addSubview:notificationSwitch];
    [notificationSwitch.superview addConstraints:@[[notificationSwitch pinToTopSuperview],
                                                   [notificationSwitch pinTrailing]]];
    [notificationSwitch addTarget:self action:@selector(accessibilitySettingChanged:) forControlEvents:UIControlEventValueChanged];
    [notificationSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:kAccessibleOnlyDirections] boolValue]];
    
    NSLayoutConstraint *spacing = [notificationSetting pinSide:NSLayoutAttributeTrailing
                                                        toView:notificationSwitch
                                                secondViewSide:NSLayoutAttributeLeading];
    spacing.priority = 999;
    [notificationSwitch.superview addConstraint:spacing];
    
    [notificationSetting.superview addConstraint:[notificationSetting alignSide:NSLayoutAttributeBottom
                                                                         toView:notificationSwitch
                                                                     secondSide:NSLayoutAttributeBottom
                                                                       constant:0]];
}

- (void)accessibilitySettingChanged:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *switchControl = (UISwitch *)sender;
        BOOL accessibleOnly = [switchControl isOn];
        [[NSUserDefaults standardUserDefaults] setBool:accessibleOnly forKey:kAccessibleOnlyDirections];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setupUserLocationPanel
{
    UILabel *userLocationDetails = [UILabel new];
    userLocationDetails.translatesAutoresizingMaskIntoConstraints = false;
    userLocationDetails.font = [UIFont fontWithName:@"MyriadPro-Regular" size:17.f];
    userLocationDetails.numberOfLines = 0;
    userLocationDetails.lineBreakMode = NSLineBreakByWordWrapping;
    userLocationDetails.text = @"This app requires your device to be location enabled to function correctly. If experiencing issues enable your location by visiting\n\nSettings > Privacy > Location Services";
    [self.userLocationPanel.panelContent addSubview:userLocationDetails];
    [userLocationDetails.superview addConstraints:@[[userLocationDetails pinToTopSuperview:10.f],
                                                    [userLocationDetails pinLeading:10.f],
                                                    [userLocationDetails pinTrailing:10.f]]];
    [self.userLocationPanel.superview addConstraint:[self.userLocationPanel pinSide:NSLayoutAttributeBottom
                                                                             toView:userLocationDetails
                                                                     secondViewSide:NSLayoutAttributeBottom
                                                                           constant:20.f]];
}


- (void)createClearCacheButton
{
    self.clearCacheButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clearCacheButton.translatesAutoresizingMaskIntoConstraints = false;
    self.clearCacheButton.backgroundColor = [UIColor blackColor];
    
    self.clearCacheButton.titleLabel.font = self.userLocationPanel.panelTitle.font;
    [self.clearCacheButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.clearCacheButton setTitle:@"RELOAD DATA" forState:UIControlStateNormal];
    [self.clearCacheButton addTarget:self action:@selector(reloadAPIData:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingsScrollView addSubview:self.clearCacheButton];
    
    [self.clearCacheButton addConstraints:@[[self.clearCacheButton height:40.f],
                                           [self.clearCacheButton width:200.f]]];
    [self.clearCacheButton.superview addConstraints:@[[self.clearCacheButton pinSide:NSLayoutAttributeTop
                                                                              toView:self.userLocationPanel
                                                                      secondViewSide:NSLayoutAttributeBottom
                                                                            constant:10.f],
                                                      [self.clearCacheButton alignCenterHorizontalSuperview]]];
}

- (void)createReloadMapsButton
{
    self.reloadMapsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.reloadMapsButton.translatesAutoresizingMaskIntoConstraints = false;
    self.reloadMapsButton.backgroundColor = [UIColor blackColor];
    
    self.reloadMapsButton.titleLabel.font = self.userLocationPanel.panelTitle.font;
    [self.reloadMapsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.reloadMapsButton setTitle:@"RELOAD MAPS" forState:UIControlStateNormal];
    [self.reloadMapsButton addTarget:self action:@selector(reloadMapsData:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingsScrollView addSubview:self.reloadMapsButton];
    
    [self.reloadMapsButton addConstraints:@[[self.reloadMapsButton height:40.f],
                                            [self.reloadMapsButton width:200.f]]];
    [self.reloadMapsButton.superview addConstraints:@[[self.reloadMapsButton pinSide:NSLayoutAttributeTop
                                                                              toView:self.clearCacheButton
                                                                      secondViewSide:NSLayoutAttributeBottom
                                                                            constant:20.f],
                                                      [self.reloadMapsButton alignCenterHorizontalSuperview]]];
}

- (void)createVersionLabel
{
    NSString *bundleVersion = (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(),
                                                                              kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey];
    
    self.versionLabel = [UILabel new];
    self.versionLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.versionLabel.backgroundColor = [UIColor clearColor];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    
    self.versionLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12.f];
    self.versionLabel.text = [NSString stringWithFormat:@"Gaylord Wayfinding 1.0 (%@)",bundleVersion];

    [self.settingsScrollView addSubview:self.versionLabel];
    
    [self.versionLabel addConstraints:@[[self.versionLabel height:40.f],
                                        [self.versionLabel width:200.f]]];
    
    [self.versionLabel.superview addConstraints:@[[self.versionLabel pinSide:NSLayoutAttributeTop
                                                                      toView:self.reloadMapsButton
                                                              secondViewSide:NSLayoutAttributeBottom
                                                                    constant:10.f],
                                                  [self.versionLabel alignCenterHorizontalSuperview]]];
}

- (void)createDebugSwitch
{
    UISwitch *notificationSwitch = [UISwitch new];
    notificationSwitch.onTintColor = UIColorFromRGB(0x002C77);
    notificationSwitch.translatesAutoresizingMaskIntoConstraints = false;

    [notificationSwitch addTarget:self action:@selector(debugSettingChanged:) forControlEvents:UIControlEventValueChanged];
    [notificationSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:@"debugEnabled"] boolValue]];
    [self.settingsScrollView addSubview:notificationSwitch];
    
    UISwitch *beaconSelectionSwitch = [UISwitch new];
    beaconSelectionSwitch.onTintColor = UIColorFromRGB(0x002C77);
    beaconSelectionSwitch.translatesAutoresizingMaskIntoConstraints = false;
    
    [beaconSelectionSwitch addTarget:self action:@selector(beaconSelectSettingChanged:) forControlEvents:UIControlEventValueChanged];
    [beaconSelectionSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:@"beaconSelectEnabled"] boolValue]];
    [self.settingsScrollView addSubview:beaconSelectionSwitch];
    
    [notificationSwitch.superview addConstraints:@[[notificationSwitch pinSide:NSLayoutAttributeTop
                                                                        toView:self.versionLabel
                                                                secondViewSide:NSLayoutAttributeBottom
                                                                      constant:20.f],
                                                   [notificationSwitch pinSide:NSLayoutAttributeBottom toView:beaconSelectionSwitch secondViewSide:NSLayoutAttributeTop constant:-20.f],
                                                   [notificationSwitch alignCenterHorizontalSuperview]]];
    
    [beaconSelectionSwitch.superview addConstraints:@[[beaconSelectionSwitch pinSide:NSLayoutAttributeTop
                                                                        toView:notificationSwitch
                                                                secondViewSide:NSLayoutAttributeBottom
                                                                      constant:20.f],
                                                   [beaconSelectionSwitch pinSide:NSLayoutAttributeBottom relation:NSLayoutRelationEqual constant:-20.f],
                                                   [beaconSelectionSwitch alignCenterHorizontalSuperview]]];
    
    
}

- (void)debugSettingChanged:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *switchControl = (UISwitch *)sender;
        BOOL accessibleOnly = [switchControl isOn];
        [[NSUserDefaults standardUserDefaults] setBool:accessibleOnly forKey:@"debugEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
//[[NSUserDefaults standardUserDefaults] objectForKey:@"beaconSelectEnabled"]
- (void)beaconSelectSettingChanged:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *switchControl = (UISwitch *)sender;
        BOOL accessibleOnly = [switchControl isOn];
        [[NSUserDefaults standardUserDefaults] setBool:accessibleOnly forKey:@"beaconSelectEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)reloadAPIData:(id)sender
{
    MBProgressHUD *reloadHud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    reloadHud.labelText = @"Reloading";
    [reloadHud show:true];
    
    [self.dataInitializer fetchInitialAPIData:nil];
    [self.dataInitializer fetchMeetingPlayLocations:^(NSArray *locations, NSError *fetchError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fetchError)
            {
                reloadHud.labelText = @"Error fetching data!";
            }
            [reloadHud hide:true afterDelay:2];
        });
    }];
}

- (void)reloadMapsData:(id)sender
{
    MBProgressHUD *reloadHud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    reloadHud.labelText = @"Reloading Maps";
    [reloadHud show:true];
    
    [self.dataInitializer fetchMapImageURLsForceRefetch:true completionHandler:^(GAHMapDataSource *mapDataSource, NSError *mapFetchError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (mapFetchError)
            {
                reloadHud.labelText = @"Error fetching data!";
            }

            [reloadHud hide:true afterDelay:2];
        });
    }];
}

- (void)session:(NSURLSession *)session task:(NSURLSessionTask *)sessionTask didUpdate:(NSMutableDictionary *)downloadOperations
{
    __block BOOL mapDownloadsFinished = true;
    NSDictionary *downloads = [NSDictionary dictionaryWithDictionary:downloadOperations];
    [downloads enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSURLSessionDownloadTask class]])
        {
            NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)obj;
            if (downloadTask.state != NSURLSessionTaskStateCompleted)
            {
                mapDownloadsFinished = false;
                *stop = true;
            }
        }
    }];
    
    if (mapDownloadsFinished)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:true];
            [[NSFileManager defaultManager] setDelegate:nil];
        });
    }
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    [super setupConstraints];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
