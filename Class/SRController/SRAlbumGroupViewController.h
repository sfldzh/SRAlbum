//
//  SRAlbumGroupViewController.h
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SRAlbumGroupViewControllerDelegate <NSObject>

/**
 TODO:相册照片获取
 
 @param images 图片列表
 */
- (void)didFinishAlbumGroupPickingImages:(NSArray *)images;

/**
 TODO:相册视频获取
 
 @param vedios 视频列表
 */
- (void)didFinishAlbumGroupPickingVedios:(NSArray *)vedios;
@end

@interface SRAlbumGroupViewController : UIViewController
@property (nonatomic, weak) id<SRAlbumGroupViewControllerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
