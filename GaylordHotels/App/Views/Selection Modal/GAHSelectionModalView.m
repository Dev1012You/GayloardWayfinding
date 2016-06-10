//
//  GAHSelectionModalView.m
//  GaylordHotels
//
//  Created by John Pacheco on 9/11/15.
//  Copyright © 2015 MeetingPlay. All rights reserved.
//

#import "GAHSelectionModalView.h"
#import "UIView+AutoLayoutHelper.h"
#import "GAHDestination.h"


// selection modal table delegate handler
@class GAHSelectionModalDelegateHandler;

@protocol GAHSelectionDelegate <NSObject>
@optional
- (void)selectionDelegate:(GAHSelectionModalDelegateHandler *)selectionDelegate tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface GAHSelectionModalDelegateHandler: NSObject <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *displayData;
@property (nonatomic, weak) id <GAHSelectionModalDelegate> selectionModalDelegate;
@end

@implementation GAHSelectionModalDelegateHandler
#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.displayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.textLabel.adjustsFontSizeToFitWidth = true;
        cell.textLabel.minimumScaleFactor = 0.5f;
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    id rowData = [self.displayData objectAtIndex:indexPath.row];
    
    if (self.selectionModalDelegate && [self.selectionModalDelegate respondsToSelector:@selector(selectionModalTableView:configureCell:data:atIndexPath:)])
    {
        cell = [self.selectionModalDelegate selectionModalTableView:tableView configureCell:cell data:rowData atIndexPath:indexPath];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id rowData = [self.displayData objectAtIndex:indexPath.row];
    
    if (self.selectionModalDelegate && [self.selectionModalDelegate respondsToSelector:@selector(selectionModalTableView:didSelectData:atIndexPath:)])
    {
        [self.selectionModalDelegate selectionModalTableView:tableView didSelectData:rowData atIndexPath:indexPath];
    }
}

@end

#pragma mark - GAHSelectionModalView
@interface GAHSelectionModalView () <GAHSearchMeetingPlayDelegate>
@property (nonatomic, strong) GAHSelectionModalDelegateHandler *modalTableDelegateHandler;
@end

@implementation GAHSelectionModalView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.containerTitle = [UILabel new];
        self.containerDescription = [UILabel new];
        
        self.dataSearchBar = [UISearchBar new];
        self.dataListContainer = [UIView new];
        self.dataList = [UITableView new];
        
        self.buttonsContainer = [UIView new];
        self.cancelButton = [UIButton new];
        
        self.modalTableDelegateHandler = [GAHSelectionModalDelegateHandler new];
        self.modalSearchDelegatehandler = [GAHSearchMeetingPlayDelegateHandler new];
        self.modalSearchDelegatehandler.searchDelegate = self;
    }
    
    return self;
}

- (void)prepareData:(NSArray *)newData
{
    self.dataSource = newData;
    self.modalTableDelegateHandler.displayData = self.dataSource;
    self.modalSearchDelegatehandler.dataSource = self.dataSource;
    [self resetDestinationList];
}

- (void)setupDefaultAppearance:(BOOL)showsSearchBar
{
    self.showsSearchBar = showsSearchBar;
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 20.f;
    self.layer.shadowOpacity = 1.f;
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.containerTitle = [self setupContainerTitle:self.containerTitle];
    self.containerDescription = [self setupContainerDescription:self.containerDescription];
    
    self.dataSearchBar = [self setupDestinationSearchBar:self.dataSearchBar];

    self.dataList = [self setupDestinationSelectionTable];
    self.cancelButton = [self setupCancelButton:self.cancelButton];
    
    [self addSubview:self.containerTitle];
    [self addSubview:self.containerDescription];
    [self addSubview:self.dataSearchBar];
    [self addSubview:self.dataListContainer];
    
    [self.buttonsContainer addSubview:self.cancelButton];
    [self addSubview:self.buttonsContainer];
    
    [self.dataListContainer addSubview:self.dataList];
    
    [self setupConstraints];
}

- (NSArray *)sortMeetingPlayDestinations:(NSArray *)meetingPlayDestinations
{
    NSArray *sortedDestinations = [meetingPlayDestinations sortedArrayUsingComparator:^NSComparisonResult(GAHDestination *obj1, GAHDestination *obj2)
                                   {
                                       return [obj1.location caseInsensitiveCompare:obj2.location];
                                   }];
    
    return sortedDestinations;
}

#pragma mark - Subview Setup
- (UILabel *)setupContainerTitle:(UILabel *)containerTitle
{
    [containerTitle setBackgroundColor:[UIColor blackColor]];
    containerTitle.font = [UIFont fontWithName:@"MyriadPro-Regular" size:17.f];
    containerTitle.textAlignment = NSTextAlignmentCenter;
    containerTitle.textColor = [UIColor whiteColor];
    containerTitle.text = @"Select a Starting Point";

    return containerTitle;
}

