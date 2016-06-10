//
//  MTPConnectionsViewController.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"

@class MTPDataSource,MDMyConnectionManager;

@interface MTPConnectionsViewController : MTPBaseViewController
@property (nonatomic, strong) IBOutlet MTPDataSource *dataSource;
@property (nonatomic, strong) MDMyConnectionManager *connectionManager;
@end
