//
//  SRAlbumViewController.m
//  T
//
//  Created by 施峰磊 on 2019/3/4.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRAlbumViewController.h"
#import "SRAlbumGroupViewController.h"
#import "SRAlbumContentController.h"
#import "SRVideoCaptureViewController.h"
#import "SRNoPowerViewController.h"
#import "SRHelper.h"
#import "SRAlbumConfiger.h"

@interface SRAlbumViewController ()<SRAlbumGroupViewControllerDelegate,SRVideoCaptureViewControllerDelegate>
@property (nonatomic, assign) SRDeviceType deviceType;
@end

@implementation SRAlbumViewController

- (void)dealloc{
    [SRAlbumConfiger freeData];
}

- (instancetype)initWithDeviceType:(SRDeviceType)type{
    self.deviceType =type;
    if (type == SRDeviceTypeLibrary) { //相册
        if ([SRHelper canAccessAlbums]) {
            SRAlbumGroupViewController *vc = [[SRAlbumGroupViewController alloc] initWithNibName:@"SRAlbumGroupViewController" bundle:nil];
            vc.delegate = self;
            self = [super initWithRootViewController:vc];
        }else{
            self = [super initWithRootViewController:[[SRNoPowerViewController alloc] initWithNibName:@"SRNoPowerViewController" bundle:nil]];
        }
    } else {//相机
        SRVideoCaptureViewController *vc = [[SRVideoCaptureViewController alloc] initWithNibName:@"SRVideoCaptureViewController" bundle:nil];
        vc.delegate = self;
        self = [super initWithRootViewController:vc];
    }
    return self;
}

- (void)setMaxItem:(NSUInteger)maxItem{
    [SRAlbumConfiger singleton].maxItem = maxItem;
}

- (void)setAssetType:(SRAssetType)assetType{
    [SRAlbumConfiger singleton].assetType = assetType;
}

- (void)setMaxlength:(long)maxlength{
    [SRAlbumConfiger singleton].maxlength = maxlength;
}

- (void)setMaxTime:(CGFloat)maxTime{
    [SRAlbumConfiger singleton].maxTime = maxTime;
}

- (void)setIsEidt:(BOOL)isEidt{
    [SRAlbumConfiger singleton].isEidt = isEidt;
}

- (void)setIsShowPicList:(BOOL)isShowPicList{
    [SRAlbumConfiger singleton].isShowPicList = isShowPicList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate {
    return [[self.viewControllers lastObject] shouldAutorotate];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

#pragma mark - SRAlbumGroupViewControllerDelegate
/**
 TODO:相册照片获取
 
 @param images 图片列表
 */
- (void)didFinishAlbumGroupPickingImages:(NSArray *)images{
    if (self.albumDelegate && [self.albumDelegate respondsToSelector:@selector(srAlbumPickerController:didFinishPickingImages:)]) {
        [self.albumDelegate srAlbumPickerController:self didFinishPickingImages:images];
    }
}


/**
 TODO:相册视频获取
 
 @param vedios 视频列表
 */
- (void)didFinishAlbumGroupPickingVedios:(NSArray *)vedios{
    if (self.albumDelegate && [self.albumDelegate respondsToSelector:@selector(srAlbumPickerController:didFinishPickingVedios:)]) {
        [self.albumDelegate srAlbumPickerController:self didFinishPickingVedios:vedios];
    }
}

#pragma mark - SRVideoCaptureViewControllerDelegate
- (void)captureFinish:(id)content{
    if ([content isKindOfClass:[UIImage class]]) {
        [self didFinishAlbumGroupPickingImages:@[content]];
    }else{
        [self didFinishAlbumGroupPickingVedios:@[content]];
    }
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
