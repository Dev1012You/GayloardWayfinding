//
//  GAHPanelView.h
//  GaylordHotels
//
//  Created by MeetingPlay on 6/26/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAHPanelView : UIView

@property (weak, nonatomic) IBOutlet UIView *panelContainer;
@property (weak, nonatomic) IBOutlet UIView *panelTitleContainer;
@property (weak, nonatomic) IBOutlet UILabel *panelTitle;

@property (weak, nonatomic) IBOutlet UIView *panelContent;


- (void)createContainerShadow;

@end
