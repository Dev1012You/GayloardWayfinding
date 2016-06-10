//
//  GAHCategoriesViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/25/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAHCategoriesViewController, GAHPropertyCategory;

@protocol GAHCategorySelectable <NSObject>

- (void)categoryView:(GAHCategoriesViewController *)categoryController
   didSelectCategory:(GAHPropertyCategory *)propertyCategory;

@end

@interface GAHCategoriesViewController : UICollectionViewController

@property (nonatomic, strong) NSArray *categoryDataSource;
@property (nonatomic, weak) id <GAHCategorySelectable> categoryDelegate;
@property (nonatomic, strong) GAHPropertyCategory *currentCategory;
@property (nonatomic, strong) UIView *grayBar;

- (void)loadCategories:(NSArray *)categories;
//- (void)updateCategory:(GAHPropertyCategory *)newCategory;

@end

@interface GAHCategoryCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIView *selectionIndicator;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@end