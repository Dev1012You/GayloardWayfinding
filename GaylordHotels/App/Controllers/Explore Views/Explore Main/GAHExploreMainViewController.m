//
//  GAHExploreMainViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHExploreMainViewController.h"
#import "GAHContentViewController.h"
#import "GAHCategoriesViewController.h"
#import "GAHBaseNavigationController.h"

#import "GAHDataSource.h"
#import "GAHMapDataSource.h"
#import "GAHPropertyCategory.h"
#import "GAHDestination.h"
#import "GAHAPIDataInitializer.h"

#import "MDCustomTransmitter+NetworkingHelper.h"

#import "GAHStoryboardIdentifiers.h"
#import "UIView+AutoLayoutHelper.h"

#import "UIButton+GAHCustomButtons.h"
#import "UIButton+MTPNavigationBar.h"

@interface GAHExploreMainViewController () <GAHCategoryFilterDelegate,GAHCategorySelectable,GAHMapScrollHidingDelegate>

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSLayoutConstraint *headerContainerHeight;

@property (nonatomic, assign) BOOL displayCategorySelection;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *categoryContainerHeight;
@property (nonatomic, strong) GAHCategoriesViewController *categoriesController;
@property (weak, nonatomic) IBOutlet UIView *categoryContainer;

@property (nonatomic, strong) GAHMapScrollHandler *mapScrollHandler;
@end

@implementation GAHExploreMainViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldHideOnToggle = false;

    [self.view sendSubviewToBack:self.mainMenuContainer];

    for (UIViewController *childViewController in self.childViewControllers)
    {
        if ([childViewController isKindOfClass:[GAHContentViewController class]])
        {
            self.contentCollectionViewController = (GAHContentViewController *)childViewController;
        }
    }
    
    self.categoriesController = [self setupCategorySelection];
    
    self.mapScrollHandler = [GAHMapScrollHandler new];
    self.mapScrollHandler.hidingDelegate = self;

    self.mapScrollHandler.categoryContainerHeight = self.categoryContainerHeight;
    
    [self setupMapView];
    self.mapScrollHandler.zoomDelegate = self.mapViewController;
    
    [self setupContentCollectionView];
    
    [self setupNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false];
    
    self.title = @"Navigate Our Resort".uppercaseString;
    
    if (self.contentData.data.count == 0)
    {
        self.contentData = [self loadData:self.dataInitializer.meetingPlayLocations];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initial Setup

- (GAHCategoriesViewController *)setupCategorySelection
{
    GAHCategoriesViewController *categoryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GAHCategoriesViewController"];
    categoryViewController.view.translatesAutoresizingMaskIntoConstraints = false;
    categoryViewController.categoryDelegate = self;
    
    [self.categoryContainer addSubview:categoryViewController.view];
    [self.categoryContainer addConstraints:[categoryViewController.view pinToSuperviewBounds]];
    
    return categoryViewController;
}

- (void)setupMapView
{
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:GAHMapViewControllerIdentifier];
    self.mapViewController.view.translatesAutoresizingMaskIntoConstraints = false;
    [self addChildViewController:self.mapViewController];
    [self.headerContainer addSubview:self.mapViewController.view];
    [self.headerContainer addConstraints:[self.mapViewController.view pinToSuperviewBounds]];
    
    if (self.mapViewController)
    {
        self.mapViewController.dataInitializer = self.dataInitializer;
        
        self.mapViewController.floorSelectorContainer.hidden = false;
        [self.mapViewController setupFloorSelectorConstraints];
        
        self.mapViewController.mapViewDelegate = self;
        
        __weak __typeof(&*self)weakSelf = self;
        [self.mapViewController loadMapZoomToDestination:nil zoomScale:defaultZoomScale animated:true completionHandler:^{
            [weakSelf loadPropertyCategories:weakSelf.dataInitializer.meetingPlayCategories];
        }];
        
        self.mapViewController.mapContainerScrollView.delegate = self.mapScrollHandler;
    }
}

- (void)setupContentCollectionView
{
    if (self.contentCollectionViewController)
    {
        self.contentCollectionViewController.mapDataSource = self.dataInitializer.mapDataSource;
        self.contentCollectionViewController.filterDelegate = self;
        
        self.contentCollectionViewController.rootNavigationController = self.rootNavigationController;
        self.contentCollectionViewController.dataInitialzer = self.dataInitializer;
        
        self.contentCollectionViewController.directionsLoader = self.directionsLoader;
        
        self.contentData = [self loadData:self.dataInitializer.meetingPlayLocations];
        
        [self.contentCollectionViewController configureCollectionView:self.contentCollectionViewController.contentCollectionView
                                                             withData:self.contentData];
        
        self.contentCollectionViewController.beaconManager = self.beaconManager;
    }
    
    if (self.currentCategory)
    {
        [self.contentCollectionViewController displayCategory:self.currentCategory];
    }
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetchMeetingPlayDestinations:) name:@"MTP_DidFetchMeetingPlayDestinations" object:nil];
}

