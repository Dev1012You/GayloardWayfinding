//
//  MTPWebViewController.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"
#import "User+Helpers.h"

@interface MTPWebViewController : MTPBaseViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *webViewContainer;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSManagedObjectContext *rootSavingContext;
@property (nonatomic, strong) NSString *customURL;

@property (nonatomic, assign, getter=isFirstLogin) BOOL firstLogin;

- (void)loadCustomURL:(NSURL *)customURL;

@end
