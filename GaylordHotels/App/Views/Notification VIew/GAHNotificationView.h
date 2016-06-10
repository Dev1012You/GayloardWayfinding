//
//  GAHNotificationView.h
//  GaylordHotels
//
//  Created by John Pacheco on 8/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAHNotificationView : UIView


@property (weak, nonatomic) IBOutlet UIView *notificationContainer;

@property (weak, nonatomic) IBOutlet UIView *iconContainer;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UILabel *notificationTitle;

@property (weak, nonatomic) IBOutlet UITextView *notificationBody;

@property (nonatomic, strong) NSString *defaultBodyFontName;
@property (nonatomic, strong) NSParagraphStyle *bodyStyle;
@property (nonatomic, assign) CGFloat buttonCornerRadius;

@property (weak, nonatomic) IBOutlet UIScrollView *buttonContainer;

+ (instancetype)notification;

- (void)setBodyMessage:(NSString *)bodyMessage;

- (void)showInView:(UIView *)parentView;

- (void)dismiss;

- (void)addButton:(NSString *)buttonTitle
  backgroundColor:(UIColor *)backgroundColor
    actionHandler:(void(^)(GAHNotificationView *))actionHandler;

- (void)addButton:(NSString *)buttonTitle
  backgroundColor:(UIColor *)backgroundColor
          atIndex:(NSInteger)index
    actionHandler:(void(^)(GAHNotificationView *))actionHandler;

@end
