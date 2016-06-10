//
//  GAHDetailContentViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/8/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "GAHDetailContentViewController.h"
#import "GAHStoryboardIdentifiers.h"
#import "UIView+AutoLayoutHelper.h"
#import "GAHDestination.h"
#import "CHAFontAwesome.h"
#import "GAHGeneralInfoViewController.h"
#import "GAHMapViewController.h"
#import "GAHBaseNavigationController.h"
#import "MBProgressHUD.h"
#import "UIColor+GAHCustom.h"

@interface GAHDetailContentViewController ()
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;

@property (nonatomic, strong) GAHDestination *currentLocation;
@end

@implementation GAHDetailContentCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.iconLabel.font = [UIFont fontWithName:@"FontAwesome" size:40.f];
    self.iconLabel.textColor = [UIColor gaylordBlue];
    self.iconLabel.adjustsFontSizeToFitWidth = true;
    self.iconLabel.minimumScaleFactor = 0.01f;
    self.iconLabel.text = @"\uf095";
    
    self.detailsLabel.font = [UIFont fontWithName:@"MyriadPro-Bold" size:12.f];
    self.detailsLabel.textColor = UIColorFromRGB(0x646464);
    self.detailsLabel.text = @"+1-432-646-9873";
}

@end

@implementation GAHDetailContentViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConstraints];
    
    [self setupButton:self.requestRouteButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = UIColorFromRGB(0xf4f4f4);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Protocol Conformance
#pragma mark - IBActions
- (IBAction)loadDirections:(id)sender
{
    if (self.directionsLoader
        && [self.directionsLoader respondsToSelector:@selector(loadWayfindingStart:destination:)])
    {
        if ([self.parentViewController.navigationController isKindOfClass:[GAHBaseNavigationController class]])
        {
            GAHBaseNavigationController *baseNav = (GAHBaseNavigationController *)self.parentViewController.navigationController;
            MDCustomTransmitter *transmitter = baseNav.rootNavigationController.beaconSightingManager.beaconManager.activeBeacon;
            if (transmitter == nil)
            {
                
                SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Location Error" andMessage:@"Sorry, we haven't detected any beacons near you. Please approach a beacon and try again."];
                [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                    DLog(@"\nalert");
                }];
                [alert show];
                return;
            }
        }
        
        id destination = self.currentLocation;
        if ([destination isKindOfClass:[GAHDestination class]])
        {
            [self.directionsLoader loadWayfindingStart:nil
                                           destination:(GAHDestination *)destination];
        }
    }
}

- (IBAction)pressedExpandMap:(id)sender
{
    if (self.mapViewDelegate && [self.mapViewDelegate respondsToSelector:@selector(mapViewWillToggleSize:)])
    {
        [self.mapViewDelegate mapViewWillToggleSize:GAHMapViewSizeFullScreen];
    }
}

