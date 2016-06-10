//
//  NSObject+MTPFileManager.h
//  GaylordHotels
//
//  Created by John Pacheco on 5/11/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MTPFileManager)

- (BOOL)fileExistsInCaches:(NSString *)filename;

- (NSString *)cacheDirectory;

@end
