//
//  NSObject+MTPFileManager.m
//  GaylordHotels
//
//  Created by John Pacheco on 5/11/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "NSObject+MTPFileManager.h"

@implementation NSObject (MTPFileManager)
- (BOOL)fileExistsInCaches:(NSString *)filename
{
    NSString *path = [NSString stringWithFormat:@"%@%@",[self cacheDirectory],filename];
    NSURL *pathURL = [NSURL URLWithString:path];
    return [[NSFileManager defaultManager] fileExistsAtPath:pathURL.path];
}

- (NSString *)cacheDirectory
{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject] absoluteString]; // NSSearchPathForDirectoriesInDomains(NSUserDomainMask, NSCachesDirectory, true);
}
@end