- (void)didFetchMeetingPlayDestinations:(NSNotification *)notification
{
    [self setupContentCollectionView];
}

- (void)refreshViews:(id)sender
{
    [self.mapViewController loadMap:true];
    [self setupContentCollectionView];
}

- (GAHDataSource *)loadData:(NSArray *)destinations
{
    GAHDataSource *meetingPlayDataSource = [[GAHDataSource alloc] init];
    meetingPlayDataSource.data = destinations;
    return meetingPlayDataSource;
}

#pragma mark - Protocol Conformance
- (void)mapViewDidToggleSize:(GAHMapViewSize)mapSize
{
    return;
}

- (void)changeMapContainerConstraints:(GAHMapViewSize)targetMapSize
{
    NSLayoutConstraint *heightConstraint;
    
    for (NSLayoutConstraint *constraint in self.headerContainer.superview.constraints)
    {
        if (constraint.firstAttribute == NSLayoutAttributeHeight
            && (constraint.firstItem == self.headerContainer || constraint.secondItem == self.headerContainer))
        {
            heightConstraint = constraint;
        }
    }
    
    if (heightConstraint)
    {
        [self.headerContainer.superview removeConstraint:heightConstraint];
        
        static CGFloat changeToSmallSize = 0.4f;
        static CGFloat changeToLargeSize = 0.6f;
        
        CGFloat newConstraintMultipler = (targetMapSize == GAHMapViewSizeLarge) ? changeToLargeSize : changeToSmallSize;
        
        [self setupRightBarItem:(newConstraintMultipler == changeToLargeSize)];
        
        [self.headerContainer.superview addConstraint:[self.headerContainer equalHeight:newConstraintMultipler]];
        
        [UIView animateWithDuration:0.5f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished)
         {
             self.mapViewController.animatingMapContainer = false;
         }];
    }
}
#pragma mark Category Selection
- (void)categoryView:(GAHCategoriesViewController *)categoryController didSelectCategory:(GAHPropertyCategory *)propertyCategory
{
    [self.contentCollectionViewController displayCategory:propertyCategory];
    
    NSMutableArray *destinationsInCategory = [NSMutableArray new];
    for (GAHDestination *destination in self.dataInitializer.meetingPlayLocations)
    {
        if ([destination.category isEqualToString:propertyCategory.categoryName])
        {
            [destinationsInCategory addObject:destination];
        }
    }
    
    [self.mapViewController loadDestinations:destinationsInCategory];
}

#pragma mark Category Display

- (void)mapView:(GAHMapViewController *)mapView didSelectDestination:(GAHDestination *)selectedDestination
{
    [self.contentCollectionViewController mapView:mapView didSelectDestination:selectedDestination];
}

#pragma mark Content FilterDelegate
- (void)contentView:(GAHContentViewController *)contenView didStartFilter:(UISearchBar *)filterBar
{
    [self growHeaderSize:false animated:true];
}

- (void)contentView:(GAHContentViewController *)contenView didEndFilter:(UISearchBar *)filterBar
{
    [self growHeaderSize:true animated:true];
}

#pragma mark Hiding Delegate
- (void)scrollHandler:(GAHMapScrollHandler *)scrollHandler toggleSelectorVisiblity:(BOOL)hidden
{
    CGPoint mapOffset = self.mapViewController.mapContainerScrollView.contentOffset;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.categoryContainerHeight.constant = hidden ? 0 : 50;
        if (mapOffset.y == 0)
        {
            CGPoint offsetForCategoryContainer = CGPointMake(self.mapViewController.mapContainerScrollView.contentOffset.x,
                                                             self.mapViewController.mapContainerScrollView.contentOffset.y - self.categoryContainerHeight.constant);
            
            self.mapViewController.mapContainerScrollView.contentOffset = offsetForCategoryContainer;
        }

        self.categoriesController.view.hidden = hidden;
        self.mapViewController.floorSelectionButton.hidden = hidden;
    }];
}

#pragma mark - IBActions
- (IBAction)returnPrevious:(id)sender
{
    [self.mapViewController.userLocationUpdateTimer invalidate];
    self.mapViewController.userLocationUpdateTimer = nil;

    [super returnToPrevious:sender];
}

#pragma mark - Helper Methods
- (void)loadPropertyCategories:(NSArray *)propertyCategories
{
    if (propertyCategories.count > 0)
    {
        [self.categoriesController loadCategories:propertyCategories];
        
        NSInteger categoryCount = [self.categoriesController.collectionView.dataSource collectionView:self.categoriesController.collectionView numberOfItemsInSection:0];
        
        if (propertyCategories.count > 0 && categoryCount > 0)
        {
            [self.categoriesController.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:true scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            
            GAHPropertyCategory *categoryDefault = propertyCategories[0];
            [self.categoriesController setCurrentCategory:categoryDefault];
            [self categoryView:self.categoriesController didSelectCategory:categoryDefault];
        }
        else
        {
            DLog(@"\ncategory count was zero");
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [self showDataError];
        });
    }
    
    //    [MBProgressHUD hideAllHUDsForView:self.view animated:true];
}

