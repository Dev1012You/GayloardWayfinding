//
//  UIView+AutoLayoutHelper.m
//  ScrollViewMap
//
//  Created by John Pacheco on 3/25/15.
//  Copyright (c) 2015 Chisel Apps. All rights reserved.
//

#import "UIView+AutoLayoutHelper.h"

@implementation UIView (AutoLayoutHelper)

- (NSLayoutConstraint *)pinLeading
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinLeading:0];
}

- (NSLayoutConstraint *)pinLeading:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinSide:NSLayoutAttributeLeading constant:constant];
}


- (NSLayoutConstraint *)pinTrailing
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinTrailing:0];
}

- (NSLayoutConstraint *)pinTrailing:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinSide:NSLayoutAttributeTrailing constant:-constant];
}


- (NSArray *)pinLeadingTrailing
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinLeadingTrailing:0];
}

- (NSArray *)pinLeadingTrailing:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return @[[self pinLeading:constant],
             [self pinTrailing:-constant]];
}

- (NSLayoutConstraint *)pinToTopLayoutGuide:(UIViewController *)containerViewController
{
    NSAssert([containerViewController isKindOfClass:[UIViewController class]], @"Container View must be a view controller.");
    if (!containerViewController.topLayoutGuide) return nil;
    
    NSLayoutConstraint *topLayoutGuide = [NSLayoutConstraint
                                          constraintWithItem:self
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:containerViewController.topLayoutGuide
                                          attribute:NSLayoutAttributeBottom
                                          multiplier:1
                                          constant:0];
    return topLayoutGuide;
}

- (NSLayoutConstraint *)pinToTopSuperview
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinSide:NSLayoutAttributeTop constant:0];
}

- (NSLayoutConstraint *)pinToTopSuperview:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinSide:NSLayoutAttributeTop constant:constant];
}

- (NSLayoutConstraint *)pinToBottomLayoutGuide:(UIViewController *)containerViewController
{
    NSAssert([containerViewController isKindOfClass:[UIViewController class]], @"Container View must be a view controller.");
    if (!containerViewController.bottomLayoutGuide) return nil;
    
    NSLayoutConstraint *topLayoutGuide = [NSLayoutConstraint
                                          constraintWithItem:self
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:containerViewController.bottomLayoutGuide
                                          attribute:NSLayoutAttributeTop
                                          multiplier:1
                                          constant:0];

    return topLayoutGuide;
}

- (NSLayoutConstraint *)pinToBottomSuperview
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinSide:NSLayoutAttributeBottom constant:0];
}

- (NSLayoutConstraint *)pinToBottomSuperview:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinSide:NSLayoutAttributeBottom constant:-constant];
}

- (NSArray *)pinToSuperviewBounds
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinToSuperviewBoundsConstant:0];
}

- (NSArray *)pinToSuperviewBoundsConstant:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSArray *constraintTypes = @[@(NSLayoutAttributeTop),
                                 @(NSLayoutAttributeBottom),
                                 @(NSLayoutAttributeLeft),
                                 @(NSLayoutAttributeRight)];
    
    for (NSNumber *constraintValue in constraintTypes)
    {
        if (![constraintValue isEqual:@(NSLayoutAttributeTop)])
        {
            constant = -constant;
        }
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint
                                          constraintWithItem:self
                                          attribute:constraintValue.integerValue
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.superview
                                          attribute:constraintValue.integerValue
                                          multiplier:1
                                          constant:constant];
        [constraints addObject:constraint];
    }
    return constraints;
}

- (NSArray *)pinToSuperviewBoundsInsets:(UIEdgeInsets)edgeInsets
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    
    NSLayoutConstraint *topEdge = [self pinToTopSuperview:edgeInsets.top];
    NSLayoutConstraint *bottomEdge = [self pinToBottomSuperview:edgeInsets.bottom];
    NSLayoutConstraint *leftEdge = [self pinLeading:edgeInsets.left];
    NSLayoutConstraint *rightEdge = [self pinTrailing:edgeInsets.right];
    
    return @[topEdge,bottomEdge,leftEdge,rightEdge];
}

- (NSLayoutConstraint *)pinSide:(NSLayoutAttribute)viewSide
                       constant:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    
    return [self pin:self side:viewSide toView:self.superview secondSide:viewSide constant:constant multiplier:1];
}

