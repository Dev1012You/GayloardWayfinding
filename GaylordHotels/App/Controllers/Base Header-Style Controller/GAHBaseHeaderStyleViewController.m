//
//  GAHBaseHeaderStyleViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseHeaderStyleViewController.h"
#import "UIView+AutoLayoutHelper.h"
#import "GAHDataSource.h"
#import "UIButton+GAHCustomButtons.h"

#import "GAHAPIDataInitializer.h"
#import "GAHMapViewController.h"
#import "GAHStoryboardIdentifiers.h"

@interface GAHBaseHeaderStyleViewController ()
@property (nonatomic, strong) GAHDataSource *contentData;
@end

@implementation GAHBaseHeaderStyleViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    self.detailContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultTexture"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - IBActions
- (void)returnToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - Helper Methods
#pragma mark - Initial Setup
- (void)configureWithDataSource:(MTPViewControllerDataSource *)controllerDataSource
{
    self.configurationDataSource = controllerDataSource;
}




@end
