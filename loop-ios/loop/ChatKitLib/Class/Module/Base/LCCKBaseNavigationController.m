//
//  LCCKBaseNavigationController.m
//  LeanCloudChatKit-iOS
//
//  v0.7.15 Created by ElonChan (微信向我报BUG:chenyilong1010) on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import "LCCKBaseNavigationController.h"

@implementation LCCKBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //self.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setTranslucent:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