- (NSLayoutConstraint *)pinSide:(NSLayoutAttribute)viewSide
                       relation:(NSLayoutRelation)layoutRelation
                       constant:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    
    return [self pin:self
                side:viewSide
      layoutRelation:layoutRelation
              toView:self.superview
          secondSide:viewSide
            constant:constant
          multiplier:1];
}

- (NSArray *)pinSides:(NSArray *)viewSides
             constant:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    NSAssert(viewSides.count > 0, @"No view sides found. Please provide one or more view sides");
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    for (NSNumber *viewSide in viewSides)
    {
        switch (viewSide.integerValue)
        {
            case NSLayoutAttributeTop:
            {
                [constraints addObject:[self pinToTopSuperview:constant]];
                break;
            }
            case NSLayoutAttributeBottom:
            {
                [constraints addObject:[self pinToBottomSuperview:constant]];
                break;
            }
            case NSLayoutAttributeLeft:
            case NSLayoutAttributeLeading:
            {
                [constraints addObject:[self pinLeading:constant]];
                break;
            }
            case NSLayoutAttributeRight:
            case NSLayoutAttributeTrailing:
            {
                [constraints addObject:[self pinTrailing:constant]];
                break;
            }
            default:
                break;
        }
    }

    return constraints;
}

- (NSLayoutConstraint *)pinSide:(NSLayoutAttribute)viewSide
                         toView:(UIView *)secondView
                 secondViewSide:(NSLayoutAttribute)secondViewSide
{
    NSAssert(secondView != nil, @"No second view provided. Please provide a reference view on which to pin a first view.");
    return [self pin:self side:viewSide toView:secondView secondSide:secondViewSide constant:0 multiplier:1];
}

- (NSLayoutConstraint *)pinSide:(NSLayoutAttribute)viewSide
                         toView:(UIView *)secondView
                 secondViewSide:(NSLayoutAttribute)secondViewSide
                       constant:(CGFloat)constant
{
    NSAssert(secondView != nil, @"No second view provided. Please provide a reference view on which to pin a first view.");
    return [self pin:self side:viewSide toView:secondView secondSide:secondViewSide constant:constant multiplier:1];
}

- (NSLayoutConstraint *)pin:(UIView *)firstView
                       side:(NSLayoutAttribute)viewSide
                     toView:(UIView *)secondView
                 secondSide:(NSLayoutAttribute)secondSide
                   constant:(CGFloat)constant
                 multiplier:(CGFloat)multiplier
{
    NSAssert(firstView != nil, @"No first view provided. Please provide a view to pin.");
    NSAssert(secondView != nil, @"No second view provided. Please provide a reference view on which to pin a first view.");

    return [self pin:firstView
                side:viewSide
      layoutRelation:NSLayoutRelationEqual
              toView:secondView
          secondSide:secondSide
            constant:constant
          multiplier:multiplier];
}

- (NSLayoutConstraint *)pin:(UIView *)firstView
                       side:(NSLayoutAttribute)viewSide
             layoutRelation:(NSLayoutRelation)relation
                     toView:(UIView *)secondView
                 secondSide:(NSLayoutAttribute)secondSide
                   constant:(CGFloat)constant
                 multiplier:(CGFloat)multiplier
{
    NSAssert(firstView != nil, @"No first view provided. Please provide a view to pin.");
    NSAssert(secondView != nil, @"No second view provided. Please provide a reference view on which to pin a first view.");
    
    NSLayoutConstraint *pinningConstraint = [NSLayoutConstraint
                                             constraintWithItem:firstView
                                             attribute:viewSide
                                             relatedBy:relation
                                             toItem:secondView
                                             attribute:secondSide
                                             multiplier:multiplier
                                             constant:constant];
    return pinningConstraint;
}

#pragma mark - Alignment
- (NSLayoutConstraint *)alignCenterVerticalSuperview
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [[self alignCenterVertical:@[self]
                        referenceView:self.superview] firstObject];
}

- (NSLayoutConstraint *)alignCenterHorizontalSuperview
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [[self alignCenterHorizontal:@[self]
                          referenceView:self.superview] firstObject];
}

- (NSLayoutConstraint *)alignLeftSuperview
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self alignSide:NSLayoutAttributeLeft constant:0];
}

- (NSLayoutConstraint *)alignRightSuperview
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self alignSide:NSLayoutAttributeRight constant:0];
}

- (NSLayoutConstraint *)alignTopSuperview
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self alignSide:NSLayoutAttributeTop constant:0];
}

