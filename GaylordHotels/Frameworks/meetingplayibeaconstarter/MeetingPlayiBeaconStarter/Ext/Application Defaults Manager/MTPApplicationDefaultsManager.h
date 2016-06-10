//
//  MTPApplicationDefaultsManager.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;

@interface MTPApplicationDefaultsManager : NSObject

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) NSDictionary *eventDefaults;

+ (instancetype)defaultsManager:(AppDelegate *)appDelegate;

- (void)setupDefaults:(NSDictionary *)eventDefaults;

@end
