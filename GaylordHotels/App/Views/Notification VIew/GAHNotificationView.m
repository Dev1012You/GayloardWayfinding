//
//  GAHNotificationView.m
//  GaylordHotels
//
//  Created by John Pacheco on 8/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHNotificationView.h"
#import "UIView+AutoLayoutHelper.h"

@interface GAHNotificationView ()
@property (nonatomic, strong) NSArray *alertButtons;
@property (nonatomic, strong) NSMutableDictionary *buttonOperations;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerHeight;

@end

@implementation GAHNotificationView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

+ (instancetype)notification
{
    GAHNotificationView *notification = [[[NSBundle mainBundle] loadNibNamed:@"GAHNotificationView" owner:nil options:nil] objectAtIndex:0];
    [notification setup];
    return notification;
}

- (void)setup
{
    self.translatesAutoresizingMaskIntoConstraints = false;
    _buttonCornerRadius = 3.f;
    
    _notificationTitle.text = @"Welcome!";
    
    NSString *defaultTitleFontName = @"MyriadPro-Bold";
    self.defaultBodyFontName = @"MyriadPro-Regular";
    
    [_notificationTitle setFont:[UIFont fontWithName:defaultTitleFontName
                                                size:35.f]];
    
    [_notificationBody setFont:[UIFont fontWithName:self.defaultBodyFontName
                                               size:17.f]];
    
    NSMutableParagraphStyle *bodyStyle = [[NSMutableParagraphStyle alloc] init];
    bodyStyle.lineSpacing = 10.f;
    bodyStyle.alignment = NSTextAlignmentCenter;
    bodyStyle.lineBreakMode = NSLineBreakByWordWrapping;
    _bodyStyle = bodyStyle;
    _notificationBody.selectable = false;
    
    _notificationContainer.layer.cornerRadius = 5.f;
    
    _buttonOperations = [NSMutableDictionary new];
    
    _alertButtons = [NSArray new];
    
    [_iconContainer addSubview:[self circleBorder:_iconContainer]];
}

- (void)setBodyMessage:(NSString *)bodyMessage
{
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] initWithAttributedString:self.notificationBody.attributedText];
    [newText addAttributes:@{NSParagraphStyleAttributeName: self.bodyStyle} range:NSMakeRange(0, newText.mutableString.length - 1)];
    [newText.mutableString setString:bodyMessage];
    
    self.notificationBody.attributedText = newText;
}

- (UIView *)circleBorder:(UIView *)containerView
{
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:containerView.bounds];
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = circlePath.CGPath;
    circleShape.lineWidth = 5.f;
    circleShape.strokeColor = [UIColor whiteColor].CGColor;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame))];
    [newView.layer addSublayer:circleShape];
    newView.layer.masksToBounds = false;
    
    return newView;
}

- (void)showInView:(UIView *)parentView
{
    [self setupButtonConstraints:self.alertButtons];
    
    [parentView addSubview:self];
    [parentView addConstraints:[self pinToSuperviewBoundsInsets:UIEdgeInsetsMake(20, 30, 50, 30)]];
    
    [self showShadow:true];
    
//    [parentView setUserInteractionEnabled:false];
}

- (void)dismiss
{
    [self removeFromSuperview];
}

- (void)showShadow:(BOOL)shouldShowShadow
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 50.f;
    self.layer.shadowOpacity = shouldShowShadow ? 1.f : 0.f;
}

- (void)addButton:(NSString *)buttonTitle
  backgroundColor:(UIColor *)backgroundColor
          atIndex:(NSInteger)index
    actionHandler:(void(^)(GAHNotificationView *))actionHandler
{
    if (buttonTitle.length == 0)
    {
        return;
    }
    
    if (index > self.alertButtons.count - 1 || index < 0)
    {
        index = MAX(0, self.alertButtons.count - 1);
    }
    
    UIButton *newButton = [UIButton new];
    newButton.translatesAutoresizingMaskIntoConstraints = false;
    newButton.layer.cornerRadius = self.buttonCornerRadius;
    newButton.backgroundColor = backgroundColor;
    newButton.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Bold" size:17.f];
    [newButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    __weak __typeof(&*self)weakSelf = self;
    NSBlockOperation *actionOperation = [NSBlockOperation blockOperationWithBlock:^{
        if (actionHandler)
        {
            actionHandler(weakSelf);
        }
        
        [weakSelf dismiss];
    }];
    
    [newButton addTarget:self action:@selector(didPressActionButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.alertButtons = [self.alertButtons arrayByAddingObject:newButton];
    
    [self.buttonOperations setObject:actionOperation forKey:buttonTitle];
}

- (void)addButton:(NSString *)buttonTitle
  backgroundColor:(UIColor *)backgroundColor
    actionHandler:(void(^)(GAHNotificationView *))actionHandler
{
    [self addButton:buttonTitle
    backgroundColor:backgroundColor
            atIndex:MAX(0, self.alertButtons.count - 1)
      actionHandler:actionHandler];
}

- (void)didPressActionButton:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        NSString *operationKey = [sender titleForState:UIControlStateNormal];
        NSBlockOperation *selectedOperation = [self.buttonOperations objectForKey:operationKey];
        [selectedOperation start];
    }
}

- (void)setupButtonConstraints:(NSArray *)buttons
{
    CGFloat buttonHeight = 40.f;
    CGFloat margin = 10.f;
    
    CGFloat buttonContainerHeight = (buttons.count * buttonHeight) + (margin * MAX(0,buttons.count - 1));
    self.buttonContainerHeight.constant = buttonContainerHeight;
    
    UIView *buttonContainer = self.buttonContainer;
    
    [buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop)
    {
        [button addConstraint:[button height:buttonHeight]];
        [buttonContainer addSubview:button];
        [buttonContainer addConstraints:[button pinLeadingTrailing]];
        [buttonContainer addConstraint:[button alignCenterHorizontalSuperview]];
        
        if (idx == 0)
        {
            [buttonContainer addConstraint:[button pinToTopSuperview]];
        }
        else
        {
            UIView *upperView = buttons[idx - 1];
            
            [buttonContainer addConstraint:[button pinSide:NSLayoutAttributeTop toView:upperView secondViewSide:NSLayoutAttributeBottom constant:margin]];
        }
    }];
}
@end
