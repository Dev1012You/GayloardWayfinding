//
//  User.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * address1;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * cell;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * drawing;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSNumber * loggedIn;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * user_type;
@property (nonatomic, retain) NSString * work;
@property (nonatomic, retain) NSString * zip_code;
@property (nonatomic, retain) NSString * attendee_type;
@property (nonatomic, retain) NSString * company;

@end