- (NSLayoutConstraint *)alignTopLayoutGuide:(UIViewController *)containerViewController
{
    NSAssert([containerViewController isKindOfClass:[UIViewController class]], @"Container View must be a view controller.");
    if (!containerViewController.topLayoutGuide) return nil;
    
    return [self pinToTopLayoutGuide:containerViewController];
}

- (NSLayoutConstraint *)alignBottomSuperview
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self alignSide:NSLayoutAttributeBottom constant:0];
}

- (NSLayoutConstraint *)alignBottomLayoutGuide:(UIViewController *)containerViewController
{
    NSAssert([containerViewController isKindOfClass:[UIViewController class]], @"Container View must be a view controller.");
    if (!containerViewController.bottomLayoutGuide) return nil;
    
    return [self pinToBottomLayoutGuide:containerViewController];
}

- (NSArray *)alignCenterHorizontal:(NSArray *)viewsForCenterHorizontalAlignment
                     referenceView:(UIView *)referenceView
{
    NSAssert(viewsForCenterHorizontalAlignment.count > 0, @"No views provided for horizontal center alignment.");
    NSAssert(referenceView != nil, @"No reference view found. Please provide a reference view.");
    
    return [self alignCenter:NSLayoutAttributeCenterX
                       views:viewsForCenterHorizontalAlignment
               referenceView:referenceView];
}

- (NSArray *)alignCenterVertical:(NSArray *)viewsForCenterVerticalAlignment
                   referenceView:(UIView *)referenceView
{
    NSAssert(viewsForCenterVerticalAlignment.count > 0, @"No views provided for vertical center alignment.");
    NSAssert(referenceView != nil, @"No reference view found. Please provide a reference view.");
    
    return [self alignCenter:NSLayoutAttributeCenterY
                       views:viewsForCenterVerticalAlignment
               referenceView:referenceView];
}

- (NSArray *)alignCenter:(NSLayoutAttribute)centerType
              views:(NSArray *)viewsForAlignment
      referenceView:(UIView *)referenceView
{
    NSAssert(viewsForAlignment.count > 0, @"No views provided for center alignment.");
    NSAssert(referenceView != nil, @"No reference view found. Please provide a reference view.");
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (UIView *alignmentView in viewsForAlignment)
    {
        if ([alignmentView isEqual:referenceView]) return nil;
        
        NSLayoutConstraint *alignCenter = [NSLayoutConstraint
                                           constraintWithItem:alignmentView
                                           attribute:centerType
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:referenceView
                                           attribute:centerType
                                           multiplier:1
                                           constant:0];
        
        [constraints addObject:alignCenter];
    }
    return constraints;
}

- (NSLayoutConstraint *)alignSide:(NSLayoutAttribute)firstSide
                         constant:(CGFloat)constant
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self pinSide:firstSide constant:constant];
}

- (NSLayoutConstraint *)alignSide:(NSLayoutAttribute)firstSide
                           toView:(UIView *)secondView
                       secondSide:(NSLayoutAttribute)secondViewSide
                         constant:(CGFloat)constant
{
    NSAssert(secondView != nil, @"No Second view provided. Please provide a second view on which to pin the receiving view.");

    return [self align:self
                  side:firstSide
                toView:secondView
            secondSide:secondViewSide
              constant:constant
            multiplier:1];
}

- (NSLayoutConstraint *)align:(UIView *)firstView
                         side:(NSLayoutAttribute)firstSide
                       toView:(UIView *)secondView
                   secondSide:(NSLayoutAttribute)secondSide
                     constant:(CGFloat)constant
                   multiplier:(CGFloat)multiplier
{
    NSAssert(firstView != nil, @"No first view provided. Please provide a view to pin.");
    NSAssert(secondView != nil, @"No second view provided. Please provide a reference view on which to pin a first view.");
    
    return [self pin:firstView
                side:firstSide
              toView:secondView
          secondSide:secondSide
            constant:constant
          multiplier:multiplier];
}

#pragma mark - Width and Height
- (NSLayoutConstraint *)width:(CGFloat)constant
{
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1
            constant:constant];
}

- (NSLayoutConstraint *)width:(NSLayoutRelation)constraintRelation
                     constant:(CGFloat)constant
{
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeWidth
            relatedBy:constraintRelation
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1
            constant:constant];
}

- (NSLayoutConstraint *)width:(NSLayoutRelation)constraintRelation
                    multiplier:(CGFloat)multiplier
{
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeWidth
            relatedBy:constraintRelation
            toItem:self.superview
            attribute:NSLayoutAttributeWidth
            multiplier:multiplier
            constant:0];
}


