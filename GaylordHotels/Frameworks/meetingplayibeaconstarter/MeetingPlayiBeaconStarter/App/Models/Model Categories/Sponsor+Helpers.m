//
//  Sponsor+Helpers.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "Sponsor+Helpers.h"

@implementation Sponsor (Helpers)

+ (instancetype)sponsorName:(NSString *)name photo:(NSURL *)photoUrl
{
    Sponsor *sponsor = [[Sponsor alloc] init];
    if (sponsor) {
        sponsor.sponsor_name = name;
        sponsor.image = photoUrl.absoluteString;
    }
    return sponsor;
}

+ (void)populateSponsor:(Sponsor*)sponsor withJSON:(NSDictionary*)jsonObject
{
    sponsor.bio = [jsonObject objectForKey:@"bio"];
    sponsor.created = [jsonObject objectForKey:@"created"];
    sponsor.image = [jsonObject objectForKey:@"image"];
    sponsor.logo = [jsonObject objectForKey:@"logo"];
    sponsor.modified = [jsonObject objectForKey:@"modified"];
    sponsor.sponsor_id = [jsonObject objectForKey:@"sponsor_id"];
    sponsor.sponsor_name = [jsonObject objectForKey:@"sponsor_name"];
    sponsor.url = [jsonObject objectForKey:@"url"];
}

- (NSString *)displayMainTitle
{
    return (self.sponsor_name > 0 ? self.sponsor_name : @"");
}

- (NSString *)displaySubtitle
{
    return (self.url.length > 0 ? self.url : @"");
}

- (NSURL *)displayImageURL
{
    NSString *photoBaseURL = [self.userDefaults objectForKey:kSponsorLogoUrl];
    NSString *sponsorDetailsImage = self.logo;
    
    if (photoBaseURL.length > 0 && sponsorDetailsImage.length > 0)
    {
        photoBaseURL = [photoBaseURL stringByAppendingString:sponsorDetailsImage];
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
    return self.sponsor_id;
}

@end
