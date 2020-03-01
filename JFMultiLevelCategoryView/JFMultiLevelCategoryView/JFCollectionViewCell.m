//
//  JFCollectionViewCell.m
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import "JFCollectionViewCell.h"

@implementation JFCollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];

    [_holder removeFromSuperview];

    _holder = nil;
}

- (void)setHolder:(JFLevelVMHolder *)holder
{
    _holder = holder;

    [_holder addToSuperview:self.contentView];
}

@end
