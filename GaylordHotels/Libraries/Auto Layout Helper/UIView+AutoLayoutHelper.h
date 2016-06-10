//
//  UIView+AutoLayoutHelper.h
//
//  Created by John Pacheco on 3/25/15.
//  Copyright (c) 2015 Chisel Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoLayoutHelper)
 
#pragma mark - Pinning
/**
 @description Pin the receiving view's leading edge to its superview's leading edge
 @return A constraint item that relates the receiving view's and its superview's leading constraints
 */
- (NSLayoutConstraint *)pinLeading;
/**
 @description Pin the receiving view's leading edge to its superview's leading edge
 @param constant CGFloat representing a constant distance between the receiving view and its superview
 @return A constraint item that relates the receiving view's and its superview's leading constraints
 */
- (NSLayoutConstraint *)pinLeading:(CGFloat)constant;

/**
 @description Pin the receiving view's trailing edge to its superview's trailing edge
 @return A constraint item that relates the receiving view's and its superview's trailing constraints
 */
- (NSLayoutConstraint *)pinTrailing;
/**
 @description Pin the receiving view's trailing edge to the superview's trailing edge
 @param constant CGFloat representing a constant distance between the receiving view and its superview
 @return A constraint item that relates the receiving view's and its superview's trailing constraints
 */
- (NSLayoutConstraint *)pinTrailing:(CGFloat)constant;

/**
 @description Pin the receiving view's leading edge and trailing edge to its superview's corresponding leading and trailing edges
 @return A constraint item that relates the receiving view's and its superview's leading and trailing constraints
 */
- (NSArray *)pinLeadingTrailing;
/**
 @description Pin the receiving view's leading edge and trailing edge to its superview's corresponding leading and trailing edges
 @param constant CGFloat representing a constant distance between the receiving view and its superview's leading and trailing edges
 @return A constraint item that relates the receiving view's and its superview's leading and trailing constraints
 */
- (NSArray *)pinLeadingTrailing:(CGFloat)constant;

/**
 @description Pin the receiving view's top side to the view controller's top layout guide
 @param containerViewController The view controller that contain's your target top layout guide
 @return A constraint item that relates the receiving view's top side and a view controller's top layout guide
 */
- (NSLayoutConstraint *)pinToTopLayoutGuide:(UIViewController *)containerViewController;
/**
 @description Pin the receiving view's top edge to the superview's top edge
 @return A constraint item that relates the receiving view's and its superview's top edge
 */
- (NSLayoutConstraint *)pinToTopSuperview;
/**
 @description Pin the receiving view's top edge to the superview's top edge
 @param constant CGFloat representing a constant distance between the receiving view and its superview's top edge
 @return A constraint item that relates the receiving view's and its superview's top edge
 */
- (NSLayoutConstraint *)pinToTopSuperview:(CGFloat)constant;

/**
 @description Pin the receiving view's bottom edge to a view controller's bottom layout guide
 @param containerViewController The view controller that contain's your target bottom layout guide
 @return A constraint item that relates the receiving view's bottom edge and a view controller's bottom layout guide
 */
- (NSLayoutConstraint *)pinToBottomLayoutGuide:(UIViewController *)containerViewController;
/**
 @description Pin the receiving view's bottom edge to the superview's bottom edge
 @return A constraint item that relates the receiving view's and its superview's bottom edge
 */
- (NSLayoutConstraint *)pinToBottomSuperview;
/**
 @description Pin the receiving view's bottom edge to the superview's bottom edge
 @param constant CGFloat representing a constant distance between the receiving view and its superview's bottom edge
 @return A constraint item that relates the receiving view's and its superview's bottom edge
 */
- (NSLayoutConstraint *)pinToBottomSuperview:(CGFloat)constant;

/**
 @description Pin the receiving view's edges to its superview's corresponding edges
 @return An array of constraint items that relates the receiving view's edges and its superview's corresponding edges
 */
- (NSArray *)pinToSuperviewBounds;
/**
 @description Pin the receiving view's edges to its superview's corresponding edges
 @param constant CGFloat representing a constant distance between the receiving view's edge and the superview's edge
 @return An array of constraint items that relates the receiving view's edges and its superview's corresponding edges
 */
