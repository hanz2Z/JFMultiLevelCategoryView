//
//  JFCollectionViewCell.h
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFLevelVMHolder.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) JFLevelVMHolder *holder;

@end

NS_ASSUME_NONNULL_END