- (NSLayoutConstraint *)height:(CGFloat)constant
{
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1
            constant:constant];
}

- (NSLayoutConstraint *)height:(NSLayoutRelation)constraintRelation
                      constant:(CGFloat)constant
{
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeHeight
            relatedBy:constraintRelation
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1
            constant:constant];
}

- (NSLayoutConstraint *)height:(NSLayoutRelation)constraintRelation
                    multiplier:(CGFloat)multiplier
{
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeHeight
            relatedBy:constraintRelation
            toItem:self.superview
            attribute:NSLayoutAttributeHeight
            multiplier:multiplier
            constant:0];
}

- (NSLayoutConstraint *)equalWidth
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self equalWidth:1];
}

- (NSLayoutConstraint *)equalWidth:(CGFloat)multiplier
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [[self equalWidths:@[self]
                referenceView:self.superview
                   multiplier:multiplier] firstObject];
}

- (NSLayoutConstraint *)equalWidthToView:(UIView *)secondView
{
    NSAssert(secondView != nil, @"No Second view provided. Please provide a second view on which to pin the receiving view.");
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:secondView
            attribute:NSLayoutAttributeWidth
            multiplier:1
            constant:0];
}

- (NSLayoutConstraint *)equalWidthToView:(UIView *)secondView
                              multiplier:(CGFloat)multiplier
{
    NSAssert(secondView != nil, @"No Second view provided. Please provide a second view on which to pin the receiving view.");
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:secondView
            attribute:NSLayoutAttributeWidth
            multiplier:multiplier
            constant:0];
}

- (NSLayoutConstraint *)equalHeight
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [self equalHeight:1];
}

- (NSLayoutConstraint *)equalHeight:(CGFloat)multiplier
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [[self equalHeights:@[self]
                 referenceView:self.superview
                    multiplier:multiplier]
            firstObject];
}

- (NSLayoutConstraint *)equalHeightToView:(UIView *)secondView
{
    NSAssert(secondView != nil, @"No Second view provided. Please provide a second view on which to pin the receiving view.");
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:secondView
            attribute:NSLayoutAttributeHeight
            multiplier:1
            constant:0];
}

- (NSLayoutConstraint *)equalHeightToView:(UIView *)secondView
                               multiplier:(CGFloat)multiplier
{
    NSAssert(secondView != nil, @"No Second view provided. Please provide a second view on which to pin the receiving view.");
    return [NSLayoutConstraint
            constraintWithItem:self
            attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:secondView
            attribute:NSLayoutAttributeHeight
            multiplier:multiplier
            constant:0];
}

- (NSArray *)equalWidths:(NSArray *)viewsForAlignment
              multiplier:(CGFloat)multiplier
{
    NSAssert(viewsForAlignment.count > 0, @"No second view provided to create equal width constraint.");
    return [self equalWidths:viewsForAlignment referenceView:self multiplier:multiplier];
}

- (NSArray *)equalWidths:(NSArray *)viewsForAlignment
           referenceView:(UIView *)referenceView
              multiplier:(CGFloat)multiplier
{
    NSAssert(viewsForAlignment.count > 0, @"No views provided for center alignment.");
    NSAssert(referenceView != nil, @"No reference view found. Please provide a reference view.");
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (UIView *alignmentView in viewsForAlignment)
    {
        if (![alignmentView isEqual:referenceView])
        {
            NSLayoutConstraint *dimensionConstraint =
            [NSLayoutConstraint constraintWithItem:alignmentView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:referenceView
                                         attribute:NSLayoutAttributeWidth
                                        multiplier:multiplier
                                          constant:0];
            
            [constraints addObject:dimensionConstraint];
        }
    }
    
    return constraints;
}

- (NSArray *)equalHeights:(NSArray *)viewsForAlignment multiplier:(CGFloat)multiplier
{
    NSAssert(viewsForAlignment.count > 0, @"No second view provided to create equal height constraint.");
    return [self equalHeights:viewsForAlignment referenceView:self multiplier:multiplier];
}