#pragma mark - Helper Methods
#pragma mark - Initial Setup
- (void)configureWithDataSource:(GAHDataSource *)dataSource
{
    __weak __typeof(&*self)weakSelf = self;
    
    self.dataSource.cellReuseIdentifier = GAHDetailContentCellIdentifier;

    self.dataSource.cellHeightCalculation = ^CGSize(UIView *collectionView)
    {
        CGFloat marginSize = 10.f;
        CGFloat height = collectionView.frame.size.height - (marginSize * 2.f);
        CGFloat width = (CGRectGetWidth(collectionView.frame)/3.f) - (marginSize * 1.5f);
        return CGSizeMake(width, height);
    };
    
    
    [self.dataSource setCellLayoutHandler:^(UICollectionViewCell *cell, id cellData, NSIndexPath *indexPath)
    {
        if ([cell isKindOfClass:[GAHDetailContentCell class]] && [cellData isKindOfClass:[NSDictionary class]])
        {
            NSString *iconString = [cellData objectForKey:@"icon"];
            NSString *itemTitle = [cellData objectForKey:@"label"];
            
            if (iconString.length < 1)
            {
                iconString = [CHAFontAwesome icon:@"fa-info-circle"];
            }
            else
            {
                iconString = [CHAFontAwesome icon:iconString];
            }
            
            [[(GAHDetailContentCell *)cell iconLabel] setText:iconString];
            
            if ([itemTitle.lowercaseString isEqualToString:@"call location"])
            {
                NSString *phoneNumber = weakSelf.currentLocation.phone;
                if (phoneNumber.length == 0)
                {
                    phoneNumber = @"Unknown Number";
                }
                [(GAHDetailContentCell *)cell iconLabel].transform = CGAffineTransformMakeScale(-1, 1);
                [[(GAHDetailContentCell *)cell detailsLabel] setText:phoneNumber];
            }
            else
            {
                [(GAHDetailContentCell *)cell iconLabel].transform = CGAffineTransformIdentity;
                [[(GAHDetailContentCell *)cell detailsLabel] setText:itemTitle];
            }
        }
    }];
    
    [self.dataSource setCellSelectionHandler:^(id cellData)
    {
        if ([cellData isKindOfClass:[NSDictionary class]])
        {
            NSString *link = [cellData objectForKey:@"link"];
            if (link.length > 0)
            {
                if ([link rangeOfString:@"http" options:NSCaseInsensitiveSearch].location == 0)
                {
                    [weakSelf openLink:link];
                }
                else
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
                }
            }
        }
    }];
    
    self.mainDetailsCollectionView.dataSource = self.dataSource;
    self.mainDetailsCollectionView.delegate = self.dataSource;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    [self.dataSource fetchDataForType:GAHDataCategoryLocation completionHandler:^(NSArray *data) {
        
        if ([data.firstObject isKindOfClass:[GAHDestination class]])
        {
            if (weakSelf.dataSource.data.count > 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.heightConstraint.constant = weakSelf.mainDetailsCollectionView.frame.size.height;
                    weakSelf.textViewHeight.constant = weakSelf.extraDetailsTextView.superview.frame.size.height - weakSelf.mainDetailsCollectionView.frame.size.height;
                    
                    if (weakSelf.dataSource.data.count < 4) {
                        weakSelf.moreItemsLabelWidth.constant = 0;
                    }
                });
            }
            
            GAHDestination *destination = data.firstObject;
            weakSelf.currentLocation = destination;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.mainDetailsCollectionView reloadData];
                [weakSelf.extraDetailsTextView setNeedsUpdateConstraints];
                [weakSelf setupTextView:weakSelf.currentLocation];
                weakSelf.moreItemsLabel.backgroundColor = weakSelf.dataSource.data.count > 3 ? UIColorFromRGB(0x1E3278) : [UIColor lightGrayColor];
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:true];
            });
        }
    }];
}

- (void)openLink:(NSString *)link
{
    GAHGeneralInfoViewController *locationMisc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHGeneralInfoViewControllerIdentifier];
    locationMisc.generalInfoURL = [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    locationMisc.minimizeCloseBar = false;
    [locationMisc.generalInfoWebView setScalesPageToFit:false];
    
    [self presentViewController:locationMisc animated:true completion:nil];
}

- (void)setupTextView:(GAHDestination *)destination
{
    NSString *htmlString =  @"";
    for (NSDictionary *details in destination.details)
    {
        htmlString = [htmlString stringByAppendingString:[details objectForKey:@"description"]];
    }
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;"];
    
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                                     options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                          documentAttributes:nil
                                       error:nil];
    if (attributedString.length > 1)
    {
        [attributedString setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MyriadPro-Regular" size:15.f]}
                                  range:NSMakeRange(0, attributedString.length-1)];
    }
    
    self.extraDetailsTextView.attributedText = attributedString;
}

- (void)setupButton:(UIButton *)styledButton
{
    styledButton.backgroundColor = kTan;
    styledButton.layer.cornerRadius = 3.f;
    
    [styledButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    styledButton.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Bold" size:14.f];
    styledButton.titleLabel.adjustsFontSizeToFitWidth = true;
    styledButton.titleLabel.minimumScaleFactor = 0.5f;
    
    [styledButton setTitle:@"TAKE ME HERE (BEGIN WAYFINDING)" forState:UIControlStateNormal];
    
    [styledButton addTarget:self
                     action:@selector(loadDirections:)
           forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat mapLeading = 10.f;
    CGFloat headerHeight = CGRectGetHeight(self.view.frame) * 0.2f;
    CGFloat mapContainerWidth = ((headerHeight * 0.6)/1.25);
    CGFloat mapContainerTrailingEdge = mapContainerWidth + mapLeading;
    
    [styledButton.superview addConstraint:[styledButton pinLeading:(10 + mapContainerTrailingEdge)]];
    
    UIButton *expandMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    expandMapButton.translatesAutoresizingMaskIntoConstraints = false;
    [expandMapButton addTarget:self
                        action:@selector(pressedExpandMap:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [styledButton.superview addSubview:expandMapButton];
    
    [expandMapButton.superview addConstraints:[expandMapButton pinSides:@[@(NSLayoutAttributeTop),@(NSLayoutAttributeBottom),@(NSLayoutAttributeLeading)]
                                                               constant:0]];
    [expandMapButton.superview addConstraint:[expandMapButton pinSide:NSLayoutAttributeTrailing toView:styledButton secondViewSide:NSLayoutAttributeLeading]];
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    self.heightConstraint.constant = 0;
}









@end
