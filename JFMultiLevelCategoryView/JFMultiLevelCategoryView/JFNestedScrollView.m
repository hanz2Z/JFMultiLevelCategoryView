//
//  JFNestedScrollView.m
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import "JFNestedScrollView.h"

@interface JFNestedScrollView ()

@property (nonatomic, weak) JFNestedScrollView *currentDragingChild;

@end

@implementation JFNestedScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
//
//        if (translation.y > 0) {
//            UIView *subView = otherGestureRecognizer.view;
//
//            if ([subView isMemberOfClass:[NestedScrollView class]]) {
//                UIScrollView *subScrollView = (UIScrollView *)subView;
//
//                if (subScrollView.contentOffset.y > 0) {
//                    return NO;
//                }
//            }
//        }
//    }
    if ([otherGestureRecognizer.view isKindOfClass:[JFNestedScrollView class]]) {
        return YES;
    }
    else {
        return NO;
    }
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    return YES;
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        CascadeScrollView *parent = [self parentScrollView];
//        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
//
//        if (translation.y > 0) {
//            self.upDirection = NO;
//        }
//        else {
//            self.upDirection = YES;
//        }
//
//        if (parent) {
//            if (translation.y > 0) {
//                if (self.contentOffset.y > 0) {
//                    return YES;
//                }
//                else {
//                    return NO;
//                }
//            }
//            else {
//                if ([self hasAncestorNotAtBottom]) {
//                    return NO;
//                }
//                else {
//                    return YES;
//                }
//            }
//        }
//        else {
//            return YES;
//        }
//    }
//    else {
//        return YES;
//    }
//}

- (void)setContentOffset:(CGPoint)contentOffset
{
    //[super setContentOffset:contentOffset];
    if (self.dragging) {
        if (contentOffset.y > self.contentOffset.y) {
            // up
            if ([self hasAncestorNotAtBottom]) {
                [self.panGestureRecognizer setTranslation:CGPointZero inView:self];
            }
            else {
                [super setContentOffset:contentOffset];
            }
        }
        else if (contentOffset.y < self.contentOffset.y) {
            BOOL hasChildNotAtTop = NO;
            JFNestedScrollView *child = self.currentDragingChild;

            while (child) {
                if (child.contentOffset.y > 0) {
                    hasChildNotAtTop = YES;
                    break;
                }
                child = child.currentDragingChild;
            }

            if (hasChildNotAtTop) {
                [self.panGestureRecognizer setTranslation:CGPointZero inView:self];
            }
            else {
                if (self.currentDragingChild) {
                    CGFloat yTranslation = [self.panGestureRecognizer translationInView:self].y;
                    if (self.contentOffset.y - contentOffset.y > 40) {
                        [super setContentOffset:CGPointMake(contentOffset.x, self.contentOffset.y-yTranslation)];
                        [self.panGestureRecognizer setTranslation:CGPointZero inView:self];
                    }
                    else {
                        [super setContentOffset:contentOffset];
                    }
                }
                else {
                    [super setContentOffset:contentOffset];
                }
            }
        }
    }
    else {
        [super setContentOffset:contentOffset];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    JFNestedScrollView *child = self;
    JFNestedScrollView *parent = [self parentScrollView];

    while (parent) {
        parent.currentDragingChild = child;
        child = parent;
        parent = [parent parentScrollView];
    }

    return YES;
}

- (BOOL)hasAncestorNotAtTop {
    BOOL res = NO;

    UIView *parentView = self.superview;

    while (parentView != nil) {
        if ([parentView isMemberOfClass:[JFNestedScrollView class]]) {
            if (![self scrollViewAtTop:(UIScrollView *)parentView]) {
                res = YES;
                break;
            }
        }
        parentView = parentView.superview;
    }

    return res;
}

- (BOOL)hasAncestorNotAtBottom {
    BOOL res = NO;

    UIView *parentView = self.superview;

    while (parentView != nil) {
        if ([parentView isMemberOfClass:[JFNestedScrollView class]]) {
            if (![self scrollViewAtBottom:(UIScrollView *)parentView]) {
                res = YES;
                break;
            }
        }
        parentView = parentView.superview;
    }

    return res;
}

- (JFNestedScrollView *)parentScrollView
{
    UIView *parentView = self.superview;
    while (parentView != nil) {
         if ([parentView isMemberOfClass:[JFNestedScrollView class]]) {
             break;
         }
         parentView = parentView.superview;
     }

     return (JFNestedScrollView *)parentView;
}

- (BOOL)scrollViewAtBottom:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)scrollViewAtTop:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 0) {
        return YES;
    }
    else {
        return NO;
    }
}
@end
