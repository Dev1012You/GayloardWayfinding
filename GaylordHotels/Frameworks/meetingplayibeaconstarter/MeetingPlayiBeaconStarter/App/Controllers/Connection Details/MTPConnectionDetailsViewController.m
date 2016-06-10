//
//  MTPConnectionDetailsViewController.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/17/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPConnectionDetailsViewController.h"
#import "MTPCustomRootNavigationViewController.h"

#import "MTPDataSource.h"
#import "User+Helpers.h"
#import "MTPSponsorManager.h"
#import "Sponsor+Helpers.h"

//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"

#import "EventKeys.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "UIImageView+AFNetworking.h"
#import "NSURLSession+MTPCategory.h"

@interface MTPConnectionDetailsViewController ()
@end

@implementation MTPConnectionDetailsViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Protocol Conformance
#pragma mark - IBActions
#pragma mark - Helper Methods
- (void)displayConnectionData:(id<MTPConnectionDetailsDisplayable>)connectionData
{
    self.connection = connectionData;
    
    if (!self.rootNavigationController)
    {
        [self performManagerSetup:nil];
    }
    
    if ([connectionData respondsToSelector:@selector(displayMainTitle)])
    {
        self.connectionDetailsMainTitle.text = [connectionData displayMainTitle];
        self.connectionDetailsSubtitle.text = [connectionData displaySubtitle];
        [self.connectionDetailsImage setImageWithURL:[connectionData displayImageURL]
                                    placeholderImage:[UIImage imageNamed:@"no_photo"]];
    }
}

#pragma mark - Initial Setup
- (void)performManagerSetup:(void(^)(void))completionHandler
{
    self.dataSource = [MTPDataSource dataSourceRootObjectContext:self.rootNavigationController.rootSavingManagedObjectContext
                                           beaconSightingManager:self.rootNavigationController.beaconSightingManager
                                               connectionManager:self.rootNavigationController.connectionManager];

    self.sponsorManager = self.rootNavigationController.sponsorManager;
    self.connectionManager = self.rootNavigationController.connectionManager;
    
    if (completionHandler)
    {
        completionHandler();
    }
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    return;
}
@end

@implementation MTPConnectionDetailsViewController (ConnectionStatusToggling)

- (void)initiateConnectionRequest:(NSNumber *)connectionID
{
    NSDictionary *connectionStatusTransformations = @{kMyConnectionNotConnected: kMyConnectionPending,
                                                      kMyConnectionPending: kMyConnectionPending,
                                                      kMyConnectionConnected: kMyConnectionConnected};
    
    NSString *oldConnectionStatus = [self currentConnectionStatus:connectionID];
    if ([oldConnectionStatus isEqualToString:kMyConnectionConnected])
    {
        DLog(@"\nalready connected to %@", self.connection);
        return;
    }
    else if (!oldConnectionStatus)
    {
        oldConnectionStatus = kMyConnectionNotConnected;
    }
    NSString *newConnectionStatus = [connectionStatusTransformations objectForKey:oldConnectionStatus];
    
    [self changeConnectionStatusContainer:newConnectionStatus];

    NSDictionary *requestInformation;
    
    if ([self showingUserProfile])
    {
        requestInformation = [self initiateUserConnectionRequest:self.loggedInUserID];
    }
    else
    {
        requestInformation = [self initiateSponsorConnectionRequest:self.loggedInUserID];
    }
    
    [self sendConnectionRequest:requestInformation];
}

- (NSDictionary *)initiateUserConnectionRequest:(NSNumber *)userID
{
    return @{@"apiURL": [NSString stringWithFormat:[NSString userConnectionAdd],userID],
             @"parameters": @{@"connection_user_id":[self.connection connectionID]},
             @"requestType": @"userConnection"};
}

- (NSDictionary *)initiateSponsorConnectionRequest:(NSNumber *)sponsorID
{
    return @{@"apiURL": [NSString stringWithFormat:[NSString sponsorConnectionAdd],sponsorID],
             @"parameters": @{@"user_id":[self.connection connectionID]},
             @"requestType": @"userConnection"};
}

- (void)changeConnectionStatusContainer:(NSString *)newStatus
{
    NSDictionary *connectionStatus = [self connectionDetailsForStatus:newStatus];
    
    NSString *statusImage = [connectionStatus objectForKey:@"icon"];
    NSString *statusText = [connectionStatus objectForKey:@"text"];
    UIColor *statusBackgroundColor = [connectionStatus objectForKey:@"color"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionStatusContainer.backgroundColor = statusBackgroundColor;
        self.connectionStatusIconLabel.text = statusImage;
        self.connectionStatusText.text = statusText;
    });
}

