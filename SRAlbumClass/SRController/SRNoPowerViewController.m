//
//  SRNoPowerViewController.m
//  T
//
//  Created by 施峰磊 on 2019/3/4.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRNoPowerViewController.h"
#import "SRHelper.h"

@interface SRNoPowerViewController ()

@end

@implementation SRNoPowerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [SRHelper alertWithTitle:@"提示" message:@"没有权限获取相册内容，要设置权限吗？" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" isSheet:NO callBackHandler:^(UIAlertTagAction *action) {
        if (action.tag == 1) {
            [SRHelper prowerSetView];
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
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
