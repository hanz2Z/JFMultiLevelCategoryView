//
//  ViewController.m
//  JFMultiLevelCategoryViewDemo
//
//  Created by 赵岩 on 2020/3/1.
//  Copyright © 2020 jumpingfish. All rights reserved.
//

#import "ViewController.h"
#import <JFMultiLevelCategoryView/JFMultiLevelCategoryView.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    JFMultiLevelCategoryView *view = [JFMultiLevelCategoryView new];
    [self.view addSubview:view];
    view.frame = self.view.bounds;
}


@end
