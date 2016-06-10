//
//  NSManagedObject+Helpers.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "NSManagedObject+Helpers.h"

@implementation NSManagedObject (Helpers)

+ (void)saveToPersistentStore:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        __block NSError *saveError = nil;
        if ([context hasChanges] || [context.parentContext hasChanges])
        {
            if (![context save:&saveError])
            {
                NSLog(@"%s [%s]: Line %i]\nCore Data Save Error %@",
                      __FILE__,__PRETTY_FUNCTION__,__LINE__,
                      saveError);
            }
            
            NSLog(@"%s [%s]: Line %i]\n%@ Context Saved",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  context);
            
            [context.parentContext performBlockAndWait:^{
                if (![context.parentContext save:&saveError])
                {
                    NSLog(@"%s [%s]: Line %i]\nCore Data Save Error %@",
                          __FILE__,__PRETTY_FUNCTION__,__LINE__,
                          saveError);
                }
                else
                {
                    NSLog(@"%s [%s]: Line %i]\n%@ Parent Context Saved",
                          __FILE__,__PRETTY_FUNCTION__,__LINE__,
                          context.parentContext);
                }
            }];
        }
    }];
}

- (void)saveToPersistentStore:(NSManagedObjectContext *)context
{
    [NSManagedObject saveToPersistentStore:context];
}

@end
