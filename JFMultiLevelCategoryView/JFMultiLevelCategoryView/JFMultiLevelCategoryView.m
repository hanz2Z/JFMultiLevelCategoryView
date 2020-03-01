//
//  JFMultiLevelCategoryView.m
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import "JFMultiLevelCategoryView.h"
#import "JFLevelVMHolder.h"
#import "JFNestedScrollView.h"
#import <Masonry/Masonry.h>

@interface JFMultiLevelCategoryView () <JFLevelVMHolderDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) JFNestedScrollView *scrollView;
@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *reusedCategoryViewControllerMap;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *reusedContentViewControllerMap;

@property (nonatomic, strong) JFLevelVMHolder *rootHolder;
@property (nonatomic, assign) BOOL needReload;

@property (nonatomic, strong) NSArray *desiredDisplayIndices;

@end

@implementation JFMultiLevelCategoryView

- (void)dealloc
{
    NSLog(@"JFMultiLevelCategoryView released!");
}

- (id)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self initData];

        [self initView];
    }

    return self;
}

- (void)initData
{
    self.reusedCategoryViewControllerMap = [NSMutableDictionary dictionary];
    self.reusedContentViewControllerMap = [NSMutableDictionary dictionary];

    self.rootHolder = [JFLevelVMHolder new];
    self.rootHolder.delegate = self;

    _needReload = YES;
}

- (void)initView
{
    JFNestedScrollView *scrollView = [JFNestedScrollView new];
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    scrollView.bounces = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    scrollView.delegate = self;
    self.scrollView = scrollView;

    UIView *contentView = [UIView new];
    [scrollView addSubview:contentView];
    self.contentView = contentView;

    [self.rootHolder addToSuperview:self.contentView];
}

- (void)updateConstraints
{
    [super updateConstraints];

    [_headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.top.left.right.mas_equalTo(0);
    }];
    //[_headerView layoutIfNeeded];

    //CGFloat headerHeight = _headerView.frame.size.height;

    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (_headerView) {
            make.top.mas_equalTo(_headerView.mas_bottom);
        }
        else {
            make.top.mas_equalTo(_containerMinimumTopOffset);
        }
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(self);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self).mas_offset(-_containerMinimumTopOffset);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (_needReload) {
        [self _reload];
        _needReload = NO;
    }
}

- (void)reload
{
    _needReload = YES;
    _desiredDisplayIndices = nil;

    [self setNeedsLayout];
}

- (void)_reload
{
    [self.rootHolder invalid];
    //[self.rootHolder addToSuperview:_contentView];
}

- (void)setHeaderView:(UIView *)headerView
{
    [_headerView removeFromSuperview];
    _headerView = headerView;
    [self.scrollView addSubview:_headerView];

    [self setNeedsUpdateConstraints];
}

- (void)setContainerMinimumTopOffset:(CGFloat)contentViewTopOffset
{
    _containerMinimumTopOffset = contentViewTopOffset;

    [self setNeedsUpdateConstraints];
}

- (void)reloadCurrentDisplaying
{
    JFLevelVMHolder *currentHolder = self.rootHolder;
    while (currentHolder.subHolders) {
        if (currentHolder.selectedSubHolderIndex >= 0) {
            currentHolder = currentHolder.subHolders[currentHolder.selectedSubHolderIndex];
        }
        else {
            break;
        }
    }

    [currentHolder invalid];
}

- (void)displayIndices:(NSArray *)indices
{
    if (_needReload) {
        _desiredDisplayIndices = indices;
    }
    else {
        _desiredDisplayIndices = nil;

        JFLevelVMHolder *currentHolder = self.rootHolder;
        for (NSNumber *number in indices) {
            NSInteger index = [number integerValue];

            if (currentHolder.subHolders) {
                currentHolder.selectedSubHolderIndex = index;
                currentHolder = currentHolder.subHolders[index];
            }
            else if (currentHolder.state == JFLevelVMHolderFinishedState ||
                     currentHolder.state == JFLevelVMHolderFailedState) {
                break;
            }
            else {
                _desiredDisplayIndices = indices;
                break;
            }
        }
    }
}

