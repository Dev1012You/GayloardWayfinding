//
//  Sponsor+Helpers.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "Sponsor.h"
#import "MTPConnectionDetailsViewController.h"

@interface Sponsor (Helpers) <MTPConnectionDetailsDisplayable>

+ (instancetype)sponsorName:(NSString*)name photo:(NSURL*)photoUrl;
+ (void)populateSponsor:(Sponsor*)sponsor withJSON:(NSDictionary*)jsonObject;

@end
