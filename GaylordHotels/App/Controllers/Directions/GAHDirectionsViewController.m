//
//  GAHDirectionsViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHDirectionsViewController.h"
#import "GAHDirectionCell.h"
#import "GAHDestination.h"
#import "GAHMapDataSource.h"
//#import "GAHDirectionDetailViewController.h"
#import "CHADirectionSet.h"
#import "CHAInstruction.h"
#import "CHARoute.h"
#import "CHADestination.h"
#import "CHAMapImage.h"

#import "GAHStoryboardIdentifiers.h"
#import "UIView+AutoLayoutHelper.h"
#import "UIImageView+AFNetworking.h"

#import "GAHDestination+Helpers.h"
#import "CHADestination+HelperMethods.h"
#import "GAHAPIDataInitializer.h"
#import "MBProgressHUD.h"

#import "UIImageView+WebCache.h"
#import "GAHRateView.h"
#import "GAHRatingFooter.h"
#import "SIAlertView.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface GAHDirectionsViewController () <GAHRatingDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSMutableDictionary *directionDetails;
@end

NSString *const GAHWayfindingDestinationKey = @"wayfindingDestination";
NSString *const GAHMeetingplayDestinationKey = @"meetingplayDestination";
NSString *const GAHInstructionKey = @"instruction";

@implementation GAHDirectionsViewController

CGFloat const cellImageHeight = 160;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupConstraints];

    __weak __typeof(&*self)weakSelf = self;
    self.directionsDataSource = [[GAHDirectionsDataSource alloc] initWithCellIdentifier:GAHDirectionCellIdentifier
                                                                   cellLayoutHandler:^(GAHDirectionCell *cell, id instruction, NSIndexPath *indexPath)
    {
        if ([instruction isKindOfClass:[CHAInstruction class]])
        {
            cell.directionTextLabel.text = [instruction text];
            cell.stepNumberLabel.text = [NSString stringWithFormat:@"%@",@(indexPath.row + 1)];
            cell.stepLocationImage.contentMode = UIViewContentModeScaleAspectFill;
            
            NSDictionary *directionDetails = [weakSelf.directionDetails objectForKey:@(indexPath.row)];
            
            if (directionDetails)
            {
                NSString *substitutedInstructionText = [directionDetails objectForKey:GAHInstructionKey];
                if (substitutedInstructionText.length > 0)
                {
                    cell.directionTextLabel.text = substitutedInstructionText;
                }
                
                CHADestination *wayfindingDestination = [directionDetails objectForKey:GAHWayfindingDestinationKey];
                NSString *wfpThumb = [wayfindingDestination.details objectForKey:@"thumbnail"];
                if (wfpThumb.length)
                {
                    cell.stepLocationImage.contentMode = UIViewContentModeScaleToFill;
                }
            }

            
            NSURL *imageURL = [weakSelf imageURLForDestination:directionDetails];
            [weakSelf directionCell:cell
                       loadImageURL:imageURL
                  completionHandler:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
            {
                cell.locationImageContainer.hidden = false;
                if (cacheType == SDImageCacheTypeNone)
                {
                    [weakSelf.directionsCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
            }];
        }
    }];
    
    self.directionsCollectionView.dataSource = self.directionsDataSource;
    self.directionsCollectionView.delegate = self.directionsDataSource;
    self.directionsDataSource.directionsViewController = self;
}

- (void)directionCell:(GAHDirectionCell *)cell loadImageURL:(NSURL *)imageURL completionHandler:(void(^)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL))completionHandler
{
    if (imageURL)
    {
        [cell.stepLocationImage sd_setImageWithURL:imageURL
                                  placeholderImage:nil
                                           options:0
                                          progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             if (expectedSize > 0)
             {
                 NSNumber *progress = @((CGFloat)receivedSize/(CGFloat)expectedSize);
             }
         } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
             
             cell.imageHeightConstraint.constant = cellImageHeight;
             cell.stepLocationImage.backgroundColor = [UIColor whiteColor];
             
             if (completionHandler)
             {
                 completionHandler(image,error,cacheType,imageURL);
             }
             
         }];
    }
    else
    {
        cell.stepLocationImage.image = nil;
        cell.stepLocationImage.backgroundColor = [UIColor clearColor];
        cell.imageHeightConstraint.constant = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = true;
}

