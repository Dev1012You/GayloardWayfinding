//
//  MTPCoreDataInitializationHelper.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h> 

@interface MTPCoreDataInitializationHelper : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (instancetype)initWithManagedObjectModelName:(NSString *)managedObjectModelName
                               sqliteStoreName:(NSString *)sqliteStoreName;

- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectContext *)managedObjectContext;
@end
