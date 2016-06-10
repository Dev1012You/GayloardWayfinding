//
//  GAHMainMenuViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHMainMenuViewController.h"
#import "UIView+AutoLayoutHelper.h"
#import "GAHStoryboardIdentifiers.h"
#import "GAHBaseViewController.h"

#import "MTPMenuItem.h"
#import "MTPMenuIcon.h"

#import "MTPAppSettingsKeys.h"

@interface GAHMainMenuViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UILabel *headerIcon;
@property (weak, nonatomic) IBOutlet UITextField *headerSearchField;
@property (weak, nonatomic) IBOutlet UILabel *searchIcon;

@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIImageView *footerImage;

@end

@implementation GAHMainMenuViewController

@dynamic rootNavigationController;

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:UIColorFromRGB(0x111c25)];
    
    [self setupConstraints];
    
    [self setupHeaderView:self.headerView];
    [self setupFooterView:self.footerView];
    
    [self setupMainMenuTableView:self.mainMenuTableView];
    
    self.parsedMenuItems = [self loadMenuData:self.mainMenuItems];
}

#pragma mark - Protocol Conformance

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.parsedMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GAHMainMenuCell *cell = (GAHMainMenuCell *)[tableView dequeueReusableCellWithIdentifier:GAHMainMenuCellIdentifier
                                                                                forIndexPath:indexPath];
    
    cell = (GAHMainMenuCell *)[self configureTableView:tableView
                                                  cell:cell
                                              cellData:self.parsedMenuItems
                                             indexPath:indexPath];
    return cell;
}

- (UITableViewCell *)configureTableView:(UITableView *)tableView
                                   cell:(GAHMainMenuCell *)cell
                               cellData:(id)cellData
                              indexPath:(NSIndexPath *)indexPath
{
    MTPMenuItem *menuItem = [cellData objectAtIndex:indexPath.row];
    
    cell.menuItemIconLabel.text = nil;
    cell.menuItemIconImage.image = nil;
    cell.menuItemLabel.text = nil;
    
    if (menuItem.icon.fontAwesomeCode.length > 0)
    {
        cell.menuItemIconLabel.text = menuItem.icon.fontAwesomeCode;
    }
    else if (menuItem.icon.resourceName.length > 0)
    {
        UIImage *iconImage = [[UIImage imageNamed:menuItem.icon.resourceName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (iconImage)
        {
            cell.menuItemIconImage.image = iconImage;
        }
    }
    
    cell.menuItemLabel.text = menuItem.title.uppercaseString;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *containerView = [UIView new];
    
    UIImageView *footerImage = [UIImageView new];
    footerImage.translatesAutoresizingMaskIntoConstraints = false;
    [containerView addSubview:footerImage];
    
    [containerView addConstraints:@[[footerImage pinToTopSuperview:20],
                                    [footerImage equalWidth:0.65],
                                    [footerImage proportionalHeightForWidth:(999/255.f)],
                                    [footerImage alignCenterHorizontalSuperview]]];

    footerImage.image = [UIImage imageNamed:@"footerIcon"];
    
    return containerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    [self processTableView:tableView
                 selection:indexPath
                 tableData:self.parsedMenuItems];
}

#pragma mark UITextField Protocol
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:true];
    return true;
}

#pragma mark - IBActions
- (IBAction)didPressHome:(id)sender
{
    MTPMenuItem *homeItem = [MTPMenuItem menuItemFromDictionary:[[self.userDefaults objectForKey:@"MTP_HomeScreen"] firstObject]];
    [self loadMainMenuItem:homeItem];
    
    [self.view endEditing:true];
}

- (IBAction)didPressSearch:(id)sender
{
    if (self.searchField.text.length < 1)
    {
        return;
    }
    
    [self.view endEditing:true];
    
    NSDictionary *searchMenuItemDictionary = [[self.userDefaults objectForKey:@"MTP_LocationSearch"] firstObject];
    MTPMenuItem *locationSearch = [MTPMenuItem menuItemFromDictionary:searchMenuItemDictionary];
    
    NSMutableDictionary *newLocationSearchDetails = [NSMutableDictionary dictionaryWithDictionary:[[locationSearch additionalData] firstObject]];
    
    NSMutableDictionary *searchViewControllerConfigurationDataSrouce =
    [[NSMutableDictionary alloc] initWithDictionary:[newLocationSearchDetails
                                                     objectForKey:@"additionalData"]];
    [searchViewControllerConfigurationDataSrouce setObject:self.searchField.text
                                                    forKey:@"searchTerm"];
    [newLocationSearchDetails setObject:searchViewControllerConfigurationDataSrouce forKey:@"additionalData"];
    
    NSArray *newAdditionalData = [NSArray arrayWithObject:newLocationSearchDetails];
    locationSearch.additionalData = newAdditionalData;

    [self loadMainMenuItem:locationSearch];
}

