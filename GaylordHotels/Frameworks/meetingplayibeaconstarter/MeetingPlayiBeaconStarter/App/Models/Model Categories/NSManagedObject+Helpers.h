//
//  NSManagedObject+Helpers.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Helpers)

+ (void)saveToPersistentStore:(NSManagedObjectContext *)context;
- (void)saveToPersistentStore:(NSManagedObjectContext *)context;

@end
