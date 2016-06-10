//
//  User+Helpers.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "User+Helpers.h"
#import "EventKeys.h"
#import <UIKit/UIKit.h> 
#import "NSObject+EventDefaultsHelpers.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSURLSession+MTPCategory.h"

@implementation User (Helpers)

+ (User *)findUser:(NSNumber *)userID context:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchUser = [User fetchRequest:[NSPredicate predicateWithFormat:@"%K = %@",@"user_id",userID]
                                             limit:1];

    __block User *fetchResult;
    __block NSError *fetchError = nil;
    
    [managedObjectContext performBlockAndWait:
     ^{
        NSArray *results = [managedObjectContext executeFetchRequest:fetchUser error:&fetchError];
        fetchResult = [results firstObject];
        
        if (fetchError) {
            NSLog(@"%s [%s]: Line %i]\n"
                  "Error fetching user by ID: %@",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  fetchError);
        }
    }];
    
    return fetchResult;
}

+ (NSArray *)findUsers:(NSArray *)userIDs context:(NSManagedObjectContext *)managedObjectContext
{
    NSPredicate *userIDSearchPredicate = [NSPredicate predicateWithFormat:@"user_id IN $userIDs"];

    NSFetchRequest *fetchUsersByID = [User fetchRequest:[userIDSearchPredicate
                                                         predicateWithSubstitutionVariables:@{@"userIDs": userIDs}]
                                                  limit:0];
    
    __block NSArray *fetchResults;
    __block NSError *fetchError = nil;
    
    [managedObjectContext performBlockAndWait:
     ^{
        fetchResults = [managedObjectContext executeFetchRequest:fetchUsersByID error:&fetchError];
        if (fetchError)
        {
            NSLog(@"%s [%s]: Line %i]\n"
                  "Error fetching user by ID: %@",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  fetchError);
        }
    }];
    return fetchResults;
}

+ (NSArray *)allUsersInContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchUsers = [User fetchRequest:nil limit:0];
    
    __block NSArray *fetchResults;
    __block NSError *fetchError = nil;
    
    [managedObjectContext performBlockAndWait:^{
        fetchResults = [managedObjectContext executeFetchRequest:fetchUsers error:&fetchError];
        
        if (fetchError) {
            NSLog(@"%s [%s]: Line %i]\n"
                  "Error fetching user by ID: %@",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  fetchError);
        }
    }];
    
    return fetchResults;
}

+ (User *)createInContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([User class])
                                         inManagedObjectContext:managedObjectContext];
}

+ (NSArray *)createUsers:(NSDictionary *)jsonData context:(NSManagedObjectContext *)managedObjectContext
{
    __block NSMutableArray *usersCreatedFromJsonData = [NSMutableArray new];
    
    NSArray *userIDs = [jsonData objectForKey:@"user_id"];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [userIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            __block NSInteger indexOfUserID = idx;
            User *user = [User findUser:obj context:managedObjectContext];
            if (!user) {
                user = [self createInContext:managedObjectContext];
            }
            
            NSArray *requiredKeys = [User requiredKeys];
            [requiredKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *requiredKey = obj;
                NSArray *valuesForRequiredKey = [jsonData objectForKey:requiredKey];
                id value;
                if ([obj isEqualToString:kUserID]) {
                    value = [valuesForRequiredKey objectAtIndex:indexOfUserID];
                } else {
                    if ([[valuesForRequiredKey objectAtIndex:indexOfUserID] isKindOfClass:[NSString class]]) {
                        value = [valuesForRequiredKey objectAtIndex:indexOfUserID];
                    } else {
                        value = [[valuesForRequiredKey objectAtIndex:indexOfUserID] description];
                    }
                }
                [user setValue:value forKeyPath:requiredKey];
            }];
            [usersCreatedFromJsonData addObject:user];
        }];
    });
    
    return usersCreatedFromJsonData;
}