- (CGFloat)directionCell:(GAHDirectionCell *)cell image:(UIImage *)image
{
    CGPoint imageCenter = CGPointMake(image.size.width/2.f, image.size.height/2.);
    CGFloat translatedImageCenter = cell.center.x - imageCenter.x;
    
    return translatedImageCenter;
}

- (NSURL *)imageURLForDestination:(NSDictionary *)destinationDetails
{
    NSURL *imageURL = nil;
    if (destinationDetails)
    {
        CHADestination *wayfindingDestination = [destinationDetails objectForKey:GAHWayfindingDestinationKey];
        NSString *wfpThumb = [wayfindingDestination.details objectForKey:@"thumbnail"];
        if (wfpThumb.length)
        {
            imageURL = [NSURL URLWithString:wfpThumb];
        }
        else
        {
            GAHDestination *meetingplayDestination = [destinationDetails objectForKey:GAHMeetingplayDestinationKey];
            NSString *imageFilename = [meetingplayDestination.image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (imageFilename.length)
            {
                NSString *imageString = [NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:kGAHLocationImageURL],imageFilename];
                imageURL = [NSURL URLWithString:imageString];
            }
            else
            {
                DLog(@"no image found");
            }
        }
    }
    return imageURL;
}


#pragma mark - Protocol Conformance
- (void)substituteDestinationNames:(CHAInstruction *)instruction
           modifiedInstructionText:(NSString **)modifiedInstructionText
            meetingplayDestination:(GAHDestination *)meetingplayDestination
             wayfindingDestination:(CHADestination *)wayfindingDestination
                               idx:(NSUInteger)idx
                      instructions:(NSArray *)instructions
{
    NSString *originalInstructionText = [NSMutableString stringWithString:[instruction text]];
    if (wayfindingDestination.destinationDescription.length > 0 && (instructions.count - 1 == idx))
    {
        *modifiedInstructionText = wayfindingDestination.destinationDescription;
    }
    else
    {
        NSRange targetRange = [originalInstructionText rangeOfString:wayfindingDestination.destinationName
                                                             options:NSCaseInsensitiveSearch];
        if (targetRange.length > 0)
        {
            if (meetingplayDestination)
            {
                *modifiedInstructionText =
                [originalInstructionText stringByReplacingCharactersInRange:targetRange
                                                                 withString:meetingplayDestination.location];
            }
            else
            {
                *modifiedInstructionText =
                [originalInstructionText stringByReplacingOccurrencesOfString:@"-"
                                                                   withString:@" "];
            }
            [instruction setText:*modifiedInstructionText];
        }
        else
        {
            DLog(@"\ndestination (%@) text not found in %@",wayfindingDestination.destinationName,originalInstructionText);
        }
    }
}

