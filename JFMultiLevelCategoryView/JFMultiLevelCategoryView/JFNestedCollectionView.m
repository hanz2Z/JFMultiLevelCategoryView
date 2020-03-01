//
//  JFNestedCollectionView.m
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import "JFNestedCollectionView.h"

@implementation JFNestedCollectionView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[JFNestedCollectionView class]]) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
            UICollectionView *other = (UICollectionView *)otherGestureRecognizer.view;

            if (translation.x > 0) {
                // left
                if (other.contentOffset.x <= 0) {
                    return YES;
                }
                else {
                    return NO;
                }
            }
            else {
                if (other.contentOffset.x >= (other.contentSize.width - other.frame.size.width)) {
                    return YES;
                }
                else {
                    return NO;
                }
            }
        }
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
        if (translation.x > 0) {
            // left
            if (self.contentOffset.x <= 0) {
                return NO;
            }
            else {
                return YES;
            }
        }
        else {
            if (self.contentOffset.x >= (self.contentSize.width - self.frame.size.width)) {
                return NO;
            }
            else {
                return YES;
            }
        }
    }

    return YES;
}

@end