- (void)updateUser:(NSDictionary*)jsonData
{
    // required values
    self.email = [jsonData objectForKey:kEmail];
    self.first_name = [jsonData objectForKey:kFirstName];
    self.last_name = [jsonData objectForKey:kLastName];
    self.region = [jsonData objectForKey:kRegion];
    self.title = [jsonData objectForKey:kTitle];
    self.user_id = [jsonData objectForKey:kUserID];
    self.user_type = [jsonData objectForKey:kUserType];
    
    // optional values
    self.address1 = [[jsonData objectForKey:kAddress1] description];
    self.address2 = [[jsonData objectForKey:kAddress2] description];
    self.cell = [[jsonData objectForKey:kCell] description];
    self.phone = [[jsonData objectForKey:kPhone] description];
    self.work = [[jsonData objectForKey:kWork] description];
    
    self.bio = [jsonData objectForKey:kBio];
    self.city = [jsonData objectForKey:kCity];
    self.country = [jsonData objectForKey:kCountry];
    self.photo = [jsonData objectForKey:kPhoto];
    self.state = [jsonData objectForKey:kStateProvince];
}

- (void)fetchUpdatedInfo:(void (^)(User *))completionHandler
{
    if (self.user_id)
    {
        NSString *updateCurrentUserURL = [NSString stringWithFormat:@"%@/%@",[NSString userInfo],self.user_id];
        NSMutableURLRequest *updateUserRequest = [NSURLSession defaultRequestMethod:@"GET" URL:updateCurrentUserURL parameters:nil];
        
        __weak __typeof(&*self)weakSelf = self;
        [[[NSURLSession sharedSession] dataTaskWithRequest:updateUserRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
          {
              id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
              if ([responseObject isKindOfClass:[NSDictionary class]])
              {
                  [weakSelf updateUser:[responseObject objectForKey:@"data"]];
                  [weakSelf saveToPersistentStore:weakSelf.managedObjectContext];
                  if (completionHandler) {
                      completionHandler(weakSelf);
                  }
              }
          }] resume];
    }
}

+ (User *)currentUser:(NSManagedObjectContext *)managedObjectContext
{
    NSPredicate *loggedInPredicate = [NSPredicate predicateWithFormat:@"%K = 1",@"loggedIn"];
    
    __block User *fetchResult;
    __block NSError *fetchError = nil;
    
    [managedObjectContext performBlockAndWait:^{
        NSArray *results = [managedObjectContext executeFetchRequest:
                            [User fetchRequest:loggedInPredicate limit:1]
                                                               error:&fetchError];
        fetchResult = [results firstObject];
        
        if (fetchError) {
            NSLog(@"%s [%s]: Line %i]\n"
                  "Error fetching user by ID: %@",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  fetchError);
        }
    }];
    
    return fetchResult;
}


+ (NSFetchRequest *)fetchRequest:(NSPredicate *)fetchPredicate limit:(NSInteger)fetchLimit
{
    NSFetchRequest *newFetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([User class])];
    [newFetchRequest setPredicate:fetchPredicate];
    if (fetchLimit > 0)
    {
        [newFetchRequest setFetchLimit:fetchLimit];
    }
    
    return newFetchRequest;
}

+ (NSArray *)requiredKeys {
    return @[@"company",
             @"country",
             @"state",
             @"phone",
             @"zip_code",
             @"address2",
             @"first_name",
             @"cell",
             @"address1",
             @"bio",
             @"user_type",
             @"work",
             @"email",
             @"attendee_type",
             @"city",
             @"region",
             @"photo",
             @"user_id",
             @"last_name",
             @"title",
             @"drawing"];
}

#pragma mark - Protocol Conformance
- (NSString *)displayMainTitle
{
    NSString *firstname = self.first_name.length > 0 ? self.first_name : @"";
    NSString *lastname = self.last_name.length > 0 ? self.last_name : @"";
    
    return [NSString stringWithFormat:@"%@ %@",firstname,lastname];
}

- (NSString *)displaySubtitle
{
    return self.title.length > 0 ? self.title : @"";
}

- (NSURL *)displayImageURL
{
    NSString *photoBaseURL = [self.userDefaults objectForKey:kProfileImageUrl];
    NSString *userProfileImage = self.photo;
    
    if (photoBaseURL.length > 0 && userProfileImage.length > 0)
    {
        photoBaseURL = [photoBaseURL stringByAppendingString:userProfileImage];
        photoBaseURL = [photoBaseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSURL URLWithString:photoBaseURL];
    }
    else
    {
        return nil;
    }
}

- (NSNumber *)connectionID
{
    return self.user_id;
}
@end
