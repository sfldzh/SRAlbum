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
#import "SRVideoCaptureViewController.h"

@interface ViewController ()<SRAlbumControllerDelegate,SRPhotoEidtViewDelegate,SRVideoCaptureViewControllerDelegate>

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
    vc.videoMaximumDuration = 5;
//    vc.isCanShot = YES;
    //编辑页的对象名,可以自定义
    vc.eidtClass = [SRPhotoEidtViewController class];
    //编辑页接收图片的对象名
    vc.eidtSourceName = @"imageSource";
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)vedioAction:(UIButton *)sender {
    SRVideoCaptureViewController *viewController = [[SRVideoCaptureViewController alloc] init];
    viewController.maxTime = 10;
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
    
}
- (IBAction)selectMedia:(UIButton *)sender {
    SRAlbumViewController *vc = [[SRAlbumViewController alloc] init];
    vc.resourceType = 0;
    vc.albumDelegate = self;
    vc.maxItem = 9;
    vc.videoMaximumDuration = 5;
    //    //编辑页的对象名,可以自定义
    //    vc.eidtClass = [SRPhotoEidtViewController class];
    //    //编辑页接收图片的对象名
    //    vc.eidtSourceName = @"imageSource";
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - SRVideoCaptureViewControllerDelegate
/**
 TODO:拍照或者录像已经确定完成和选择
 
 @param content 照片或者视频地址
 @param isVedio 是否是视频
 */
- (void)videoCaptureViewDidFinishWithContent:(id)content isVedio:(BOOL)isVedio{
    NSLog(@"%@ %@",content,isVedio?@"视频":@"图片");
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