#pragma mark - Initial Setup
+ (instancetype)loadWithDestinations:(NSArray *)destinations
                          headerData:(GAHDataSource *)headerData
                         contentData:(GAHDataSource *)contentData
                      fromStoryboard:(UIStoryboard *)storyboard
                       andIdentifier:(NSString *)storyboardIdentifier
{
    return [[GAHExploreMainViewController alloc] initWithDestinations:destinations
                                                           headerData:headerData
                                                          contentData:contentData
                                                       fromStoryboard:storyboard
                                                        andIdentifier:storyboardIdentifier];
}

- (instancetype)initWithDestinations:(NSArray *)destinations
                          headerData:(GAHDataSource *)headerData
                         contentData:(GAHDataSource *)contentData
                      fromStoryboard:(UIStoryboard *)storyboard
                       andIdentifier:(NSString *)storyboardIdentifier
{
    NSAssert(storyboard != nil, @"You must provide a storyboard when instantiating GAHExploreMainViewController in this manner");
    
    self = [storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    
    if (self)
    {
        _headerData = headerData;
        _contentData = contentData;
    }
    return self;
}

- (void)setupRightBarItem:(BOOL)showExpandIcon
{
    [[self navigationItem] setRightBarButtonItem:[UIButton refreshMenuButton:@{@"fontAwesomeCode": (showExpandIcon ? @"\uf102" : @"\uf103")}
                                                                      target:self.mapViewController
                                                                    selector:nil]];
}

#pragma mark - Constraint Setup
- (void)setupConstraints
{
    [super setupConstraints];
    
    self.headerContainer.translatesAutoresizingMaskIntoConstraints = false;
    self.contentContainer.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.headerContainer.superview addConstraints:[self.headerContainer pinSides:@[@(NSLayoutAttributeTop),@(NSLayoutAttributeLeading)]
                                                                         constant:0]];
    [self.headerContainer.superview addConstraint:[self.headerContainer equalWidth]];
//    [self.headerContainer.superview addConstraint:[self.headerContainer equalHeight:0.4f]];
    [self growHeaderSize:true animated:false];
    
    [self.contentContainer.superview addConstraints:[self.contentContainer pinSides:@[@(NSLayoutAttributeLeading),@(NSLayoutAttributeBottom)]
                                                                           constant:0]];
    [self.contentContainer.superview addConstraint:[self.contentContainer equalWidth]];
    
    [self.contentContainer.superview addConstraint:[self.contentContainer pinSide:NSLayoutAttributeTop
                                                                           toView:self.headerContainer
                                                                   secondViewSide:NSLayoutAttributeBottom]];
}

- (void)growHeaderSize:(BOOL)shouldGrow animated:(BOOL)animated
{
    [self.headerContainer.superview removeConstraint:self.headerContainerHeight];
    
    CGFloat targetHeight = 0.2f;
    if (shouldGrow)
    {
        targetHeight = 0.4f;
    }
    
    self.headerContainerHeight = [self.headerContainer equalHeight:targetHeight];
    
    [self.headerContainer.superview addConstraint:self.headerContainerHeight];
    
    if (animated)
    {
        [UIView animateWithDuration:.35f delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

- (void)removeSuperviewConstraintsForView:(UIView *)constraintRemovalView
{
    NSMutableArray *taggedForRemoval = [NSMutableArray new];
    
    for (NSLayoutConstraint *constraint in constraintRemovalView.superview.constraints)
    {
        if ([[constraint firstItem] isEqual:self.headerContainer])
        {
            [taggedForRemoval addObject:constraint];
        }
        
        if ([[constraint secondItem] isEqual:self.headerContainer])
        {
            [taggedForRemoval addObject:constraint];
        }
    }
    
    [constraintRemovalView.superview removeConstraints:taggedForRemoval];
}

@end




#pragma mark - GAHMapScrollHandler

@implementation GAHMapScrollHandler
#pragma mark ScrollView Zooming
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.zoomDelegate && [self.zoomDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
    {
        return [self.zoomDelegate viewForZoomingInScrollView:scrollView];
    }
    else
    {
        return nil;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if (self.zoomDelegate && [self.zoomDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
    {
        [self.zoomDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (self.zoomDelegate && [self.zoomDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
    {
        [self.zoomDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

#pragma mark ScrollView element hiding
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.categoryContainerHeight.constant > 0)
    {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y);
        self.shouldHideCategories = true;
        [self hideScrollView:scrollView selectors:true];
    }
    else
    {
        self.shouldHideCategories = false;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self hideScrollView:scrollView selectors:false];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.shouldHideCategories)
    {
        [self hideScrollView:scrollView selectors:false];
    }
}

- (void)hideScrollView:(UIScrollView *)scrollView selectors:(BOOL)isHidden
{
    if (self.hidingDelegate && [self.hidingDelegate respondsToSelector:@selector(scrollHandler:toggleSelectorVisiblity:)])
    {
        [self.hidingDelegate scrollHandler:self toggleSelectorVisiblity:isHidden];
    }
}

@end