- (NSArray *)pinToSuperviewBoundsConstant:(CGFloat)constant;
/**
 @description Pin the receiving view's edges to its superview's corresponding edges
 @param edgeInsets An edge inset that defines the distance between the view and superview's corresponding edge
 @return An array of constraint items that relates the receiving view's edges and its superview's corresponding edges
 */
- (NSArray *)pinToSuperviewBoundsInsets:(UIEdgeInsets)edgeInsets;

/**
 @description Pin the receiving view's edge to the superview's corresponding edge
 @param viewSide An intended view's NSLayoutAttribute to be lined up with the superview's
 @param constant CGFloat representation of the distance between the intended view's NSLayoutAttribute and the superview's NSLayoutAttribute
 @return A constraint item that relates the receiving view's NSLayoutAttribute with the superview's NSLayoutAttribute
 */
- (NSLayoutConstraint *)pinSide:(NSLayoutAttribute)viewSide
                       constant:(CGFloat)constant;
/**
 @description Pin the receiving view's edge to the superview's corresponding edge
 @param viewSide An intended view's NSLayoutAttribute to be lined up with the superview's
 @param layoutRelation The relationship between the actual value and the constant
 @param constant CGFloat representation of the distance between the intended view's NSLayoutAttribute and the superview's NSLayoutAttribute
 @return A constraint item that relates the receiving view's NSLayoutAttribute with the superview's NSLayoutAttribute
 */
- (NSLayoutConstraint *)pinSide:(NSLayoutAttribute)viewSide
                       relation:(NSLayoutRelation)layoutRelation
                       constant:(CGFloat)constant;

/**
 @description Pin the receiving view's edges equally to the superview's corresponding edges
 @param viewSides An array of NSLayoutAttribute's as NSNumbers 
 @param constant CGFloat representation of the distance between the intended view's NSLayoutAttribute's and the superview's NSLayoutAttribute's
 @return An array of constraint items that relates the receiving view's NSLayoutAttribute's with the superview's NSLayoutAttribute's
 */
- (NSArray *)pinSides:(NSArray *)viewSides
             constant:(CGFloat)constant;

/**
 @description Pin the receiving view's NSLayoutAttribute to second view's selected NSLayoutAttribute
 @param viewSide The receiving view's NSLayoutAttribute to pin to a second view
 @param secondView The second view to which the receiving view will be pinned
 @param secondViewSide The second view's NSLayoutAttribute to which the receiving view's NSLayoutAttribute will be pinned
 @return A constraint item that relates the receiving view's NSLayoutAttribute with the second view's NSLayoutAttribute
 */
- (NSLayoutConstraint *)pinSide:(NSLayoutAttribute)viewSide
                         toView:(UIView *)secondView
                 secondViewSide:(NSLayoutAttribute)secondViewSide;
/**
 @description Pin the receiving view's NSLayoutAttribute to second view's selected NSLayoutAttribute
 @param viewSide The receiving view's NSLayoutAttribute to pin to a second view
 @param secondView The second view to which the receiving view will be pinned
 @param secondViewSide The second view's NSLayoutAttribute to which the receiving view's NSLayoutAttribute will be pinned
 @param constant CGFloat representation of a constant distance between the views's two sides
 @return A constraint item that relates the receiving view's NSLayoutAttribute with the second view's NSLayoutAttribute
 */
- (NSLayoutConstraint *)pinSide:(NSLayoutAttribute)viewSide
                         toView:(UIView *)secondView
                 secondViewSide:(NSLayoutAttribute)secondViewSide
                       constant:(CGFloat)constant;
/**
 @description A proxy method to pin any view's NSLayoutAttribute to a second view's NSLayoutAttribute
 @param firstView A view to pin to a second view
 @param viewSide A view's NSLayoutAttribute to pin to a second view's NSLayoutAttribute
 @param secondView A second view to which a first view should be pinned
 @param secondSide A second view's NSLayoutAttribute to which a first view's NSLayoutAttribute should be pinned
 @param constant CGFloat representation of a constant distance between two view's NSLayoutAttribute's
 @param multiplier Ratio of the constant value relating two views
 @return A constraint item that relates the first view's NSLayoutAttribute with the second view's NSLayoutAttribute
 */
