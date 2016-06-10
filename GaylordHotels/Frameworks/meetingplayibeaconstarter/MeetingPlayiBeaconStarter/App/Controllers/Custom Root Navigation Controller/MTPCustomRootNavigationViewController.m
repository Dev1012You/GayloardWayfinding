//
//  MTPCustomRootNavigationViewController.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPCustomRootNavigationViewController.h"
#import "MTPWebViewController.h"
#import "MTPConnectionsViewController.h"
#import "NSString+MTPWebViewURL.h"

@interface MTPCustomRootNavigationViewController ()
@end

@implementation MTPCustomRootNavigationViewController
#pragma mark - View Life Cycle
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self registerForNotifications];
    self.navigationBarHidden = true;
    self.loadedMenuItems = [NSMutableDictionary new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentUser = [User currentUser:self.rootSavingManagedObjectContext];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initial Setup
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLoginNotification:)
                                                 name:MTP_LoginNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLogoutNotification:)
                                                 name:MTP_LogoutNotification
                                               object:nil];
}

#pragma mark - Helper Methods
- (void)didReceiveLoginNotification:(NSNotification *)notification
{
    self.currentUser = [User findUser:[[notification userInfo] objectForKey:kUserID]
                              context:self.rootSavingManagedObjectContext];
    self.currentUser.loggedIn = @(true);
    [self.currentUser saveToPersistentStore:self.rootSavingManagedObjectContext];
    
    [self.userDefaults setObject:self.currentUser.user_id forKey:kUserID];
    [self.userDefaults synchronize];
    
    [self.beaconSightingManager.beaconService startListening];
    self.beaconSightingManager.beaconManager.currentUser = self.currentUser;
    [self.beaconSightingManager.beaconManager getEventBeacons];
    
    [self.sponsorManager fetchConnectedSponsors:nil];
    [self.connectionManager updateConnectionsFromApi];
}

- (void)didReceiveLogoutNotification:(NSNotification *)notification
{
    [self.connectionManager flushAll];
    
    [self.beaconSightingManager.beaconService stopListening];
    self.currentUser.loggedIn = @(false);
    [self.currentUser saveToPersistentStore:self.rootSavingManagedObjectContext];
    
    [self.userDefaults setObject:nil forKey:kUserID];
    [self.userDefaults synchronize];
    
    self.currentUser = nil;
    [self topViewControllerShouldToggleMenu:@(0)];
    
    [self clearWebCaches];
    
    [self popToRootViewControllerAnimated:true];

    [self.loadedMenuItems removeAllObjects];
    
    [self loadLogin];
}

- (void)clearWebCaches
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

- (void)openPoll:(NSURL *)destinationUrl
   realTimePoll:(NSNumber *)realTimePoll
{
    NSDictionary *pollMenuItemDictionary = [[self.userDefaults objectForKey:@"MTP_PollItem"] firstObject];
    MTPMenuItem *pollItem = [MTPMenuItem menuItemFromDictionary:pollMenuItemDictionary];
    
    NSMutableDictionary *newPollDetails = [NSMutableDictionary dictionaryWithDictionary:[[pollItem additionalData] firstObject]];
    [newPollDetails setObject:destinationUrl.absoluteString
                       forKey:@"webviewBaseURL"];
    
    NSArray *newAdditionalDataForPollMenuItem = [NSArray arrayWithObject:newPollDetails];
    pollItem.additionalData = newAdditionalDataForPollMenuItem;
    
    [self loadViewController:pollItem
       controllerDataSources:[self extractViewControllerDataSources:pollItem]];
}

- (void)openSessionDetails:(NSString *)scheduleID
{
    NSDictionary *sessionMenuItemDictionary = [[self.userDefaults objectForKey:@"MTP_SessionItem"] firstObject];
    MTPMenuItem *sessionItem = [MTPMenuItem menuItemFromDictionary:sessionMenuItemDictionary];
    
    NSMutableDictionary *newSessionDetails = [NSMutableDictionary dictionaryWithDictionary:[[sessionItem additionalData] firstObject]];
    [newSessionDetails setObject:[NSString stringWithFormat:[NSString sessionDetailsURL],scheduleID]
                          forKey:@"webviewBaseURL"];
    
    NSArray *newAdditionalDataForSessionMenuItem = [NSArray arrayWithObject:newSessionDetails];
    sessionItem.additionalData = newAdditionalDataForSessionMenuItem;
    
    [self loadViewController:sessionItem
       controllerDataSources:[self extractViewControllerDataSources:sessionItem]];
}

- (MTPViewControllerDataSource *)dataSourceMatchingQuery:(NSString *)query
{
    __block MTPViewControllerDataSource *viewControllerDataSource;
    [self.viewControllerDataSources enumerateKeysAndObjectsUsingBlock:^(id key, MTPViewControllerDataSource *obj, BOOL *stop)
    {
        NSString *viewControllerTitle = [obj pageTitle];
        if ([viewControllerTitle rangeOfString:query options:NSCaseInsensitiveSearch].length != NSNotFound)
        {
            viewControllerDataSource = obj;
            *stop = true;
        }
    }];
    
    if (!viewControllerDataSource)
    {
        viewControllerDataSource = [MTPViewControllerDataSource viewDataSource:@{@"pageTitle": @"Agenda",
                                                                                 @"contentType": @(MTPDisplayStyleWebView),
                                                                                 @"webviewBaseURL": @"http://www.meetingplay.com"}];
    }
    return viewControllerDataSource;
}

