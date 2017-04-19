//
//  ViewController.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "ViewController.h"
#import "SRAlbumViewController.h"
#import <Photos/Photos.h>
#import "SRPhotoEidtViewController.h"//编辑
#import "SRAlbumHelper.h"

@interface ViewController ()<SRAlbumControllerDelegate,SRPhotoEidtViewDelegate>

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(@"/Users/shifenglei/Desktop/20170414145825.mp4")) {
//        UISaveVideoAtPathToSavedPhotosAlbum(@"/Users/shifenglei/Desktop/20170414145825.mp4", self, nil, nil);
//    }
}

- (IBAction)action:(UIButton *)sender {
    SRAlbumViewController *vc = [[SRAlbumViewController alloc] init];
    vc.resourceType = sender.tag;
    vc.albumDelegate = self;
    vc.maxItem = 9;
    //编辑页的对象名,可以自定义
    vc.eidtClass = [SRPhotoEidtViewController class];
    //编辑页接收图片的对象名
    vc.eidtSourceName = @"imageSource";
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SRAlbumControllerDelegate

/**
 TODO:已经选择了视频或者照片
 
 @param content 视频或者照片
 @param isVedio 是否是视频
 @param viewController 相册
 */
- (void)srAlbumDidSeletedFinishWithContent:(id)content isVedio:(BOOL)isVedio viewController:(SRAlbumController *)viewController{
    if ([content isKindOfClass:[NSURL class]]) {
        NSLog(@"%@",[SRAlbumHelper thumbnailImageForVideo:content atTime:1]);
    }
    NSLog(@"%@",content);
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SRPhotoEidtViewDelegate
/**
 TODO:图片编辑完成
 
 @param datas 图片数组
 @param viewController 编辑页面
 */
- (void)didEidtEndWithDatas:(NSArray *)datas viewController:(SRPhotoEidtViewController *)viewController{
    NSLog(@"%@",datas);
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
