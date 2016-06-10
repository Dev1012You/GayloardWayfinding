//
//  GAHSearchMeetingPlayDelegateHandler.h
//  GaylordHotels
//
//  Created by John Pacheco on 9/14/15.
//  Copyright © 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UISearchBar.h>

@class GAHSearchMeetingPlayDelegateHandler;

@protocol GAHSearchMeetingPlayDelegate <NSObject>
- (void)searchDelegate:(GAHSearchMeetingPlayDelegateHandler *)searchDelegate didFilterLocations:(NSArray *)filteredLocations;
@end

@interface GAHSearchMeetingPlayDelegateHandler : NSObject <UISearchBarDelegate>

@property (nonatomic, weak) id <GAHSearchMeetingPlayDelegate> searchDelegate;
@property (nonatomic, strong) NSArray *displayData;
@property (nonatomic, strong) NSArray *dataSource;
@end