- (void)map:(UIView *)mapView didFetchRoute:(CHARoute *)route
{
    self.directionsDataSource.routeData = route;
    
    NSArray *instructions = [self.directionsDataSource createSingleDirectiveDataSource:route.directions];
    NSArray *wayfindingIdentifiers = [CHADestination identifiersForWayfindingLocations:self.wayfindingDestinations];
    
    NSMutableDictionary *floorNumbersAndNames = [self floorNumbersAndNames];
    
    self.directionDetails = [NSMutableDictionary new];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak __typeof(&*self)weakSelf = self;
        [instructions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[CHAInstruction class]])
             {
                 NSIndexSet *matchingSlugIndexes = [self indexesOfMatchingSlugsInDirection:[(CHAInstruction *)obj text] wayfindingIdentifiers:wayfindingIdentifiers];
                 
                 NSArray *rangesOfMatchingSlugs = [self rangesOfMatchingSlugsInDirection:[(CHAInstruction *)obj text]
                                                                         matchingIndexes:matchingSlugIndexes
                                                                   wayfindingIdentifiers:wayfindingIdentifiers];
                 
                 __block NSArray *matchingWayfindingDestinations = [NSArray new];
                 __block NSMutableSet *matchingWayfindingIdentifiers = [NSMutableSet new];
                 [matchingSlugIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                     
                     CHADestination *matchingDestination = weakSelf.wayfindingDestinations[idx];
                     matchingWayfindingDestinations = [matchingWayfindingDestinations arrayByAddingObject:matchingDestination];
                     [matchingWayfindingIdentifiers addObject:matchingDestination.destinationName];
                 }];
                 
                 
                 __block NSArray *matchingMeetingPlayDestinations = [NSArray new];
                 [weakSelf.meetingPlayDestinations enumerateObjectsUsingBlock:^(GAHDestination * obj, NSUInteger idx, BOOL *stop) {
                     
                     if ([matchingWayfindingIdentifiers containsObject:obj.wfpName])
                     {
                         matchingMeetingPlayDestinations = [matchingMeetingPlayDestinations arrayByAddingObject:obj];
                     }
                 }];
                 
                 
                 if (rangesOfMatchingSlugs.count > 0)
                 {
                     [matchingSlugIndexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger slugIndex, BOOL *stop)
                      {
                          CHADestination *wayfindingDestination = weakSelf.wayfindingDestinations[slugIndex];
                          GAHDestination *meetingplayDestination = [[GAHDestination destinationsForBaseLocation:wayfindingDestination.destinationName
                                                                                           meetingPlayLocations:weakSelf.meetingPlayDestinations] firstObject];
                          
                          NSString *substitutedInstructionText = @"";
                          if (wayfindingDestination || meetingplayDestination)
                          {
                              [self substituteDestinationNames:(CHAInstruction *)obj
                                       modifiedInstructionText:&substitutedInstructionText
                                        meetingplayDestination:meetingplayDestination
                                         wayfindingDestination:wayfindingDestination
                                                           idx:idx
                                                  instructions:instructions];
                              
                              [(CHAInstruction *)obj setAssociatedPoint:CGPointMake(wayfindingDestination.xCoordinate.floatValue,
                                                                                    wayfindingDestination.yCoordinate.floatValue)];
                          }
                          
                          if (meetingplayDestination && meetingplayDestination.image.length > 0)
                          {
                              NSString *imageString = [NSString stringWithFormat:@"%@%@",[weakSelf.userDefaults objectForKey:kGAHLocationImageURL],[meetingplayDestination.image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                              NSURL *meetingPlayImageURL = [NSURL URLWithString:imageString];
                              [(CHAInstruction *)obj setImageURL:meetingPlayImageURL];
                          }
                          
                          NSMutableDictionary *directionDetail = [NSMutableDictionary new];
                          
                          if (wayfindingDestination)
                          {
                              [directionDetail setObject:wayfindingDestination forKey:GAHWayfindingDestinationKey];
                          }
                              
                          if (meetingplayDestination)
                          {
                              [directionDetail setObject:meetingplayDestination forKey:GAHMeetingplayDestinationKey];
                          }
                          
                          if (substitutedInstructionText.length > 0)
                          {
                              substitutedInstructionText = [substitutedInstructionText stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                                               withString:[[substitutedInstructionText substringToIndex:1] uppercaseString]];
                              [directionDetail setObject:substitutedInstructionText forKey:GAHInstructionKey];
                          }
                          else
                          {
                              if ([(CHAInstruction *)obj text].length > 0)
                              {
                                  NSString *capitalizedInstruction = [[(CHAInstruction *)obj text] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                                                           withString:[[[obj text] substringToIndex:1] uppercaseString]];
                                  [(CHAInstruction *)obj setText:capitalizedInstruction];
                              }
                          }
                          
                          if (directionDetail.allKeys.count)
                          {
                              [weakSelf.directionDetails setObject:directionDetail
                                                            forKey:@(idx)];
                          }
                      }];
                 }
                 else
                 {
                     NSString *capitalizedInstruction = [[(CHAInstruction *)obj text] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                                              withString:[[[obj text] substringToIndex:1] uppercaseString]];
                     [(CHAInstruction *)obj setText:capitalizedInstruction];
                 }
                 
                 
                 NSString *instructionText = [(CHAInstruction *)obj text];
                 if ([instructionText rangeOfString:@"floor" options:NSCaseInsensitiveSearch].location != NSNotFound)
                 {
                     NSString *newInstructionText = [weakSelf substituteFloorText:[(CHAInstruction *)obj text] mapFloorData:floorNumbersAndNames];
                     
                     if (newInstructionText.length > 0)
                     {
                         [(CHAInstruction *)obj setText:newInstructionText];
                     }
                 }
             }
         }];
        
        weakSelf.directionsDataSource.directionDetails = weakSelf.directionDetails;
        [weakSelf.directionsCollectionView.collectionViewLayout invalidateLayout];
        [weakSelf.directionsCollectionView reloadData];
        
        [weakSelf didParseDirections:weakSelf.directionsDataSource];
    });
}

