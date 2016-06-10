//
//  Sponsor.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Sponsor : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * connectionStatus;
@property (nonatomic, retain) NSString * created;
@property (nonatomic, retain) NSNumber * has_image;
@property (nonatomic, retain) NSNumber * has_logo;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * logo;
@property (nonatomic, retain) NSString * modified;
@property (nonatomic, retain) NSNumber * sponsor_id;
@property (nonatomic, retain) NSString * sponsor_name;
@property (nonatomic, retain) NSString * url;

@end
