//
//  GAHSelectionModalPresenter.h
//  GaylordHotels
//
//  Created by John Pacheco on 11/24/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAHSelectionModalView.h"

@interface GAHSelectionModalPresenter : NSObject <GAHSelectionModalDelegate>

@property (nonatomic, strong) GAHSelectionModalView *selectionView;

@property (nonatomic, copy) void(^selectionHandler)(NSIndexPath *);
@property (nonatomic, copy) void(^modalCellCongiuration)(UITableViewCell *,id cellData);

- (void)loadData:(NSArray *)dataSource;
- (void)presentSelectionModalInView:(UIView *)presentationView selectionHandler:(void(^)(NSIndexPath *indexPath))selectionHandler;
- (void)removeSelectionModalFromParentView;

@end
