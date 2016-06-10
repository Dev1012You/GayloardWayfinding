//
//  GAHSelectionModalView.h
//  GaylordHotels
//
//  Created by John Pacheco on 9/11/15.
//  Copyright © 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAHSearchMeetingPlayDelegateHandler.h"

@protocol GAHSelectionModalDelegate <NSObject>
@optional
- (UITableViewCell *)selectionModalTableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell data:(id)rowData atIndexPath:(NSIndexPath *)indexPath;
- (void)selectionModalTableView:(UITableView *)tableView didSelectData:(id)rowData atIndexPath:(NSIndexPath *)indexPath;
@end

@interface GAHSelectionModalView : UIView <UISearchBarDelegate>

@property (nonatomic, weak) id <GAHSelectionModalDelegate> selectionModalDelegate;
@property (nonatomic, strong) GAHSearchMeetingPlayDelegateHandler *modalSearchDelegatehandler;

@property (nonatomic, strong) NSArray *displayData;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UILabel *containerTitle;
@property (nonatomic, strong) UILabel *containerDescription;
@property (nonatomic, strong) UISearchBar *dataSearchBar;

@property (nonatomic, strong) UIView *dataListContainer;
@property (nonatomic, strong) UITableView *dataList;

@property (nonatomic, strong) UIView *buttonsContainer;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, copy) void(^cancelBlock)(void);

@property (nonatomic, assign) BOOL showsSearchBar;

- (void)setupConstraints;
- (void)setupDefaultAppearance:(BOOL)showsSearchBar;

- (void)prepareData:(NSArray *)newData;

- (void)resetDestinationList;

@end
