//
//  JFMultiLevelCategoryView.h
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double JFMultiLevelCategoryViewVersionNumber;

FOUNDATION_EXPORT const unsigned char JFMultiLevelCategoryViewVersionString[];

#import <UIKit/UIKit.h>
#import <JFMultiLevelCategoryView/JFCategorySelectViewProtocol.h>
#import <JFMultiLevelCategoryView/JFCategorySelectViewFactoryProtocol.h>
#import <JFMultiLevelCategoryView/JFContentViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class JFMultiLevelCategoryView;

@protocol JFMultiLevelCategoryViewDelegate <NSObject>

- (void)loadCategoriesForCategoryView:(JFMultiLevelCategoryView *)view
                    indicesAtUpLevels:(NSArray<NSNumber *> *)selectedIndices
                           categories:(void (^)(NSArray<NSString *> * categories))categories
                            content:(void (^)(id content))content
                              failure:(void (^)(NSError *error))failure;

- (CGFloat)categoryView:(JFMultiLevelCategoryView *)view selectorHeightForIndicesAtUpLevels:(NSArray<NSNumber *> *)selectedIndices;

- (BOOL)categoryView:(JFMultiLevelCategoryView *)view sececotrShouldFloatingForIndicesAtUpLevels:(NSArray<NSNumber *> *)selectedIndices;

- (id<JFCategorySelectViewFactoryProtocol>)categoryView:(JFMultiLevelCategoryView *)view
                      selectorFactoryForIndicesAtUpLevels:(NSArray<NSNumber *> *)selectedIndices;

- (JFContentViewController *)categoryView:(JFMultiLevelCategoryView *)view
                     controllerForContent:(id)content
                        indicesAtUpLevels:(NSArray<NSNumber *> *)selectedIndices;

- (void)categoryView:(JFMultiLevelCategoryView *)view containerTopOffsetChangeTo:(CGFloat)offset;

@end

@interface JFMultiLevelCategoryView : UIView

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, weak) id<JFMultiLevelCategoryViewDelegate> delegate;

@property (nonatomic, assign) CGFloat containerMinimumTopOffset;

- (JFContentViewController *)dequeueReusableControllerWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)reload;

- (void)reloadCurrentDisplaying;

- (void)displayIndices:(NSArray *)indices;

@end

NS_ASSUME_NONNULL_END
