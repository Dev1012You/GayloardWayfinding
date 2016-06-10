//
//  MTPConnectionDetailsViewController.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/17/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"

@protocol MTPConnectionDetailsDisplayable <NSObject>

- (NSString *)displayMainTitle;
- (NSString *)displaySubtitle;
- (NSURL *)displayImageURL;
- (NSNumber *)connectionID;
@end

@protocol MTPConnectionCompletionDelegate <NSObject>

- (void)didCompleteConnection:(id)connection atIndexPath:(NSIndexPath *)indexPath;
@end

@class MDMyConnectionManager, MTPSponsorManager, MTPCustomRootNavigationViewController, MTPDataSource;

@interface MTPConnectionDetailsViewController : MTPBaseViewController

@property (nonatomic, strong) MTPCustomRootNavigationViewController *rootNavigationController;
@property (nonatomic, strong) MTPSponsorManager *sponsorManager;
@property (nonatomic, strong) MDMyConnectionManager *connectionManager;
@property (nonatomic, strong) MTPDataSource *dataSource;

@property (nonatomic, strong) NSNumber *loggedInUserID;
@property (nonatomic, strong) id <MTPConnectionDetailsDisplayable> connection;
@property (nonatomic, weak) id <MTPConnectionCompletionDelegate> connectionCompletionDelegate;
@property (nonatomic, strong) NSIndexPath *connectionIndexPath;

@property (nonatomic, weak) IBOutlet UILabel *connectionDetailsMainTitle;
@property (nonatomic, weak) IBOutlet UILabel *connectionDetailsSubtitle;
@property (nonatomic, weak) IBOutlet UIImageView *connectionDetailsImage;

@property (nonatomic, weak) IBOutlet UIView *connectionStatusContainer;
@property (weak, nonatomic) IBOutlet UIButton *initiateConnectionButton;
@property (nonatomic, weak) IBOutlet UILabel *connectionStatusIconLabel;
@property (nonatomic, weak) IBOutlet UILabel *connectionStatusText;

- (void)performManagerSetup:(void(^)(void))completionHandler;
- (void)displayConnectionData:(id<MTPConnectionDetailsDisplayable>)connectionData;
@end

#pragma mark - Connection Status Toggling
@interface MTPConnectionDetailsViewController (ConnectionStatusToggling)
- (NSString *)currentConnectionStatus:(NSNumber *)userID;
- (void)changeConnectionStatusContainer:(NSString *)newStatus;

- (void)initiateConnectionRequest:(NSNumber *)connectionID;
- (void)sendConnectionRequest:(NSDictionary *)requestDetails;
- (void)completeConnectionRequest:(NSDictionary *)connectionCompletionDetails;

- (BOOL)showingUserProfile;
@end

#pragma mark - Connection Game Helpers
@interface MTPConnectionDetailsViewController (ConnectionGameHelper)

- (void)checkDrawing:(NSNumber *)userID;
- (void)loadGame:(id<MTPConnectionDetailsDisplayable>)connection;
@end