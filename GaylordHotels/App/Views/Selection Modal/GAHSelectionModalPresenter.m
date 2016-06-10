//
//  GAHSelectionModalPresenter.m
//  GaylordHotels
//
//  Created by John Pacheco on 11/24/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHSelectionModalPresenter.h"
#import "GAHSelectionModalView.h"

#import "UIView+AutoLayoutHelper.h"

@implementation GAHSelectionModalPresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _selectionView = [self createSelectionModal];
    }
    return self;
}

- (GAHSelectionModalView *)createSelectionModal
{
    GAHSelectionModalView *newSelectionModal = [GAHSelectionModalView new];
    newSelectionModal.translatesAutoresizingMaskIntoConstraints = false;
    newSelectionModal.selectionModalDelegate = self;
    [newSelectionModal setupDefaultAppearance:true];
    
    return newSelectionModal;
}

- (void)presentSelectionModalInView:(UIView *)presentationView selectionHandler:(void(^)(NSIndexPath *indexPath))selectionHandler
{
    [presentationView addSubview:self.selectionView];
    [presentationView addConstraints:[self.selectionView pinToSuperviewBoundsInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    if (selectionHandler)
    {
        self.selectionHandler = selectionHandler;
    }
}

- (void)removeSelectionModalFromParentView
{
    [self.selectionView removeFromSuperview];
}

- (void)loadData:(NSArray *)dataSource
{
    [self.selectionView prepareData:dataSource];
}

- (UITableViewCell *)selectionModalTableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell data:(id)rowData atIndexPath:(NSIndexPath *)indexPath
{
    if (self.modalCellCongiuration)
    {
        self.modalCellCongiuration(cell,rowData);
    }
    
    return cell;
}

- (void)selectionModalTableView:(UITableView *)tableView didSelectData:(id)rowData atIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectionHandler)
    {
        self.selectionHandler(indexPath);
    }
    
    [self.selectionView removeFromSuperview];
}


@end
