//
//  JFLevelVMHolder.h
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFCategoryViewController.h"
#import "JFContentViewController.h"

typedef enum : NSUInteger {
    JFLevelVMHolderInitState,
    JFLevelVMHolderLoadingState,
    JFLevelVMHolderFinishedState,
    JFLevelVMHolderFailedState
} JFLevelVMHolderState;

NS_ASSUME_NONNULL_BEGIN

@class JFLevelVMHolder;

@protocol JFLevelVMHolderDelegate <NSObject>

- (void)holderAskToLoad:(JFLevelVMHolder *)holder
                indices:(NSMutableArray *)indices
             categories:(void (^)(NSArray<NSString *> * categories))categories
                content:(void (^)(id content))content
                failure:(void (^)(NSError *error))failure;

- (JFCategoryViewController *)createOrRetriveCategoryControllerForHolder:(JFLevelVMHolder *)holder indices:(NSMutableArray *)indices;

- (JFContentViewController *)contentControllerForHolder:(JFLevelVMHolder *)holder indices:(NSMutableArray *)indices;

- (void)holder:(JFLevelVMHolder *)holder recycleCategoryController:(JFCategoryViewController *)controller;

- (void)holder:(JFLevelVMHolder *)holder recycleContentController:(JFContentViewController *)controller;

@end

@interface JFLevelVMHolder : NSObject

@property (nonatomic, weak) JFLevelVMHolder *parentHolder;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign, readonly) JFLevelVMHolderState state;
@property (nonatomic, assign, readonly) long long loadingNumber;

@property (nonatomic, assign) id<JFLevelVMHolderDelegate> delegate;

@property (nonatomic, strong) NSArray<JFLevelVMHolder *> *subHolders;
@property (nonatomic, assign) NSInteger selectedSubHolderIndex;

@property (nonatomic, strong) id content;

- (void)invalid;

- (void)addToSuperview:(UIView *)superView;

- (void)removeFromSuperview;

@end

NS_ASSUME_NONNULL_END
