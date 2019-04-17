//
//  SRAlbumContentController.h
//  T
//
//  Created by 施峰磊 on 2019/3/4.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAssetCollection+Info.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SRAlbumContentControllerDelegate <NSObject>

/**
 TODO:相册照片获取
 
 @param images 图片列表
 */
- (void)didFinishAlbumContentPickingImages:(NSArray *)images;


/**
 TODO:相册视频获取

 @param vedios 视频列表
 */
- (void)didFinishAlbumContentPickingVedios:(NSArray *)vedios;
@end

@interface SRAlbumContentController : UIViewController
@property (nonatomic, weak) id<SRAlbumContentControllerDelegate>delegate;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

NS_ASSUME_NONNULL_END
