//
//  SRAlbumBrowseViewController.h
//  T
//
//  Created by 施峰磊 on 2019/3/6.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SRAlbumBrowseViewControllerDelegate <NSObject>

/**
 TODO:关闭获取前一个页面的frame

 @param indexPath 序号索引
 @return 前一个页面的frame
 */
- (CGRect)willBeginCloseAnimationRect:(NSIndexPath *)indexPath;


/**
 TODO:设置相册资源类型

 @param assetType 资源类型
 */
- (void)setAlbumAssetType:(SRAssetType)assetType;


/**
 TODO:设置图片或者视频压缩

 @param isCompress 是否压缩
 */
- (void)setFileCompress:(BOOL)isCompress;


/**
 TODO:点击发送
 */
- (void)didClickSendAction;

@end

@interface SRAlbumBrowseViewController : UIViewController
@property (nonatomic, weak) id<SRAlbumBrowseViewControllerDelegate>delegate;
@property (nonatomic, assign) SRAssetType assetType;
@property (nonatomic, strong) PHFetchResult *assetList;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSMutableArray *selecteds;
@property (nonatomic, strong) NSIndexPath *showIndexPath;
@property (nonatomic, assign) CGRect clickeRect;
@property (nonatomic, assign, readonly)CGRect imageRect;
@property (nonatomic, assign, readonly)CGRect closeRect;
@property (nonatomic, assign) BOOL isCompress;

/**
 TODO:获取当前的图片

 @return 图片
 */
- (UIImage *)currentImage;
@end

NS_ASSUME_NONNULL_END
