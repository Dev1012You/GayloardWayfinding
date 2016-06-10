//
//  MTPSession.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPSession.h"

@implementation MTPSession

-(void)fillValuesFromResponseObject:(NSDictionary *)response
{
    self.location = [response objectForKey:@"location"];
    self.track = [response objectForKey:@"track"];
    self.modified = [response objectForKey:@"modified"];
    self.sessionDescription = [response objectForKey:@"description"];
    self.teaser = [response objectForKey:@"teaser"];
    self.session_id = [response objectForKey:@"session_id"];
    self.schedule_id = [response objectForKey:@"schedule_id"];
    self.end_time = [response objectForKey:@"end_time"];
    self.start_time = [response objectForKey:@"start_time"];
    self.created = [response objectForKey:@"created"];
    self.photo = [response objectForKey:@"photo"];
    self.sessionTitle = [response objectForKey:@"title"];
    self.goto_session_details = [response objectForKey:@"goto_session_details"];
}

@end
