//
//  MTPMenuIcon.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPMenuIcon.h"
//#import "NSObject+EventDefaultsHelpers.h"
#import "NSObject+MTPFileManager.h"
#import "NSURLSession+MTPCategory.h"

@implementation MTPMenuIcon

- (instancetype)initWithDictionary:(NSDictionary *)iconDictionary
{
    self = [super init];
    if (self)
    {
        _iconURL = [iconDictionary objectForKey:@"iconURL"] ? [NSURL URLWithString:[iconDictionary objectForKey:@"iconURL"]] : nil;
        
        if (_iconURL)
        {
            [self fetchIconImage:_iconURL];
        }
        
        _fontAwesomeCode = [iconDictionary objectForKey:@"fontAwesomeCode"];
        _resourceName = [iconDictionary objectForKey:@"resourceName"];
    }
    return self;
}

- (UIImage *)fetchIconImage:(NSURL *)iconImageURL
{
    if (iconImageURL)
    {
        NSString *imageFilename = [iconImageURL lastPathComponent];
        if (![imageFilename isKindOfClass:[NSString class]])
        {
            return nil;
        }
        
        if (![self validFileType:imageFilename])
        {
            return nil;
        }

        
        if ([self fileExistsInCaches:imageFilename])
        {
            return [UIImage imageWithContentsOfFile:
                    [NSString stringWithFormat:@"%@%@",self.cacheDirectory,imageFilename]];
        }
        else
        {
            [self downloadImage:iconImageURL];
        }
    }
    
    return nil;
}

- (BOOL)validFileType:(NSString *)filename
{
    NSArray *filenameComponents = [filename componentsSeparatedByString:@"."];
    if ([[filenameComponents lastObject] rangeOfString:@"png"].location != NSNotFound) {
        return true;
    }
    
    if ([[filenameComponents lastObject] rangeOfString:@"jpg"].location != NSNotFound) {
        return true;
    }
    
    return false;
}

- (void)downloadImage:(NSURL *)iconImageURL
{
    __weak __typeof(&*self)weakSelf = self;
    NSMutableURLRequest *imageRequest = [NSURLSession defaultRequestMethod:@"GET" URL:iconImageURL.absoluteString parameters:nil];
    [[[NSURLSession sharedSession] downloadTaskWithRequest:imageRequest
                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            NSLog(@"%s\n[%s]: Line %i] Error fetching icon image %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
                  error);
            return;
        }
        
        if (location)
        {
            NSString *copyTargetLocation = [NSString stringWithFormat:@"%@%@",
                                            [self cacheDirectory],iconImageURL.lastPathComponent];
            NSError *copyError = nil;
            
            BOOL didCopy = [[NSFileManager defaultManager]
                            copyItemAtURL:location
                            toURL:[NSURL URLWithString:copyTargetLocation]
                            error:&copyError];
            if (!didCopy)
            {
                NSLog(@"%s\n[%s]: Line %i] Icon copy error %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
                      copyError);
                return;
            }
            
            UIImage *copiedIconImage = [UIImage imageWithContentsOfFile:copyTargetLocation];
            weakSelf.iconImage = [copiedIconImage copy];
        }
    }] resume];
}

- (NSString *)fontAwesomeHexCode
{
    return self.fontAwesomeCode ? [NSString stringWithFormat:@"0x%@",self.fontAwesomeCode] : nil;
}

@end
