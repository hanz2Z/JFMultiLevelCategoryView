//
//  JFCategoryViewController.h
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFCategorySelectViewFactoryProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class JFLevelVMHolder;

@class JFCategoryViewController;

@protocol JFCategoryViewControllerDelegate <NSObject>

- (void)categoryController:(JFCategoryViewController *)controller didSelectIndex:(NSInteger)index;

@end

@interface JFCategoryViewController : UIViewController

@property (nonatomic, strong, nullable) NSArray<JFLevelVMHolder *> *holders;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) BOOL selectViewFloating;
@property (nonatomic, assign) CGFloat selectViewHeight;

@property (nonatomic, weak) id<JFCategoryViewControllerDelegate> delegate;

@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

- (id)initWithSelectViewFactory:(id<JFCategorySelectViewFactoryProtocol>)factory;

- (void)updateView;

@end

NS_ASSUME_NONNULL_END
