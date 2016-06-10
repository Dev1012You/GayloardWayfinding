//
//  GAHDirectionCell.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHDirectionCell.h"
#import "UIView+AutoLayoutHelper.h"

@interface GAHDirectionCell ()
@property (nonatomic, weak) IBOutlet UIView *separatorLine;
@property (nonatomic, strong) CAShapeLayer *lineLayer;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation GAHDirectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.clipsToBounds = false;
    
    self.stepLocationImage.clipsToBounds = true;
//    self.stepLocationImage.contentMode = UIViewContentModeScaleAspectFill;
    
    CAShapeLayer *circleLayer = [self circularBackgroundForView:self.stepNumberContainer border:true];
    [self.stepNumberContainer.layer addSublayer:circleLayer];
    [self.stepNumberContainer bringSubviewToFront:self.stepNumberLabel];
    
    self.separatorLine.backgroundColor = [UIColor clearColor];
    self.separatorLine.clipsToBounds = true;
    [self.separatorLine.layer addSublayer:[self createLineLayer]];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectCell:)];
    [self.locationImageContainer addGestureRecognizer:self.tapGesture];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.locationImageContainer.hidden = true;
    self.stepLocationImage.image = nil;
    self.imageHeightConstraint.constant = 0;
}

- (void)didSelectCell:(id)sender
{
    if (self.directionCellDelegate && [self.directionCellDelegate respondsToSelector:@selector(directionCell:didSelectLocation:)])
    {
        [self.directionCellDelegate directionCell:self didSelectLocation:self.cellIndex];
    }
}

- (CAShapeLayer *)createLineLayer
{
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointZero];
    [linePath addLineToPoint:CGPointMake(CGRectGetMaxX(self.stepLocationImage.frame), 0)];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.strokeColor = [UIColor colorWithWhite:0.35 alpha:1].CGColor;
    lineLayer.lineWidth = 2.f;
    lineLayer.lineDashPattern = @[@6,@4];
    
    return lineLayer;
}


- (CAShapeLayer *)circularBackgroundForView:(UIView *)targetView border:(BOOL)hasBorder
{
    CGRect circleRect = CGRectMake(0, 0, targetView.frame.size.width, targetView.frame.size.height);
    CAShapeLayer *circleShapeLayer = [CAShapeLayer layer];
    circleShapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:circleRect].CGPath;
    circleShapeLayer.fillColor = [UIColor colorWithRed:130/255.f green:130/255.f blue:130/255.f alpha:1.f].CGColor;
    if (hasBorder)
    {
        circleShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        circleShapeLayer.lineWidth = 2.5f;
    }
    
    return circleShapeLayer;
}

@end