- (BOOL)processRequest:(NSURLRequest *)request apiError:(NSError *)apiError response:(NSURLResponse *)urlResponse
{
    if (!apiError)
    {
        return false;
    }
    
    if (apiError.code == 400) {
//        NSString *connectionStatus = [self.connectionManager checkMyConnectionFor:[self.connection connectionID]];
        // should load game
        //                [weakSelf performSegueWithIdentifier:@"initiateConnectionSegue" sender:nil];
    }
    else if (apiError.code == 409)
    {
        if (![self showingUserProfile])
        {
            [self.sponsorManager updateSponsor:self.connection connectionStatus:kMyConnectionConnected];
            /*
            if (self.delegate && [weakSelf.delegate respondsToSelector:@selector(sponsorConnection:)])
            {
                [weakSelf.delegate sponsorConnection:weakSelf.sponsor];
            }
             */
        }
        DLog(@"\nalready sent a request");
    }
    DLog(@"\nerror %@", apiError.localizedDescription);

    return true;
}

- (void)sendConnectionRequest:(NSDictionary *)requestDetails
{
    NSString *requestURLString = [requestDetails objectForKey:@"apiURL"];
    NSDictionary *requestParameters = [requestDetails objectForKey:@"parameters"];
    
    NSMutableURLRequest *urlRequest = [NSURLSession defaultRequestMethod:@"PUT"
                                                             URL:requestURLString
                                                      parameters:requestParameters];

    __weak __typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if ([weakSelf processRequest:urlRequest apiError:error response:response] == false) {
            // no error so it must have succeeded
            id responseObject = [NSURLSession serializeJSONData:data
                                                   response:response
                                                      error:error];
            
            
            
            if ([weakSelf showingUserProfile])
            {
                if ([weakSelf.userDefaults objectForKey:@"eventHasConnectionGame"])
                {
                    [weakSelf performSegueWithIdentifier:@"initiateConnectionSegue" sender:nil];
                }
                else
                {
                    DLog(@"\nresponseObject %@", responseObject);
                    [weakSelf.connectionManager changeMyConnectionStatus:[weakSelf.connection connectionID]
                                                                toStatus:kMyConnectionConnected];
                    [weakSelf changeConnectionStatusContainer:kMyConnectionConnected];
                    [weakSelf completeConnectionRequest:nil];
                }
            }
            else
            {
                [weakSelf.sponsorManager updateSponsor:weakSelf.connection
                                      connectionStatus:kMyConnectionConnected];
                
                //            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(sponsorConnection:)])
                //            {
                //                [weakSelf.delegate sponsorConnection:weakSelf.sponsor];
                //            }
                [weakSelf changeConnectionStatusContainer:[weakSelf.sponsorManager
                                                           connectionStatus:weakSelf.loggedInUserID]];
            }
        }
    }] resume];
}

- (void)completeConnectionRequest:(NSDictionary *)connectionCompletionDetails
{

    // change data
//    NSNumber *userID;
//    [[MDMyConnectionManager sharedManager] changeMyConnectionStatus:userID to:kMyConnectionConnected];
    
    // change ui
//    [self toggleConnectionStatus];
    
    if (self.connectionCompletionDelegate
        && [self.connectionCompletionDelegate respondsToSelector:@selector(didCompleteConnection:atIndexPath:)])
    {
        [self.connectionCompletionDelegate didCompleteConnection:self.connection atIndexPath:self.connectionIndexPath];
    }
}

- (NSString *)currentConnectionStatus:(NSNumber *)userID
{
    NSString *connectionStatus = [self showingUserProfile] ? [self.connectionManager checkMyConnectionFor:userID] : [self.sponsorManager connectionStatus:userID];
    return connectionStatus ? connectionStatus : kMyConnectionNotConnected;
}

- (BOOL)showingUserProfile
{
    return [self.connection isKindOfClass:[User class]] ? true : false;
}

- (NSDictionary *)connectionDetailsForStatus:(NSString *)connectionStatus
{
    NSDictionary *connectionDetails = @{kMyConnectionConnected:@{@"icon": @"\uf0c1",
                                                                 @"text": @"Connected",
                                                                 @"color": kDarkGreen},
                                        
                                        kMyConnectionPending:@{@"icon": @"\uf017",
                                                               @"text": @"Pending",
                                                               @"color": kOrange},
                                        
                                        kMyConnectionNotConnected:@{@"icon": @"\uf127",
                                                                    @"text": @"Click to Connect",
                                                                    @"color": kDarkBlue}
                                        };
    return [connectionDetails objectForKey:connectionStatus];
}
@end


@implementation MTPConnectionDetailsViewController (ConnectionGameHelper)

- (void)checkDrawing:(NSNumber *)userID
{
    
}

- (void)loadGame:(id<MTPConnectionDetailsDisplayable>)connection
{
    
}
@end