- (void)didPressSocial:(id)sender
{
    if ([self.parentViewController isKindOfClass:[GAHBaseViewController class]])
    {
        GAHBaseViewController *baseViewController = (GAHBaseViewController *)self.parentViewController;
        [baseViewController toggleSocialView:sender];
    }
}

- (void)didPressFeedback:(id)sender
{
    if ([self.parentViewController isKindOfClass:[GAHBaseViewController class]])
    {
        GAHBaseViewController *baseViewController = (GAHBaseViewController *)self.parentViewController;
        [baseViewController presentFeedback];
    }
}

#pragma mark - Helper Methods
- (void)processTableView:(UITableView *)tableView
               selection:(NSIndexPath *)indexPath
               tableData:(id)tableData
{
    if ([tableData isKindOfClass:[NSArray class]])
    {
        MTPMenuItem *menuItem = [tableData objectAtIndex:indexPath.row];
        if ([menuItem.title caseInsensitiveCompare:@"get social!"] == NSOrderedSame)
        {
            [self didPressSocial:nil];
        }
        else if ([menuItem.title caseInsensitiveCompare:@"app feedback"] == NSOrderedSame)
        {
            [self didPressFeedback:nil];
        }
        else
        {
            [self loadMainMenuItem:menuItem];
        }
    }
}

#pragma mark - Initial Setup

- (NSArray *)loadMenuData:(NSArray *)mainMenuItems
{
    NSArray *parsedMenuItems = [NSArray new];
    NSString *keyForMenuSection = [[[mainMenuItems firstObject] allKeys] firstObject];
    if (keyForMenuSection)
    {
        parsedMenuItems = [[mainMenuItems firstObject] objectForKey:keyForMenuSection];
    }
    return parsedMenuItems;
}

- (void)setupHeaderView:(UIView *)headerView
{
    headerView.backgroundColor = kTan;
    
    NSAttributedString *placeHolder = [[NSAttributedString alloc] initWithString:@"Search"
                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.searchField.attributedPlaceholder = placeHolder;
}

- (void)setupFooterView:(UIView *)footerView
{
//    self.footerImage.image = [UIImage imageNamed:@"footerIcon"];
//    self.footerImage.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setupMainMenuTableView:(UITableView *)menuTableView
{
    menuTableView.rowHeight = 50.f;
    menuTableView.separatorInset = UIEdgeInsetsZero;
    if ([menuTableView respondsToSelector:@selector(layoutMargins)])
    {
        menuTableView.layoutMargins = UIEdgeInsetsZero;
    }
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    return;
}

@end





@implementation GAHMainMenuCell

const CGFloat defaultMarginWidth = 5.f;

- (void)awakeFromNib
{
    if ([self respondsToSelector:@selector(layoutMargins)])
    {
        self.layoutMargins = UIEdgeInsetsZero;
    }

    self.menuItemIconLabel.textAlignment = NSTextAlignmentCenter;
    self.menuItemIconLabel.textColor = [UIColor whiteColor];
    self.menuItemLabel.textColor = [UIColor whiteColor];
    self.menuItemIconImage.tintColor = [UIColor whiteColor];
    
    [self setupCustomStyling];
}

- (void)setupCustomStyling
{
    NSDictionary *mainMenuFontStyling = [[self.userDefaults objectForKey:MTP_MainMenuOptions] objectForKey:MTP_MainMenuFontDescription];
    
    NSString *defaultMainMenuFontName = [mainMenuFontStyling objectForKey:MTP_MainMenuFontName];
    if (defaultMainMenuFontName)
    {
        NSNumber *defaultFontSize = [mainMenuFontStyling objectForKey:MTP_MainMenuFontSize];
        if (!defaultFontSize)
        {
            defaultFontSize = [mainMenuFontStyling objectForKey:MTP_MainMenuDefaultFontSize];
        }
        self.menuItemLabel.font = [UIFont fontWithName:defaultMainMenuFontName size:defaultFontSize.floatValue];
    }
    
    NSNumber *defaultIconSize = [mainMenuFontStyling objectForKey:@"iconFontSize"];
    if (defaultIconSize)
    {
        self.menuItemIconLabel.font = [UIFont fontWithName:@"FontAwesome" size:defaultIconSize.floatValue];
    }
    else
    {
        self.menuItemIconLabel.font = [UIFont fontWithName:@"FontAwesome" size:[[mainMenuFontStyling objectForKey:@"defaultIconFontSize"] floatValue]];
    }
}

@end