//
//  MTPConnectionsViewController.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPConnectionsViewController.h"
#import "MTPCustomRootNavigationViewController.h"

#import "MTPDataSource.h"

@interface MTPConnectionsViewController ()
@end

@implementation MTPConnectionsViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataSource = [self setupDataSource];
}

#pragma mark - Initial Setup
- (MTPDataSource *)setupDataSource
{
    MTPDataSource *dataSource;
    if ([self.parentViewController.navigationController isKindOfClass:[MTPCustomRootNavigationViewController class]])
    {
        MTPCustomRootNavigationViewController *customNavigationController = (MTPCustomRootNavigationViewController *)self.parentViewController.navigationController;
        self.connectionManager = customNavigationController.connectionManager;
        dataSource = [MTPDataSource dataSourceRootObjectContext:customNavigationController.rootSavingManagedObjectContext
                                          beaconSightingManager:customNavigationController.beaconSightingManager
                                              connectionManager:customNavigationController.connectionManager];
    }
    else
    {
        NSLog(@"%s [%s]: Line %i]\n Data Source will be nil",
              __FILE__,__PRETTY_FUNCTION__,__LINE__);
    }
    return dataSource;
}

#pragma mark - Protocol Conformance

#pragma mark - IBActions

#pragma mark - Helper Methods

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
