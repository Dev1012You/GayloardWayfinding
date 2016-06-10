//
//  GAHNotificationsViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 6/25/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHNotificationsViewController.h"
#import "UIButton+GAHCustomButtons.h"
#import "GAHNotificationView.h"

#import "GAHPromotion.h"
#import "GAHCouponView.h"

@interface GAHNotificationsViewController ()
@property (nonatomic, strong) NSArray *dataSource;
@property (weak, nonatomic) IBOutlet UIView *checkBackContainer;
@end

@implementation GAHNotificationsViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *promotions = [NSKeyedUnarchiver unarchiveObjectWithFile:[GAHPromotion promotionsSavePath].path];
    
    self.dataSource = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7)];
    self.dataSource = promotions;
    
    [self.view sendSubviewToBack:self.mainMenuContainer];
    
    self.checkBackContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.checkBackContainer.layer.shadowOpacity = 0.4f;
    self.checkBackContainer.layer.shadowRadius = 3.f;
    self.checkBackContainer.layer.cornerRadius = 4.f;
    
    [self.detailContainer setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultTexture"]]];
    
#warning DEBUG TO SHOW NOTIFICATION STYLE
    GAHNotificationView *notification = [GAHNotificationView notification];
    
    NSString *defaultMessage = @"Welcome to the Gaylord National Resort, and we hope you enjoy your stay with us.";
    [notification setBodyMessage:defaultMessage];
    
//    __weak __typeof(&*self)weakSelf = self;
    [notification addButton:@"View Location Details" backgroundColor:UIColorFromRGB(0x002c77) actionHandler:^(GAHNotificationView *notificationView)
     {
         [notificationView removeFromSuperview];
     }];
    
    [notification addButton:@"Take Me to Wayfinding" backgroundColor:UIColorFromRGB(0xbb9468) actionHandler:^(GAHNotificationView *notificationView)
     {
         [notificationView removeFromSuperview];
     }];
    
    [notification addButton:@"Dismiss" backgroundColor:UIColorFromRGB(0x646464) actionHandler:^(GAHNotificationView *notificationView)
     {
         [notificationView removeFromSuperview];
     }];
    
//    [notification showInView:self.detailContainer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:false];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MyriadPro-Bold" size:13.f],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationItem setTitle:@"NOTIFICATIONS"];
}

#pragma mark - Protocol Conformance
#pragma mark UICollectionView Data Source and Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GAHNotificationsCell *cell = (GAHNotificationsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GAHNotificationsCell" forIndexPath:indexPath];
    
    id data = self.dataSource[indexPath.row];
    
    cell = (GAHNotificationsCell *)[self configureCell:cell data:data atIndexPath:indexPath];
    
    BOOL isLastRow = (indexPath.row == self.dataSource.count -1) ? true : false;
    cell.finalDotMarker.hidden = !isLastRow;
    
    return cell;
}

- (UICollectionViewCell *)configureCell:(UICollectionViewCell *)cell data:(id)cellData atIndexPath:(NSIndexPath *)indexPath
{
    GAHNotificationsCell *notificationCell = (GAHNotificationsCell *)cell;
    
    if ([cellData isKindOfClass:[GAHPromotion class]])
    {
        GAHPromotion *promotionInfo = (GAHPromotion *)cellData;
        notificationCell.headerLabel.text = promotionInfo.name;
        notificationCell.messageBodyLabel.text = promotionInfo.promotion;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id data = self.dataSource[indexPath.row];

    if ([data isKindOfClass:[GAHPromotion class]])
    {
        NSURLRequest *couponRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[data details]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        [GAHCouponView loadInView:self.view urlRequest:couponRequest delegate:nil];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margins = 12.f;
    CGFloat width = CGRectGetWidth(self.view.frame) - (2.f * margins);
    
    CGFloat cellMinimumHeight = 75.f;
    CGSize labelSize = [self cellMessageBodyLabelForWidth:width];
    
    return CGSizeMake(width, cellMinimumHeight + labelSize.height + 5.f);
}

- (NSString *)textForNotification
{
    return @"Welcome to the Gaylord National Resort Hotel!";
}

- (CGSize)cellMessageBodyLabelForWidth:(CGFloat)targetWidth
{
    UILabel *label = [UILabel new];
    label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.f];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    label.text = [self textForNotification];
    
    return [label sizeThatFits:CGSizeMake(targetWidth, MAXFLOAT)];
}

#pragma mark - IBActions
#pragma mark - Helper Methods
#pragma mark - Initial Setup
#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    [super setupConstraints];
}

@end

@implementation GAHNotificationsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.headerBackground.image = [[UIImage imageNamed:@"notificationCellHeaderBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    self.dotMarker.backgroundColor = [UIColor clearColor];
//    self.finalDotMarker.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.circlePath)
    {
        self.circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.dotMarker.bounds),
                                                                            CGRectGetMidY(self.dotMarker.bounds))
                                                         radius:self.dotMarker.center.x-3.f
                                                     startAngle:0
                                                       endAngle:2*M_PI
                                                      clockwise:true];
        for (UIView *dotMarker in @[self.dotMarker,self.finalDotMarker])
        {
            CAShapeLayer *circleLayer = [CAShapeLayer layer];
            circleLayer.path = self.circlePath.CGPath;
            circleLayer.lineWidth = 2.5f;
            circleLayer.strokeColor = [UIColor darkGrayColor].CGColor;
            if (dotMarker == self.dotMarker)
            {
                circleLayer.fillColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultTexture"]].CGColor;
            }
            else
            {
                circleLayer.fillColor = [UIColor darkGrayColor].CGColor;
            }
            
            [dotMarker.layer addSublayer:circleLayer];
        }
    }
}

@end