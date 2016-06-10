//
//  GAHSearchMeetingPlayDelegateHandler.m
//  GaylordHotels
//
//  Created by John Pacheco on 9/14/15.
//  Copyright © 2015 MeetingPlay. All rights reserved.
//

#import "GAHSearchMeetingPlayDelegateHandler.h"

@implementation GAHSearchMeetingPlayDelegateHandler
#pragma mark UISearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;                     // called when text starts editing
{
    [searchBar setShowsCancelButton:true animated:true];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;                       // called when text ends editing
{
    [searchBar setShowsCancelButton:false animated:true];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
{
    if (searchText.length == 0)
    {
        self.displayData = self.dataSource;
    }
    else
    {
        self.displayData = [self filterList:searchText data:self.dataSource];
    }
    
    if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(searchDelegate:didFilterLocations:)])
    {
        [self.searchDelegate searchDelegate:self didFilterLocations:self.displayData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;                     // called when keyboard search button pressed
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;                     // called when cancel button pressed
{
    //    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (NSArray *)filterList:(NSString *)searchCriteria data:(NSArray *)data
{
    NSArray *dataCopy = [NSArray arrayWithArray:data];
    
    NSPredicate *nameFilter = [NSPredicate predicateWithFormat:@"self.location contains[cd] %@",searchCriteria];
    
    NSArray *filteredArray = [dataCopy filteredArrayUsingPredicate:nameFilter];
    
    return filteredArray;
}

@end