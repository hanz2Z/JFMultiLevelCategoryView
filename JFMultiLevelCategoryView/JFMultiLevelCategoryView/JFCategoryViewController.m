//
//  JFCategoryViewController.m
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import "JFCategoryViewController.h"
#import "JFNestedScrollView.h"
#import "JFNestedCollectionView.h"
#import "JFLevelVMHolder.h"
#import "JFCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface JFCategoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) id<JFCategorySelectViewFactoryProtocol> selectorFactory;

@property (nonatomic, weak) UIView<JFCategorySelectViewProtocol> *selectView;
@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation JFCategoryViewController

- (void)loadView
{
    JFNestedScrollView *view = [JFNestedScrollView new];
    view.bounces = NO;
    view.showsVerticalScrollIndicator = NO;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIControl<JFCategorySelectViewProtocol> *selectView = [self.selectorFactory createSelectView];
    [self.view addSubview:selectView];
    [selectView addTarget:self action:@selector(selectedIndexChanged:) forControlEvents:UIControlEventValueChanged];
    self.selectView = selectView;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    JFNestedCollectionView *collectionView = [[JFNestedCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.bounces = NO;
    collectionView.pagingEnabled = YES;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.allowsMultipleSelection = NO;
    [collectionView registerClass:[JFCollectionViewCell class] forCellWithReuseIdentifier:@"CategoryID"];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}

- (id)initWithSelectViewFactory:(id<JFCategorySelectViewFactoryProtocol>)factory
{
    if (self = [super init]) {
        _selectorFactory = factory;
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;

    [self updateViewForSelectedIndex];
}

- (void)updateView
{
    NSMutableArray *list = [NSMutableArray array];
    for (JFLevelVMHolder *holder in self.holders) {
        [list addObject:holder.title];
    }

    [self.selectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.top.left.right.mas_equalTo(0);

        // TODO:
        make.height.mas_equalTo(_selectViewHeight);
    }];
    self.selectView.items = list;

    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectView.mas_bottom);
        make.width.mas_equalTo(self.view);
        make.left.right.bottom.mas_equalTo(0);

        if (_selectViewFloating) {
            make.height.mas_equalTo(self.view).mas_offset(-_selectViewHeight);
        }
        else {
            make.height.mas_equalTo(self.view);
        }
    }];
    [self.collectionView reloadData];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViewForSelectedIndex];
    });
}

- (void)updateViewForSelectedIndex
{
    self.selectView.selectedIndex = self.selectedIndex;
    [self.collectionView setContentOffset:CGPointMake(self.selectedIndex * self.collectionView.frame.size.width, 0)];
}

- (NSString *)reuseIdentifier
{
    return [self.selectorFactory reuseIdentifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.holders.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JFCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryID" forIndexPath:indexPath];
    cell.holder = self.holders[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.selectView.selectedIndex = index;

    [self.delegate categoryController:self didSelectIndex:index];
}

- (void)selectedIndexChanged:(UIView<JFCategorySelectViewProtocol> *)sender
{
    UICollectionView *collectionView = self.collectionView;

    NSInteger index = sender.selectedIndex;

    [collectionView setContentOffset:CGPointMake(index * collectionView.frame.size.width, 0)];

    [self.delegate categoryController:self didSelectIndex:index];
}

@end