- (NSArray *)equalHeights:(NSArray *)viewsForAlignment
            referenceView:(UIView *)referenceView
               multiplier:(CGFloat)multiplier
{
    NSAssert(viewsForAlignment.count > 0, @"No views provided for center alignment.");
    NSAssert(referenceView != nil, @"No reference view found. Please provide a reference view.");
 
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (UIView *alignmentView in viewsForAlignment)
    {
        if (![alignmentView isEqual:referenceView])
        {
            NSLayoutConstraint *dimensionConstraint =
            [NSLayoutConstraint constraintWithItem:alignmentView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:referenceView
                                         attribute:NSLayoutAttributeHeight
                                        multiplier:multiplier
                                          constant:0];
            
            [constraints addObject:dimensionConstraint];
        }
    }
    
    return constraints;
}

- (NSLayoutConstraint *)proportionalWidth
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [[self equalWidths:@[self]
                referenceView:self.superview
                   multiplier:(MAX(1,self.bounds.size.width))/(MAX(1,self.superview.bounds.size.width))]
            firstObject];
    
}

- (NSLayoutConstraint *)proportionalWidthForHeight:(CGFloat)height
{
    NSAssert(height >= 1, @"Height must be greater than or equal to 1");
    
    NSLayoutConstraint *proportionalWidth = [NSLayoutConstraint
                                             constraintWithItem:self
                                             attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                             attribute:NSLayoutAttributeWidth
                                             multiplier:(height/MAX(1,self.bounds.size.width))
                                             constant:0];
    
    return proportionalWidth;
}

- (NSLayoutConstraint *)proportionalHeight
{
    NSAssert(self.superview != nil, @"Superview not found. The receiving view must already be part of the view hierarchy.");
    return [[self equalHeights:@[self]
                 referenceView:self.superview
                    multiplier:(MAX(1,self.bounds.size.width))/(MAX(1,self.superview.bounds.size.width))]
            firstObject];
}

- (NSLayoutConstraint *)proportionalHeightForWidth:(CGFloat)width
{
    NSAssert(width >= 1, @"Width must be greater than or equal to 1");
    
    NSLayoutConstraint *proportionalHeight = [NSLayoutConstraint
                                             constraintWithItem:self
                                             attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                             attribute:NSLayoutAttributeWidth
                                             multiplier:(MAX(1,self.bounds.size.height)/width)
                                             constant:0];
    
    return proportionalHeight;
}

- (NSLayoutConstraint *)aspectRatio
{
    NSLayoutConstraint *aspectRatio = [NSLayoutConstraint
                                       constraintWithItem:self
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeWidth
                                       multiplier:(MAX(1,self.bounds.size.height)/MAX(1,self.bounds.size.width))
                                       constant:0];
    return aspectRatio;
}


#pragma mark - View Grouping
- (NSArray *)stackAboveView:(UIView *)bottomView
{
    return [self stackAboveView:bottomView superviewMargin:0 interViewSpacing:0];
}

- (NSArray *)stackAboveView:(UIView *)bottomView
            superviewMargin:(CGFloat)outerEdgeMargin
           interViewSpacing:(CGFloat)viewMargin
{
    NSAssert(bottomView != nil, @"No bottom view provided. Please provide a lower view");
    
    NSArray *pinTopView = [self pinSides:@[@(NSLayoutAttributeTop),@(NSLayoutAttributeLeading),@(NSLayoutAttributeTrailing)]
                                constant:outerEdgeMargin];
    
    NSArray *pinBottomView = [bottomView pinSides:@[@(NSLayoutAttributeBottom),@(NSLayoutAttributeLeading),@(NSLayoutAttributeTrailing)]
                                         constant:outerEdgeMargin];
    
    NSLayoutConstraint *interViewSpace = [NSLayoutConstraint constraintWithItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:bottomView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:viewMargin];
    
    NSArray *constraints = [NSArray arrayWithArray:pinTopView];
    constraints = [constraints arrayByAddingObjectsFromArray:pinBottomView];
    constraints = [constraints arrayByAddingObject:interViewSpace];
    
    return constraints;
}

#pragma mark - Constraint Removal
- (void)removeSuperviewConstraintsForViews:(NSArray *)views
{
    for (id view in views)
    {
        NSAssert([view isKindOfClass:[UIView class]], @"Invalid object type provided. Only view objects should be provided");
    }
    
    [views enumerateObjectsUsingBlock:^(UIView *mainView, NSUInteger idx, BOOL *stop)
    {
        NSArray *constraints = [mainView.superview constraints];
        for (NSLayoutConstraint *constraint in constraints)
        {
            if (constraint.firstItem == mainView || constraint.secondItem == mainView)
            {
                [mainView.superview removeConstraint:constraint];
            }
        }
    }];
}













@end
