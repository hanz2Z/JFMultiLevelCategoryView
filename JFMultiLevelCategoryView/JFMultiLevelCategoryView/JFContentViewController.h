//
//  JFContentViewController.h
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFContentViewController : UIViewController

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