- (UILabel *)setupContainerDescription:(UILabel *)containerDescription
{
    containerDescription.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.f];
    containerDescription.textAlignment = NSTextAlignmentCenter;
    containerDescription.lineBreakMode = NSLineBreakByWordWrapping;
    containerDescription.numberOfLines = 0;
    containerDescription.minimumScaleFactor = 0.75;
    containerDescription.textColor = [UIColor darkGrayColor];
    containerDescription.text = @"We couldn't pinpoint your location. Please enable bluetooth and location services.";

    return containerDescription;
}

- (UISearchBar *)setupDestinationSearchBar:(UISearchBar *)destinationSearchBar
{
    destinationSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    destinationSearchBar.placeholder = @"Filter Locations";
    destinationSearchBar.delegate = self.modalSearchDelegatehandler;

    return destinationSearchBar;
}

- (UIButton *)setupCancelButton:(UIButton *)cancelButton
{
    [cancelButton setBackgroundColor:[UIColor lightGrayColor]];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(didPressCancel:) forControlEvents:UIControlEventTouchUpInside];

    return cancelButton;
}

- (void)didPressCancel:(id)sender
{
    if (self.cancelBlock)
    {
        self.cancelBlock();
    }
    
    [self removeFromSuperview];
}

- (UITableView *)setupDestinationSelectionTable
{
    self.modalTableDelegateHandler.selectionModalDelegate = self.selectionModalDelegate;
    
    UITableView *destinationSelection = self.dataList != nil ? self.dataList : [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    destinationSelection.dataSource = self.modalTableDelegateHandler;
    destinationSelection.delegate = self.modalTableDelegateHandler;
    
    return destinationSelection;
}

- (void)resetDestinationList
{
    self.modalTableDelegateHandler.displayData = self.dataSource;
    [self.dataList reloadData];
}

- (void)searchDelegate:(GAHSearchMeetingPlayDelegateHandler *)searchDelegate didFilterLocations:(NSArray *)filteredLocations
{
    self.modalTableDelegateHandler.displayData = filteredLocations;
    [self.dataList reloadData];
}

#pragma mark - Constraint Setup
- (void)setupConstraints
{
    // setup constraints
    
    NSArray *autoresizingMaskDisabled = @[self.containerTitle,self.containerDescription,self.dataSearchBar,self.dataListContainer,self.dataList,self.buttonsContainer,self.cancelButton];
    
    for (UIView *noAutoresizingMask in autoresizingMaskDisabled)
    {
        noAutoresizingMask.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    CGFloat defaultMargin = 10;
    
//    [destinationSelectionContainer.superview addConstraints:[destinationSelectionContainer pinToSuperviewBoundsConstant:defaultMargin]];
    
    [self.containerTitle addConstraint:[self.containerTitle height:34.f]];
    [self addConstraints:@[[self.containerTitle pinToTopSuperview:defaultMargin],[self.containerTitle pinLeading:defaultMargin],[self.containerTitle pinTrailing:defaultMargin]]];
    
    [self.containerDescription addConstraint:[self.containerDescription height:44.f]];
    [self addConstraints:@[[self.containerDescription pinSide:NSLayoutAttributeTop toView:self.containerTitle secondViewSide:NSLayoutAttributeBottom],
                                                    [self.containerDescription pinLeading:defaultMargin],
                                                    [self.containerDescription pinTrailing:defaultMargin]]];
    
    CGFloat searchBarHeight = 0;
    if (self.showsSearchBar)
    {
        searchBarHeight = 44.f;
    }
    [self.dataSearchBar addConstraint:[self.dataSearchBar height:searchBarHeight]];
    [self addConstraints:@[[self.dataSearchBar pinSide:NSLayoutAttributeTop toView:self.containerDescription secondViewSide:NSLayoutAttributeBottom constant:3],
                                                    [self.dataSearchBar pinLeading:defaultMargin],
                                                    [self.dataSearchBar pinTrailing:defaultMargin]]];
    
    [self addConstraints:@[[self.dataListContainer pinSide:NSLayoutAttributeTop toView:self.dataSearchBar secondViewSide:NSLayoutAttributeBottom constant:0],
                                                    [self.dataListContainer pinSide:NSLayoutAttributeBottom toView:self.buttonsContainer secondViewSide:NSLayoutAttributeTop],
                                                    [self.dataListContainer pinLeading:defaultMargin],
                                                    [self.dataListContainer pinTrailing:defaultMargin]]];
    
    [self.dataListContainer addConstraints:[self.dataList pinToSuperviewBounds]];
    
    [self.buttonsContainer addConstraint:[self.buttonsContainer height:44]];
    [self addConstraints:@[[self.buttonsContainer pinSide:NSLayoutAttributeTop toView:self.dataListContainer secondViewSide:NSLayoutAttributeBottom],
                                                    [self.buttonsContainer pinLeading:defaultMargin],
                                                    [self.buttonsContainer pinTrailing:defaultMargin],
                                                    [self.buttonsContainer pinToBottomSuperview:defaultMargin]]];
    
    [self.buttonsContainer addConstraints:[self.cancelButton pinToSuperviewBoundsInsets:UIEdgeInsetsMake(5, 0, 0, 0)]];
}

@end
