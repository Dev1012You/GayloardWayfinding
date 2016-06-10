//
//  GAHCategoriesViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/25/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHCategoriesViewController.h"
#import "GAHPropertyCategory.h"
#import "EventKeys.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "CHAFontAwesome.h"
#import "UIView+AutoLayoutHelper.h"
#import "UIColor+GAHCustom.h"

@interface GAHArrowView : UIView
@property (nonatomic, strong) CAShapeLayer *arrowCircle;
@property (nonatomic, assign) BOOL pointingRight;
@property (nonatomic, assign) CGRect previousFrame;
@end

@implementation GAHArrowView

+ (instancetype)arrowView:(BOOL)pointRight
{
    GAHArrowView *arrowContainer = [GAHArrowView new];
    arrowContainer.translatesAutoresizingMaskIntoConstraints = false;
    arrowContainer.pointingRight = pointRight;
    
    UIView *circleContainer = [UIView new];
    circleContainer.translatesAutoresizingMaskIntoConstraints = false;
    [arrowContainer addSubview:circleContainer];
    [arrowContainer addConstraints:[circleContainer pinToSuperviewBounds]];
    
    arrowContainer.arrowCircle = [CAShapeLayer layer];
    arrowContainer.arrowCircle.fillColor = [UIColor gaylordBlue:0.8].CGColor;
    [circleContainer.layer insertSublayer:arrowContainer.arrowCircle atIndex:0];

    UILabel *arrowLabel = [UILabel new];
    arrowLabel.translatesAutoresizingMaskIntoConstraints = false;
    [arrowContainer addSubview:arrowLabel];
    [arrowContainer addConstraints:[arrowLabel pinSides:@[@(NSLayoutAttributeTop),@(NSLayoutAttributeBottom)] constant:0]];
    [arrowContainer addConstraint:(pointRight ? [arrowLabel pinTrailing:3] : [arrowLabel pinLeading:3])];
    
    arrowLabel.font = [UIFont fontWithName:@"FontAwesome" size:11.f];
    arrowLabel.textAlignment = NSTextAlignmentCenter;
    arrowLabel.textColor = [UIColor whiteColor];
    arrowLabel.text = pointRight ? [CHAFontAwesome faChevronRight] : [CHAFontAwesome faChevronLeft];
    
    arrowContainer.previousFrame = CGRectZero;
    
    return arrowContainer;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect containerFrame = self.bounds;
    if (CGRectEqualToRect(self.previousFrame, containerFrame) == NO)
    {
        containerFrame.size.width = containerFrame.size.width * 2;
        if (!self.pointingRight)
        {
            containerFrame.origin = CGPointMake(-10, 0);
        }
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:containerFrame];
        _arrowCircle.path = bezierPath.CGPath;
        _arrowCircle.frame = containerFrame;
    }
    
    self.previousFrame = containerFrame;
}
@end


@interface GAHCategoriesViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic, assign,getter=isFirstLoad) BOOL firstLoad;

@property (nonatomic, strong) GAHArrowView *pointingRight;
@property (nonatomic, strong) GAHArrowView *pointingLeft;

@end

@implementation GAHCategoriesViewController

static NSString * const reuseIdentifier = @"GAHCategoryCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
    self.firstLoad = true;
    
    self.grayBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 5)];
    self.grayBar.translatesAutoresizingMaskIntoConstraints = false;
    self.grayBar.backgroundColor = [UIColor lightGrayColor];
    [self.view insertSubview:self.grayBar belowSubview:self.collectionView];
    self.grayBar.hidden = true;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupArrowViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isFirstLoad)
    {
        self.firstLoad = false;
        
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                          animated:true
                                    scrollPosition:UICollectionViewScrollPositionNone];
        
        if (self.categoryDataSource.count > 0)
        {
            self.currentCategory = self.categoryDataSource[0];
            
            if (self.categoryDelegate && [self.categoryDelegate respondsToSelector:@selector(categoryView:didSelectCategory:)])
            {
                [self.categoryDelegate categoryView:self didSelectCategory:self.currentCategory];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.categoryDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GAHCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    [self configureCell:cell atIndexPath:indexPath inCollection:self.categoryDataSource];
    return cell;
}

- (void)configureCell:(GAHCategoryCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
         inCollection:(NSArray *)dataSource
{
    GAHPropertyCategory *category = dataSource[indexPath.row];
    cell.categoryLabel.text = category.categoryName.uppercaseString;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
    
    if (self.categoryDelegate && [self.categoryDelegate respondsToSelector:@selector(categoryView:didSelectCategory:)])
    {
        [self.categoryDelegate categoryView:self didSelectCategory:self.categoryDataSource[indexPath.row]];
    }
}

- (GAHPropertyCategory *)categoryByName:(NSString *)categoryName
{
    __block GAHPropertyCategory *matchingCategory = nil;
    
    [self.categoryDataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([[obj categoryName] isEqualToString:categoryName])
        {
            matchingCategory = obj;
            *stop = true;
        }
    }];
    
    return matchingCategory;
}

- (void)loadCategories:(NSArray *)categories
{
    self.categoryDataSource = categories;
    [self.collectionView reloadData];
}

#pragma mark - Arrow Views
- (void)setupArrowViews
{
    self.pointingLeft = [self arrowView:false];
    [self.pointingLeft addConstraint:[self.pointingLeft width:20]];
    [self.pointingLeft addConstraint:[self.pointingLeft height:40]];
    [self.view addSubview:self.pointingLeft];
    
    [self.view addConstraints:@[[self.pointingLeft pinSide:NSLayoutAttributeLeading
                                                    toView:self.pointingLeft.superview
                                            secondViewSide:NSLayoutAttributeLeading],
                                [self.pointingLeft pinToBottomSuperview]]];
    
    self.pointingRight = [self arrowView:true];
    [self.pointingRight addConstraint:[self.pointingRight width:20]];
    [self.pointingRight addConstraint:[self.pointingRight height:40]];
    
    [self.view addSubview:self.pointingRight];
    [self.view addConstraints:@[[self.pointingRight pinSide:NSLayoutAttributeTrailing
                                                    toView:self.pointingRight.superview
                                            secondViewSide:NSLayoutAttributeTrailing],
                               [self.pointingRight pinToBottomSuperview]]];
}

- (GAHArrowView *)arrowView:(BOOL)pointRight
{
    GAHArrowView *arrow = [GAHArrowView arrowView:pointRight];
    return arrow;
}

@end

@implementation GAHCategoryCell

- (void)setSelected:(BOOL)selected
{
    if (selected)
    {
        self.selectionIndicator.backgroundColor = kTan;
    }
    else
    {
        self.selectionIndicator.backgroundColor = [UIColor lightGrayColor];
    }
}

@end
