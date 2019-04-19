//
//  SRAlbumViewController.h
//  T
//
//  Created by 施峰磊 on 2019/3/4.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRAlbum.h"
#import "SRHelper.h"

NS_ASSUME_NONNULL_BEGIN
@class SRAlbumViewController;
@protocol SRAlbumViewControllerDelegate <NSObject>
@optional
/**
 TODO:相册照片获取

 @param picker 相册
 @param images 图片列表
 */
- (void)srAlbumPickerController:(SRAlbumViewController *)picker didFinishPickingImages:(NSArray *)images;


/**
 TODO:相册视频获取

 @param picker 相册
 @param vedios 视频列表
 */
- (void)srAlbumPickerController:(SRAlbumViewController *)picker didFinishPickingVedios:(NSArray *)vedios;
@end

@interface SRAlbumViewController : UINavigationController
@property(nonatomic,weak) id <SRAlbumViewControllerDelegate> albumDelegate;
//选择资源的类型
@property (nonatomic, assign) SRAssetType assetType;
//最大选择数量(默认9张)
@property (nonatomic, assign) NSUInteger maxItem;
//最大内存大小
@property (nonatomic, assign) long maxlength;
//录制视频时间
@property (nonatomic, assign) CGFloat maxTime;
//编辑图片 YES:assetType自动变更为SRAssetTypePic
@property (nonatomic, assign) BOOL isEidt;
//是否直接显示图片列表
@property (nonatomic, assign) BOOL isShowPicList;

/**
 TODO:初始化图片库

 @param type SRDeviceTypeLibrary：相册，SRDeviceTypeCamera：相机
 @return 图片库
 */
- (instancetype)initWithDeviceType:(SRDeviceType)type;
@end

NS_ASSUME_NONNULL_END