- (NSLayoutConstraint *)pin:(UIView *)firstView
                       side:(NSLayoutAttribute)viewSide
                     toView:(UIView *)secondView
                 secondSide:(NSLayoutAttribute)secondSide
                   constant:(CGFloat)constant
                 multiplier:(CGFloat)multiplier;

#pragma mark - Alignment
/**
 @description Align the receiving view's vertical center to its superview's vertical center
 @return A constraint item that relates the receiving view's vertical center to its superview's vertical center
 */
- (NSLayoutConstraint *)alignCenterVerticalSuperview;
/**
 @description Align the receiving view's horizontal center to its superview's horizontal center
 @return A constraint item that relates the receiving view's vertical center to its superview's vertical center
 */
- (NSLayoutConstraint *)alignCenterHorizontalSuperview;
/**
 @description Align the receiving view's left edge to its superview's left edge
 @return A constraint item that relates the receiving view's left edge to its superview's left edge
 */
- (NSLayoutConstraint *)alignLeftSuperview;
/**
 @description Align the receiving view's right edge to its superview's right edge
 @return A constraint item that relates the receiving view's right edge to its superview's right edge
 */
- (NSLayoutConstraint *)alignRightSuperview;

/**
 @description Align the receiving view's top edge to its superview's top edge
 @return A constraint item that relates the receiving view's top edge to its superview's top edge
 */
- (NSLayoutConstraint *)alignTopSuperview;
/**
 @description Align the receiving view's top edge to the view controller's top layout guide
 @param containerViewController The view controller that contain's your target top layout guide
 @return A constraint item that relates the receiving view's top edge and a view controller's top layout guide
 */
- (NSLayoutConstraint *)alignTopLayoutGuide:(UIViewController *)containerViewController;

/**
 @description Align the receiving view's bottom edge to its superview's bottom edge
 @return A constraint item that relates the receiving view's bottom edge to its superview's bottom edge
 */
- (NSLayoutConstraint *)alignBottomSuperview;
/**
 @description Align the receiving view's bottom edge to a view controller's bottom layout guide
 @param containerViewController The view controller that contain's your target bottom layout guide
 @return A constraint item that relates the receiving view's bottom edge and a view controller's bottom layout guide
 */
- (NSLayoutConstraint *)alignBottomLayoutGuide:(UIViewController *)containerViewController;

/**
 @description Align several views's horizontal center to a single reference view's horizontal center
 @param viewsForCenterHorizontalAlignment All of the views that should share a horizontal center
 @param referenceView The reference view to which all other views will center themselves
 @return An array of constraint items that relates a collection of views and their horizontal centers to a reference view
 */
- (NSArray *)alignCenterHorizontal:(NSArray *)viewsForCenterHorizontalAlignment
                     referenceView:(UIView *)referenceView;
/**
 @description Align several views's vertical center to a single reference view's vertical center
 @param viewsForCenterVerticalAlignment All of the views that should share a vertical center
 @param referenceView The reference view to which all other views will center themselves
 @return An array of constraint items that relates a collection of views and their vertical centers to a reference view
 */
- (NSArray *)alignCenterVertical:(NSArray *)viewsForCenterVerticalAlignment
                   referenceView:(UIView *)referenceView;

/**
 @description Align the receiving view's NSLayoutAttribute to its superview's NSLayoutAttribute
 @param constant CGFloat representation of the distance between the recipient views NSLayoutAttribute and its superview
 @return A constraint item that relates the receiving view's NSLayoutAttribute to its superview's corresponding NSLayoutAttribute
 */
- (NSLayoutConstraint *)alignSide:(NSLayoutAttribute)firstSide
                         constant:(CGFloat)constant;

/**
 @description Align the receiving view's NSLayoutAttribute to second view's selected NSLayoutAttribute
 @param firstSide The receiving view's NSLayoutAttribute to align to a second view
 @param secondView The second view to which the receiving view will be aligned
 @param secondViewSide The second view's NSLayoutAttribute to which the receiving view's NSLayoutAttribute will be aligned
 @return A constraint item that relates the receiving view's NSLayoutAttribute with the second view's NSLayoutAttribute
 */
