//
//  GAHPanelView.m
//  GaylordHotels
//
//  Created by MeetingPlay on 6/26/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHPanelView.h"

@implementation GAHPanelView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self createContainerShadow];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)createContainerShadow
{
    self.panelContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.panelContainer.layer.shadowOpacity = 1.f;
    self.panelContainer.layer.shadowRadius = 5.f;
}


@end