- (NSMutableDictionary *)floorNumbersAndNames
{
    __block NSMutableDictionary *floorNumbersAndNames = [NSMutableDictionary new];
    [self.dataInitializer.mapDataSource.mapImageData enumerateObjectsUsingBlock:^(CHAMapImage *obj, NSUInteger idx, BOOL *stop) {
        
        NSString *key = [NSString stringWithFormat:@"floor #%@",obj.floorNumber];
        NSString *value = [obj.floorName stringByReplacingOccurrencesOfString:@"-" withString:@" "].capitalizedString;
        if (key.length > 0 && value.length > 0)
        {
            [floorNumbersAndNames setObject:value forKey:key];
        }
    }];
    
    return floorNumbersAndNames;
}

- (NSString *)substituteFloorText:(NSString *)instruction mapFloorData:(NSDictionary *)floorNumberAndName
{
    if (instruction.length == 0)
    {
        return nil;
    }
    
    __block NSString *modifiedInstruction = instruction;
    
    [floorNumberAndName enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        modifiedInstruction = [modifiedInstruction stringByReplacingOccurrencesOfString:key
                                                                             withString:obj
                                                                                options:NSCaseInsensitiveSearch
                                                                                  range:NSMakeRange(0, modifiedInstruction.length)];
    }];
    
    return modifiedInstruction;
}

- (NSIndexSet *)indexesOfMatchingSlugsInDirection:(NSString *)directionText wayfindingIdentifiers:(NSArray *)wayfindingIdentifiers
{
    NSIndexSet *matchingSlugIndexes = [wayfindingIdentifiers indexesOfObjectsPassingTest:^BOOL(id wayfindingSlug, NSUInteger wayfindingDestinationIndex, BOOL *stop) {
        
        BOOL didFindDestination = false;

        NSArray *matches = [self searchDirectionText:directionText slug:wayfindingSlug];
        if (matches.count)
        {
            didFindDestination = true;
        }
        return didFindDestination;
    }];
    
    return matchingSlugIndexes;
}

- (NSArray *)searchDirectionText:(NSString *)directionText slug:(NSString *)slug
{
    NSArray *matchingRanges = nil;
    
    NSError *expressionSearchError = nil;
    NSString *slugPattern = [NSString stringWithFormat:@"(?<!\\-)\\b%@\\b",slug];
    NSRegularExpression *locationSlugExpression = [NSRegularExpression regularExpressionWithPattern:slugPattern
                                                                                            options:NSRegularExpressionCaseInsensitive
                                                                                              error:&expressionSearchError];
    if (expressionSearchError)
    {
        DLog(@"\nexpression search error %@", expressionSearchError);
    }
    else
    {
        matchingRanges = [locationSlugExpression matchesInString:directionText options:NSMatchingWithTransparentBounds range:NSMakeRange(0, directionText.length)];
    }
    
    return matchingRanges;
}

