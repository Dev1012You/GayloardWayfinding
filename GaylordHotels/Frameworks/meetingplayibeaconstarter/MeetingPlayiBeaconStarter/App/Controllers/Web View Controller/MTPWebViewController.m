//
//  MTPWebViewController.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPWebViewController.h"
#import "MTPViewControllerDataSource.h"
#import "MTPCustomRootNavigationViewController.h"
#import "MBProgressHUD.h"
#import "MTPAppSettingsKeys.h"

@interface MTPWebViewController ()

@end

@implementation MTPWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.scalesPageToFit = true;
    self.webView.alpha = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCustomURL:(NSURL *)customURL
{
    NSManagedObjectContext *rootContext = self.rootSavingContext;
//    NSURL *urlWithUserID = [NSURL URLWithString:[NSString stringWithFormat:@"%@userID=%@",customURL.absoluteString,[User currentUser:rootContext].user_id]];
    
    NSURLRequestCachePolicy cachePolicy;
    if ([[self.configurationDataSource.additionalData objectForKey:@"forceReload"] boolValue])
    {
        cachePolicy = NSURLRequestReloadIgnoringCacheData;
    }
    else
    {
        cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    
    NSURL *urlWithUserID = customURL;
    if (urlWithUserID.parameterString.length > 0)
    {
        urlWithUserID = [NSURL URLWithString:[NSString stringWithFormat:@"%@&userID=%@",urlWithUserID.absoluteString,[User currentUser:rootContext].user_id]];
    }
    else
    {
        NSString *lastCharacter = [NSString stringWithFormat:@"%c",[urlWithUserID.absoluteString characterAtIndex:(urlWithUserID.absoluteString.length - 1)]];
        urlWithUserID = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@userID=%@",
                                              urlWithUserID.absoluteString,
                                              [lastCharacter isEqualToString:@"?"] ? @"" : @"?",
                                              [User currentUser:rootContext].user_id]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlWithUserID cachePolicy:cachePolicy timeoutInterval:20.0f];
    
    DLog(@"\ncached response %@",[[NSURLCache sharedURLCache] cachedResponseForRequest:request]);
    
    [self.webView loadRequest:request];
}

#pragma mark - Delegate Methods
#pragma mark UIWebView Delegateo
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [NSString stringWithFormat:@"%@",[[self.userDefaults objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL]];

    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        if ([request.URL.absoluteString rangeOfString:urlString].location == NSNotFound)
        {
            [[UIApplication sharedApplication] openURL:request.URL];
            return false;
        }
    }
    
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // this suppresses the error that occurs when the user navigates to another
    // screen and when it cancels opening "../#/mds-pollzone/" after login
    if (error.code != -999 && error.code != 102) {
        //        [MTConstants showSIAlertWithTitle:@"Network Error" message:@"Couldn't load the website! Press reload to try again"];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
