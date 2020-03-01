//
//  JFLevelVMHolder.m
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import "JFLevelVMHolder.h"
#import <Masonry/Masonry.h>

@interface JFLevelVMHolder () <JFLevelVMHolderDelegate, JFCategoryViewControllerDelegate>

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, strong, nullable) JFCategoryViewController *categoryViewController;

@property (nonatomic, strong, nullable) JFContentViewController *contentViewController;

@property (nonatomic, assign) JFLevelVMHolderState state;

@end

@implementation JFLevelVMHolder

- (id)init {
    if (self = [super init]) {
        _state = JFLevelVMHolderInitState;
    }

    return self;
}

- (void)invalid
{
    _loadingNumber += 1;
    _content = nil;
    _subHolders = nil;
    _selectedSubHolderIndex = -1;
    _state = JFLevelVMHolderInitState;

    if (self.superView) {
        [self unloadController];

        [self load];
    }
}

- (void)addToSuperview:(UIView *)superView
{
    if (superView != _superView) {
        _superView = superView;

         if (_state == JFLevelVMHolderInitState) {
             [self load];
         }
         else if (_state == JFLevelVMHolderFinishedState) {
             [self loadController];
         }
         else if (_state == JFLevelVMHolderFailedState) {

         }
    }
}

- (void)removeFromSuperview
{
    [self unloadController];

    _superView = nil;
}

- (void)setSelectedSubHolderIndex:(NSInteger)selectedSubHolderIndex
{
    _selectedSubHolderIndex = selectedSubHolderIndex;

    if (self.categoryViewController) {
        self.categoryViewController.selectedIndex = selectedSubHolderIndex;
    }
}

- (void)holderAskToLoad:(JFLevelVMHolder *)holder
                indices:(NSMutableArray *)indices
             categories:(void (^)(NSArray<NSString *> * categories))categories
                content:(void (^)(id content))content
                failure:(void (^)(NSError *error))failure;
{
    NSInteger index = [self.subHolders indexOfObject:holder];
    [indices insertObject:@(index) atIndex:0];

    [self.delegate holderAskToLoad:self indices:indices categories:categories content:content failure:failure];
}

- (JFCategoryViewController *)createOrRetriveCategoryControllerForHolder:(JFLevelVMHolder *)holder
                                                                 indices:(NSMutableArray *)indices;
{
    NSInteger index = [self.subHolders indexOfObject:holder];
    [indices insertObject:@(index) atIndex:0];

    JFCategoryViewController *vc = [self.delegate createOrRetriveCategoryControllerForHolder:self indices:indices];

    return vc;
}

- (JFContentViewController *)contentControllerForHolder:(JFLevelVMHolder *)holder
                                                               indices:(NSMutableArray *)indices;
{
    NSInteger index = [self.subHolders indexOfObject:holder];
    [indices insertObject:@(index) atIndex:0];

    JFContentViewController *vc = [self.delegate contentControllerForHolder:self indices:indices];

    return vc;
}

- (void)holder:(JFLevelVMHolder *)holder recycleCategoryController:(JFCategoryViewController *)controller
{
    [self.delegate holder:self recycleCategoryController:controller];
}

- (void)holder:(JFLevelVMHolder *)holder recycleContentController:(JFContentViewController *)controller
{
    [self.delegate holder:self recycleContentController:controller];
}

- (void)load
{
    _loadingNumber += 1;
    long long loadingNumber = self.loadingNumber;

    NSMutableArray *indices = [NSMutableArray new];

    _state = JFLevelVMHolderLoadingState;

    __weak typeof(self) ws = self;
    [self.delegate holderAskToLoad:self indices:indices categories:^(NSArray<NSString *> * _Nonnull categories) {
        if (loadingNumber == ws.loadingNumber) {
            NSMutableArray *list = [NSMutableArray array];
            for (NSString *category in categories) {
                JFLevelVMHolder *holder = [JFLevelVMHolder new];
                holder.title = category;
                holder.parentHolder = self;
                holder.delegate = self;

                [list addObject:holder];
            }
            ws.subHolders = list;
            ws.selectedSubHolderIndex = list.count > 0 ? 0 : -1;

            ws.state = JFLevelVMHolderFinishedState;
            [ws loadController];
        }
    } content:^(id  _Nonnull content) {
        if (loadingNumber == ws.loadingNumber) {
            ws.content = content;

            ws.state = JFLevelVMHolderFinishedState;
            [ws loadController];
        }
    } failure:^(NSError * _Nonnull error) {
        if (loadingNumber == ws.loadingNumber) {
            ws.state = JFLevelVMHolderFailedState;

            [ws loadErrorController];
        }
    }];
}

- (void)loadController
{
    if (self.superView) {
        if (self.content) {
            NSMutableArray *indices = [NSMutableArray new];
            self.contentViewController = [self.delegate contentControllerForHolder:self indices:indices];
            [self.superView addSubview:self.contentViewController.view];
            [self.contentViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(0);
            }];
        }
        else if (self.subHolders) {
            NSMutableArray *indices = [NSMutableArray new];
            self.categoryViewController = [self.delegate createOrRetriveCategoryControllerForHolder:self indices:indices];
            //self.categoryViewController.delegate = self;
            self.categoryViewController.holders = self.subHolders;
            self.categoryViewController.selectedIndex = self.selectedSubHolderIndex;
            self.categoryViewController.delegate = self;
            [self.superView addSubview:self.categoryViewController.view];
            [self.categoryViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(0);
            }];

            [self.categoryViewController updateView];
        }
    }
}

- (void)unloadController
{
    if (self.contentViewController) {
        [self.contentViewController.view removeFromSuperview];
    }
    else {
        [self.categoryViewController.view removeFromSuperview];
        self.categoryViewController.holders = nil;
    }

    [self recycleController];
}

- (void)loadErrorController
{
    if (self.superView) {

    }
}

- (void)recycleController
{
    if (self.contentViewController) {
        JFContentViewController *contentVC = self.contentViewController;
        if ([contentVC isViewLoaded]) {
            [contentVC.view removeFromSuperview];
        }
        [self.delegate holder:self recycleContentController:contentVC];
        self.contentViewController = nil;
    }
    else if (self.categoryViewController) {
        JFCategoryViewController *categoryVC = self.categoryViewController;

        if ([categoryVC isViewLoaded]) {
            [categoryVC.view removeFromSuperview];
        }
        categoryVC.holders = nil;
        categoryVC.selectedIndex = -1;
        [self.delegate holder:self recycleCategoryController:categoryVC];
        self.categoryViewController = nil;
    }
}
- (void)categoryController:(JFCategoryViewController *)controller didSelectIndex:(NSInteger)index
{
    _selectedSubHolderIndex = index;
}

@end