- (NSArray *)rangesOfMatchingSlugsInDirection:(NSString *)directionText matchingIndexes:(NSIndexSet *)matchingSlugIndexes wayfindingIdentifiers:(NSArray *)wayfindingIdentifiers
{
    NSMutableArray *rangesOfMatchingSlugs = [NSMutableArray new];
    
    [matchingSlugIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSString *wayfindingSlug = wayfindingIdentifiers[idx];
        NSRange rangeOfSlug = [directionText.lowercaseString
                               rangeOfString:[wayfindingSlug lowercaseString]];
        if (rangeOfSlug.length > 0)
        {
            [rangesOfMatchingSlugs addObject:[NSValue valueWithRange:rangeOfSlug]];
        }
    }];
    
    return [NSArray arrayWithArray:rangesOfMatchingSlugs];
}

- (void)didParseDirections:(GAHDirectionsDataSource *)directionsDataSource
{
    if (self.directionsDelegate && [self.directionsDelegate respondsToSelector:@selector(directionsView:didParseDirections:)])
    {
        [self.directionsDelegate directionsView:self didParseDirections:directionsDataSource];
    }
}

- (BOOL)map:(UIView *)mapView shouldShowRoute:(CHARoute *)route directions:(NSArray *)directionSet forFloor:(NSNumber *)floorNumber
{
    return true;
}

- (void)map:(UIView *)mapView didSwitchRoute:(CHARoute *)route fromFloor:(NSNumber *)sourceFloor toFloor:(NSNumber *)destinationFloor
{
    DLog(@"\ndid switch %@", mapView);
}