- (void)topViewControllerShouldToggleMenu:(id)sender
{
    if ([self.topViewController respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.topViewController performSelectorOnMainThread:@selector(topViewControllerShouldToggleMenu:)
                                                 withObject:sender
                                              waitUntilDone:true];
    }
}


- (void)setAlertManager:(MTPAlertManager *)alertManager
{
    if (_alertManager == alertManager)
    {
        return;
    }
    _alertManager = alertManager;
    _beaconSightingManager.beaconManager.alertManager = _alertManager;
}

#pragma mark View Controller Loading
- (void)loadLogin
{
    MTPLoginClient *loginClient = [MTPLoginClient loginClient:self.rootSavingManagedObjectContext];
    MTPLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:SB_MTPLoginViewController];
    loginViewController.rootNavigationController = self;
    loginViewController.loginClient = loginClient;
    [self setViewControllers:@[loginViewController]];
}

- (void)loadLandingViewController
{
    [self setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:SB_MTPLandingViewController]]];
    return;
}

- (void)loadViewController:(MTPMenuItem *)menuItem controllerDataSources:(NSArray *)viewControllerDataSources
{
    MTPBaseNavigationController *navigationController = [self.loadedMenuItems objectForKey:menuItem.title];
    if (!navigationController)
    {
        navigationController = (MTPBaseNavigationController *)[self prepareViewController:menuItem
                                     controllerDataSources:viewControllerDataSources];
        [self.loadedMenuItems setObject:navigationController forKey:menuItem.title];
    }
    else
    {
        if ([navigationController.topViewController isKindOfClass:[MTPBaseViewController class]])
        {
            MTPBaseViewController *baseViewController = (MTPBaseViewController *)navigationController.topViewController;
            
            if ([baseViewController configurationDataSource].dataSourceType == MTPDisplayStyleWebView)
            {
                MTPViewControllerDataSource *webViewDataSource = [viewControllerDataSources firstObject];
                
                baseViewController.configurationDataSource.webviewBaseURL = webViewDataSource.webviewBaseURL;
                [(MTPWebViewController *)baseViewController
                 loadCustomURL:[NSURL URLWithString:webViewDataSource.webviewBaseURL]];
            }
        }

    }
    
    if ([self.topViewController respondsToSelector:@selector(addViewControllerToStack:)])
    {
        id <MTPChildViewControllerLoading> controller = self.topViewController;
        [controller addViewControllerToStack:navigationController];
    }
    [self topViewControllerShouldToggleMenu:@(0)];
}

- (UIViewController *)prepareViewController:(MTPMenuItem *)menuItem
                      controllerDataSources:(NSArray *)viewControllerDataSources
{
    id preparedViewController = nil;
    
    switch (menuItem.navigationType)
    {
        case MTPNavigationTypeSingleViewController:
        case MTPNavigationTypeNavigationController: {
            preparedViewController = [self configureNavigationController:viewControllerDataSources];
            break;
        }
        case MTPNavigationTypeTabBarController: {
            preparedViewController = [self configureTabBarController:menuItem.selectedTabBarIndex
                                           viewControllerDataSources:viewControllerDataSources];
            break;
        }
        default: {
            DLog(@"\nMenu Item %@ with unknown navigation type %@",
                  menuItem,@(menuItem.navigationType));
            break;
        }
    }
    
    return preparedViewController;
}

- (MTPBaseNavigationController *)configureNavigationController:(NSArray *)viewControllerDataSources
{
    id rootViewController;
    
    for (MTPViewControllerDataSource *controllerData in viewControllerDataSources)
    {
        MTPBaseViewController *newViewController = [self configureViewController:controllerData];
        rootViewController = newViewController;
    }
    return [[MTPBaseNavigationController alloc] initWithRootViewController:rootViewController];
}

- (MTPBaseViewController *)configureViewController:(MTPViewControllerDataSource *)dataSource
{
    return nil;
}

- (MTPBaseTabBarController *)configureTabBarController:(NSInteger)selectedIndex
                             viewControllerDataSources:(NSArray *)viewControllerDataSources
{
    MTPBaseTabBarController *tabBarController = [[MTPBaseTabBarController alloc] init];
    
    NSMutableArray *viewControllers = [NSMutableArray new];
    for (MTPViewControllerDataSource *controllerData in viewControllerDataSources)
    {
        MTPBaseViewController *newViewController = [[MTPBaseViewController alloc] init];
        newViewController.configurationDataSource = controllerData;
        [newViewController configureWithDataSource:newViewController.configurationDataSource];
        [viewControllers addObject:newViewController];
    }
    tabBarController.viewControllers = viewControllers;
    tabBarController.selectedIndex = selectedIndex;
    return tabBarController;
}

@end
