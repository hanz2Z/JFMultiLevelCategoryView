//
//  JFContentViewController.m
//  Ape_xc
//
//  Created by 赵岩 on 2020/2/16.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import "JFContentViewController.h"
#import "JFNestedScrollView.h"

CGFloat CCRANDOM_0_1()
{
    return (arc4random() % 101) / 100.0f;
}

@interface JFContentViewController ()

@end

@implementation JFContentViewController

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super init]) {
        _reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (void)loadView
{
    JFNestedScrollView *view = [JFNestedScrollView new];
    view.bounces = NO;
    view.showsVerticalScrollIndicator = NO;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //self.view.backgroundColor = [UIColor colorWithRed:CCRANDOM_0_1()  green:CCRANDOM_0_1()  blue:CCRANDOM_0_1()  alpha:1];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