#pragma mark Directions Rating
- (void)rateViewDidRateDirections:(GAHRateView *)rateView
{
    //        if (rateView.value < 3)
    if (rateView)
    {
        __weak __typeof(&*self)weakSelf = self;
        
        NSString *startLocation = weakSelf.start.destinationName.length > 0 ? weakSelf.start.destinationName : [NSString stringWithFormat:@"floor %@ and location (%@,%@)",
                                                                                                                weakSelf.start.floorNumber,weakSelf.start.xCoordinate,weakSelf.start.yCoordinate];
        
        NSString *messageBodyText = [NSString stringWithFormat:@"I submitted a %@ star rating for directions from <a href=\"http://%@\">my location</a> to <a href=\"http://%@\">%@</a> because...",
                                     @(rateView.value), startLocation,weakSelf. destination.slug, weakSelf.destination.location];
        
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *feedbackComposer = [[MFMailComposeViewController alloc] init];
            feedbackComposer.mailComposeDelegate = self;
            
            [feedbackComposer setSubject:@"Wayfinding Feedback"];
            [feedbackComposer setToRecipients:@[@"Gaylord Wayfinding Feedback <gaylord@meetingplay.com>"]];

            
            [feedbackComposer setMessageBody:messageBodyText isHTML:YES];
            
            [self presentViewController:feedbackComposer animated:true completion:nil];
        }
        else
        {
            SIAlertView *emailDisabledAlert = [[SIAlertView alloc] initWithTitle:@"Cannot Send Mail"
                                                                      andMessage:@"We cannot send feedback via e-mail, because the Mail application has not beeen setup. Please add a"];
            [emailDisabledAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
            [emailDisabledAlert show];
        }
    }
    else
    {
        NSString *ratingAlertMessage = [NSString stringWithFormat:@"Your rating has been sent.\n\nThank you for your feedback!"];
        SIAlertView *ratingAlert = [[SIAlertView alloc] initWithTitle:@"Rating Submitted" andMessage:ratingAlertMessage];
        [ratingAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
        [ratingAlert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error)
    {
        SIAlertView *sendMailError = [[SIAlertView alloc] initWithTitle:@"Error Sending Feedback"
                                                             andMessage:@"There was an error submitting the feedback"];
        [sendMailError addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
        [sendMailError show];
    }
    else
    {
        if (result == MFMailComposeResultCancelled || result == MFMailComposeResultFailed)
        {
            [self dismissViewControllerAnimated:true completion:nil];
        }
        else if (result == MFMailComposeResultSent)
        {
            NSString *ratingAlertMessage = [NSString stringWithFormat:@"Your feedback has been sent.\n\nThank you!"];
            SIAlertView *ratingAlert = [[SIAlertView alloc] initWithTitle:@"Feedback Submitted" andMessage:ratingAlertMessage];
            
            __weak __typeof(&*self)weakSelf = self;
            [ratingAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                [weakSelf dismissViewControllerAnimated:true completion:nil];
            }];
            
            [ratingAlert show];
        }
        else
        {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }
}

#pragma mark - Initial Setup
- (void)setupConstraints
{
    [self.directionsCollectionView.superview addConstraints:[self.directionsCollectionView pinToSuperviewBounds]];
}

- (void)clearDirections
{
    [self.directionsDataSource resetDirectionData];
    [self.directionsCollectionView reloadData];
}


@end





#pragma mark - Directions Data Source
#import "GAHDirectionDetailViewController.h"
#import "CHARoute.h"
#import "CHAMapLocation.h"
#import "CHADirectionSet.h"
#import "CHAFloorPathInfo.h"
#import "UIImageView+AFNetworking.h"

@interface GAHDirectionsDataSource () <GAHDirectionCellDelegate>
@property (nonatomic, strong) UILabel *sizingLabel;
@end

@implementation GAHDirectionsDataSource

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier
                     cellLayoutHandler:(DirectionsCellLayoutHandler)cellLayoutHandler
{
    if (self = [super init])
    {
        _cellReuseIdentifier = cellIdentifier;
        _cellLayoutHandler = cellLayoutHandler;
        _routeData = nil;
        _singleDirectives = [NSArray new];
        
        _sizingLabel = [[UILabel alloc] init];
        _sizingLabel.font = [UIFont fontWithName:@"MyriadPro-Bold" size:17.f];
        _sizingLabel.numberOfLines = 0;
        _sizingLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _sizingLabel.minimumScaleFactor = 1;
    }
    
    return self;
}

- (NSArray *)createSingleDirectiveDataSource:(NSArray *)directionSets
{
    NSMutableArray *singleDirections = [NSMutableArray new];
    
    for (CHADirectionSet *directions in directionSets)
    {
        if (directions.directionSet.count > 0)
        {
            [singleDirections addObjectsFromArray:directions.directionSet];
        }
    }
    
    self.singleDirectives = singleDirections;
    
    return singleDirections;
}

- (void)resetDirectionData
{
    self.singleDirectives = [NSArray new];
    self.routeData = nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSInteger rowCount;
    rowCount = self.singleDirectives.count;
    
    return rowCount;
}

static CGFloat baseCellHeight = 50.f;

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[GAHDirectionCell class]])
    {
        CHAInstruction *instruction = self.singleDirectives[indexPath.row];
        if (instruction.imageURL && instruction.imageURL.absoluteString.length > 0)
        {
            [(GAHDirectionCell *)cell imageHeightConstraint].constant = cellImageHeight;
        }
        else
        {
            [(GAHDirectionCell *)cell imageHeightConstraint].constant = 0;
        }
        
//        [[(GAHDirectionCell *)cell stepLocationImage] setImage:nil];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GAHDirectionCell *cell = (GAHDirectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:self.cellReuseIdentifier
                                                                                           forIndexPath:indexPath];
    
    cell.directionCellDelegate = self;
    cell.cellIndex = indexPath;
    
    cell.directionTextLabel.numberOfLines = 0;
    cell.directionTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    CHAInstruction *instruction = self.singleDirectives[indexPath.row];
    
    if (self.cellLayoutHandler)
    {
        self.cellLayoutHandler(cell,instruction,indexPath);
    }
    
    return cell;
}