- (NSLayoutConstraint *)alignSide:(NSLayoutAttribute)firstSide
                           toView:(UIView *)secondView
                       secondSide:(NSLayoutAttribute)secondViewSide
                         constant:(CGFloat)constant;

/**
 @description A proxy method to aligns any view's NSLayoutAttribute to a second view's NSLayoutAttribute
 @param firstView A view to align to a second view
 @param viewSide A view's NSLayoutAttribute to align to a second view's NSLayoutAttribute
 @param secondView A second view to which a first view should be aligned
 @param secondSide A second view's NSLayoutAttribute to which a first view's NSLayoutAttribute should be aligned
 @param constant CGFloat representation of a constant distance between two view's NSLayoutAttribute's
 @param multiplier Ratio of the constant value relating two views
 @return A constraint item that relates the first view's NSLayoutAttribute with the second view's NSLayoutAttribute
 */
- (NSLayoutConstraint *)align:(UIView *)firstView
                         side:(NSLayoutAttribute)firstSide
                       toView:(UIView *)secondView
                   secondSide:(NSLayoutAttribute)secondSide
                     constant:(CGFloat)constant
                   multiplier:(CGFloat)multiplier;

#pragma mark - Width and Height
/**
@description Set a constant width for a view
@param constant CGFloat representation of a constant width in points for a view
@return A constraint item defining a view's constant width in points
*/
- (NSLayoutConstraint *)width:(CGFloat)constant;
/**
 @description Set a equal-to or greater/less-than width for a view
 @param constraintRelation NSLayoutRelation that specifies a equal-to, greater-than, or less-than relationship to a constant
 @param constant CGFloat representation of a constant width in points for a view
 @return A constraint item defining a view's constant width in points
 */
- (NSLayoutConstraint *)width:(NSLayoutRelation)constraintRelation
                     constant:(CGFloat)constant;
/**
 @description Set a equal-to or greater/less-than width for a view
 @param constraintRelation NSLayoutRelation that specifies a equal-to, greater-than, or less-than relationship to a multiplier value
 @param constant CGFloat representation of a percent-based width for a view
 @return A constraint item defining a view's percent-based width
 */
- (NSLayoutConstraint *)width:(NSLayoutRelation)constraintRelation
                   multiplier:(CGFloat)multiplier;
/**
 @description Set a constant height for a view
 @param constant CGFloat representation of a constant height in points for a view
 @return A constraint item defining a view's constant height in points
 */
- (NSLayoutConstraint *)height:(CGFloat)constant;
/**
 @description Set a equal-to or greater/less-than height for a view
 @param constraintRelation NSLayoutRelation that specifies a equal-to, greater-than, or less-than relationship to a constant
 @param constant CGFloat representation of a constant height in points for a view
 @return A constraint item defining a view's constant height in points
 */
- (NSLayoutConstraint *)height:(NSLayoutRelation)constraintRelation constant:(CGFloat)constant;
/**
 @description Set a equal-to or greater/less-than height for a view
 @param constraintRelation NSLayoutRelation that specifies a equal-to, greater-than, or less-than relationship to a multiplier value
 @param constant CGFloat representation of a percent-based height for a view
 @return A constraint item defining a view's percent-based height
 */
- (NSLayoutConstraint *)height:(NSLayoutRelation)constraintRelation multiplier:(CGFloat)multiplier;

/**
 @description Set the receiving view's width equal to its superview's width
 @return A constraint item that relates the receiving view's width to its superview's width
 */
- (NSLayoutConstraint *)equalWidth;
/**
 @description Set the receiving view's width proportional to its superview's width
 @param multiplier CGFloat-based ratio between the receiving view's width and its superview's width
 @return A constraint item that relates the receiving view's width to its superview's width
 */
- (NSLayoutConstraint *)equalWidth:(CGFloat)multiplier;
/**
 @description Set the receiving view's width equal to a second view's width
 @param secondView The second view whose width will be the reference width for the receiving view
 @return A constraint item that relates the receiving view's width to a second view's width
 */