- (void)holderAskToLoad:(JFLevelVMHolder *)holder
                indices:(NSMutableArray *)indices
             categories:(void (^)(NSArray<NSString *> * categories))categories
                content:(void (^)(id content))content
                failure:(void (^)(NSError *error))failure
{
    __weak typeof(self) ws = self;

    JFLevelVMHolder *holderNeedLoad = self.rootHolder;

    for (NSNumber *number in indices) {
        NSInteger index = [number integerValue];
        holderNeedLoad = holderNeedLoad.subHolders[index];
    }

    [self.delegate loadCategoriesForCategoryView:self indicesAtUpLevels:indices categories:^(NSArray<NSString *> * _Nonnull list) {
        categories(list);

        if (ws.desiredDisplayIndices) {
            if (indices.count < ws.desiredDisplayIndices.count) {
                NSNumber *number = ws.desiredDisplayIndices[indices.count];
                NSInteger index = [number integerValue];

                if (indices.count > 0) {
                    NSInteger upIndex = [[indices lastObject] integerValue];
                    NSInteger upDesiredIndex = [ws.desiredDisplayIndices[indices.count - 1] integerValue];

                    if (upIndex == upDesiredIndex) {
                        holderNeedLoad.selectedSubHolderIndex = index;
                    }
                }
                else {
                    holderNeedLoad.selectedSubHolderIndex = index;
                }
            }
        }
    } content:^(id  _Nonnull data) {
        content(data);
    } failure:^(NSError * _Nonnull e) {
        failure(e);
    }];
}

- (JFCategoryViewController *)createOrRetriveCategoryControllerForHolder:(JFLevelVMHolder *)holder
                                                                 indices:(NSMutableArray *)indices
{
    id<JFCategorySelectViewFactoryProtocol> factory = [self.delegate categoryView:self selectorFactoryForIndicesAtUpLevels:indices];
    NSString *reuseIdentifier = [factory reuseIdentifier];
    NSMutableArray *list = [self.reusedCategoryViewControllerMap objectForKey:reuseIdentifier];

    BOOL shouldFloating = [self.delegate categoryView:self sececotrShouldFloatingForIndicesAtUpLevels:indices];
    CGFloat height = [self.delegate categoryView:self selectorHeightForIndicesAtUpLevels:indices];

    if (list.count > 0) {
        JFCategoryViewController *vc = [list firstObject];
        vc.selectViewFloating = shouldFloating;
        vc.selectViewHeight = height;
        [list removeObject:vc];
        return vc;
    }
    else {
        JFCategoryViewController *vc = [[JFCategoryViewController alloc] initWithSelectViewFactory:factory];
        vc.selectViewFloating = shouldFloating;
        vc.selectViewHeight = height;
        return vc;
    }
}

- (JFContentViewController *)dequeueReusableControllerWithReuseIdentifier:(NSString *)reuseIdentifier
{
    NSMutableArray *list = [self.reusedContentViewControllerMap objectForKey:reuseIdentifier];
    if (list.count > 0) {
        JFContentViewController *vc = [list firstObject];
        [list removeObject:vc];
        return vc;
    }
    else {
        return nil;
    }
}

- (JFContentViewController *)contentControllerForHolder:(JFLevelVMHolder *)holder
                                                               indices:(NSMutableArray *)indices
{
    JFLevelVMHolder *holderNeedLoad = self.rootHolder;

    for (NSNumber *number in indices) {
        NSInteger index = [number integerValue];
        holderNeedLoad = holderNeedLoad.subHolders[index];
    }

    JFContentViewController *vc = [self.delegate categoryView:self
                                         controllerForContent:holderNeedLoad.content
                                            indicesAtUpLevels:indices];

    return vc;
}

- (void)holder:(JFLevelVMHolder *)holder recycleCategoryController:(JFCategoryViewController *)controller
{
    NSString *reuseIdentifier = controller.reuseIdentifier;
    if (reuseIdentifier) {
        NSMutableArray *list = [self.reusedCategoryViewControllerMap objectForKey:reuseIdentifier];
        if (list) {
            [list addObject:controller];
        }
        else {
            list = [NSMutableArray arrayWithObject:controller];
            [self.reusedCategoryViewControllerMap setObject:list forKey:reuseIdentifier];
        }
    }
}

- (void)holder:(JFLevelVMHolder *)holder recycleContentController:(JFContentViewController *)controller
{
    NSString *reuseIdentifier = controller.reuseIdentifier;
    if (reuseIdentifier) {
        NSMutableArray *list = [self.reusedContentViewControllerMap objectForKey:reuseIdentifier];
        if (list) {
            [list addObject:controller];
        }
        else {
            list = [NSMutableArray arrayWithObject:controller];
            [self.reusedContentViewControllerMap setObject:list forKey:reuseIdentifier];
        }
    }
}

-  (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = 0;
    if (self.headerView) {
        CGFloat y = scrollView.contentOffset.y;
        offset = self.headerView.frame.size.height - y;
    }
    else {
        offset = _containerMinimumTopOffset;
    }

    [self.delegate categoryView:self containerTopOffsetChangeTo:offset];
}

@end