const CGFloat cellSpacing = 15.f;
const CGFloat collectionViewSideInset = 10;
const CGFloat stepNumberLabelWidth = 35.f;
const CGFloat stepNumberAndDirectionsLabelSpacing = 10;

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize collectionViewCellSize = CGSizeZero;
    collectionViewCellSize.width = CGRectGetWidth(collectionView.frame) - (collectionViewSideInset * 2.f);
    
    CHAInstruction *instruction = self.singleDirectives[indexPath.row];
    self.sizingLabel.text = instruction.text;
    
    CGFloat targetWidth = collectionViewCellSize.width - stepNumberLabelWidth - (stepNumberAndDirectionsLabelSpacing) - (collectionViewSideInset * 2.f);
    CGSize labelSize = [self.sizingLabel sizeThatFits:CGSizeMake(targetWidth,MAXFLOAT)];
    if (labelSize.height + cellSpacing + 10 > baseCellHeight)
    {
        collectionViewCellSize.height = labelSize.height + cellSpacing + 10;
    }
    else
    {
        collectionViewCellSize.height = baseCellHeight;
    }
    
    NSDictionary *directionDetails = [self.directionDetails objectForKey:@(indexPath.row)];
    NSURL *imageURL = [self imageURLForDestination:directionDetails];
    
    if (imageURL)
    {
        collectionViewCellSize.height += (collectionViewCellSize.width - (collectionViewSideInset * 2)) * 0.75;
    }
    
    return collectionViewCellSize;
}

- (NSURL *)imageURLForDestination:(NSDictionary *)destinationDetails
{
    NSURL *imageURL = nil;
    if (destinationDetails)
    {
        CHADestination *wayfindingDestination = [destinationDetails objectForKey:GAHWayfindingDestinationKey];
        NSString *wfpThumb = [wayfindingDestination.details objectForKey:@"thumbnail"];
        if (wfpThumb.length)
        {
            imageURL = [NSURL URLWithString:wfpThumb];
        }
        else
        {
            GAHDestination *meetingplayDestination = [destinationDetails objectForKey:GAHMeetingplayDestinationKey];
            NSString *imageFilename = [meetingplayDestination.image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (imageFilename.length)
            {
                NSString *imageString = [NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:kGAHLocationImageURL],imageFilename];
                imageURL = [NSURL URLWithString:imageString];
            }
            else
            {
                //            NSLog(@"no image found");
            }
        }
    }
    return imageURL;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *locationWithImage = self.directionDetails[@(indexPath.row)];
    if (locationWithImage)
    {
        NSURL *imageURL = nil;
        NSString *imageString = nil;
        
        GAHDestination *directionDestination = [locationWithImage objectForKey:GAHMeetingplayDestinationKey];
        NSString *imageName = [directionDestination.image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (imageName.length > 0)
        {
            imageString = [NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:kGAHLocationImageURL],imageName];
            imageURL = [NSURL URLWithString:imageString];
        }
        
        BOOL infiniteScroll = NO;
        
        CHADestination *wayfindingDestination = [locationWithImage objectForKey:GAHWayfindingDestinationKey];
        if ([[wayfindingDestination.details objectForKey:@"images"] count])
        {
            imageString = [[wayfindingDestination.details objectForKey:@"images"] firstObject];
            if (imageString.length > 0)
            {
                imageURL = [NSURL URLWithString:imageString];
                infiniteScroll = YES;
            }
            else
            {
                NSLog(@"image string was empty %@", wayfindingDestination.details);
            }
        }
        else
        {
            NSLog(@"images were empty %@", wayfindingDestination.details);
        }
        
        
        if (imageURL)
        {
            GAHDirectionDetailViewController *directionDetail = [[UIStoryboard storyboardWithName:@"GAHDirectionDetailViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"GAHDirectionDetailViewController"];
            [directionDetail configureThreeSixtyViewImageURL:imageURL parentView:directionDetail.view infiniteScroll:infiniteScroll];
            directionDetail.imageURL = imageURL;
            
            
            [self.directionsViewController presentViewController:directionDetail animated:true completion:^{
                //            [directionDetail loadImage:imageURL];
            }];
        }
    }
}

- (void)directionCell:(GAHDirectionCell *)directionCell didSelectLocation:(NSIndexPath *)cellIndex
{
    [self collectionView:self.directionsViewController.directionsCollectionView didSelectItemAtIndexPath:cellIndex];
}




- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    GAHRatingFooter *ratingFooter = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                       withReuseIdentifier:@"GAHRatingFooter"
                                                                              forIndexPath:indexPath];
    return ratingFooter;
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end