- (NSLayoutConstraint *)equalWidthToView:(UIView *)secondView;
/**
 @description Set the receiving view's width proportional to a second view's width
 @param secondView The second view whose width will be the reference width for the receiving view
 @param multiplier CGFloat ratio relationship between the receiving view's width and a second view's width
 @return A constraint item that represents a proportional relationship between the receiving view's width to a second view's width
 */
- (NSLayoutConstraint *)equalWidthToView:(UIView *)secondView multiplier:(CGFloat)multiplier;
/**
 @description Set the receiving view's height equal to its superview's height
 @return A constraint item that relates the receiving view's height to its superview's height
 */
- (NSLayoutConstraint *)equalHeight;
/**
 @description Set the receiving view's height proportional to its superview's height
 @param multiplier CGFloat-based ratio between the receiving view's height and its superview's height
 @return A constraint item that relates the receiving view's height to its superview's height
 */
- (NSLayoutConstraint *)equalHeight:(CGFloat)multiplier;
/**
 @description Set the receiving view's height equal to a second view's height
 @param secondView The second view whose height will be the reference height for the receiving view
 @return A constraint item that relates the receiving view's height to a second view's height
 */
- (NSLayoutConstraint *)equalHeightToView:(UIView *)secondView;
/**
 @description Set the receiving view's height proportional to a second view's height
 @param secondView The second view whose height will be the reference height for the receiving view
 @param multiplier CGFloat ratio relationship between the receiving view's height and a second view's height
 @return A constraint item that represents a proportional relationship between the receiving view's height to a second view's height
 */
- (NSLayoutConstraint *)equalHeightToView:(UIView *)secondView multiplier:(CGFloat)multiplier;

/**
 @description Set several view's width proportional to the receiving view's width
 @param viewsForAlignment A collection of views that share a related width
 @param multiplier CGFloat ratio relationship between the receiving view's width and the collection of view's widths
 @return An array of constraint items that represents a proportional relationship between the receiving view's width to a collection of views's widths
 */
- (NSArray *)equalWidths:(NSArray *)viewsForAlignment
              multiplier:(CGFloat)multiplier;
/**
 @description Set several view's height proportional to the receiving view's height
 @param viewsForAlignment A collection of views that share a related height
 @param multiplier CGFloat ratio relationship between the receiving view's height and the collection of view's widths
 @return An array of constraint items that represents a proportional relationship between the receiving view's height to a collection of views's height
 */
- (NSArray *)equalHeights:(NSArray *)viewsForAlignment
               multiplier:(CGFloat)multiplier;

/**
 @description Set a view's width proportional to a specified height
 @param height The height that determines a view's width
 @return A constraint item that relates a view's width to its height
 */
- (NSLayoutConstraint *)proportionalWidthForHeight:(CGFloat)height;
/**
 @description Set a view's height proportional to a specified width
 @param height The width that determines a view's height
 @return A constraint item that relates a view's height to its width
 */
- (NSLayoutConstraint *)proportionalHeightForWidth:(CGFloat)width;
/**
 @description Set a relationship between a view's width and height
 @return A constraint item that relates a view's width and height
 */
- (NSLayoutConstraint *)aspectRatio;

#pragma mark - View Grouping
/**
 @description Stack two views vertically in a superview with margins of 0
 @param topView The upper view
 @param bottomView The lower view
 @return An array of constraints that represents two views stacked vertically
 */
- (NSArray *)stackAboveView:(UIView *)bottomView;

/**
 @description Stack two views vertically in a superview
 @param topView The upper view
 @param bottomView The lower view
 @param outerEdgeMargin A CGFloat that represents the margin between the views and the superview
 @param viewMargin A CGFloat that represents the distance between the two views
 @return An array of constraints that represents two views stacked vertically
 */
- (NSArray *)stackAboveView:(UIView *)bottomView
            superviewMargin:(CGFloat)outerEdgeMargin
           interViewSpacing:(CGFloat)viewMargin;








#pragma mark - Remove Superviews
/**
 @description Remove constraints from the receiving view's superview for a collection of views
 @param views A collection of views whose constraints should be removed from the recipient's superviews
 */
- (void)removeSuperviewConstraintsForViews:(NSArray *)views;


















@end
