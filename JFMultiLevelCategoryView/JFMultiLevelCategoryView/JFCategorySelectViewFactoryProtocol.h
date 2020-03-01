//
//  JFCategorySelectViewFactory.h
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFCategorySelectViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol JFCategorySelectViewFactoryProtocol <NSObject>

- (UIControl<JFCategorySelectViewProtocol> *)createSelectView;

- (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
