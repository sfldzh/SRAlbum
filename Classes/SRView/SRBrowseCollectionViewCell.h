//
//  SRBrowseCollectionViewCell.h
//  T
//
//  Created by 施峰磊 on 2019/3/7.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+Info.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SRBrowseCollectionViewCellDelegate <NSObject>

/**
 TODO:获取当前图片的frame

 @param frame 当前图片的frame
 */
- (void)currentImageFrame:(CGRect)frame;

/**
 TODO:关闭相册浏览器
 */
- (void)didSwipeClose;


/**
 TODO:将要滑动关闭
 */
- (void)willSwipeClose;


/**
 TODO:取消滑动关闭
 */
- (void)cancelSwipeClose;


/**
 TODO:点击获取导航栏
 */
- (void)didClickBar;
@end

@interface SRBrowseCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) id<SRBrowseCollectionViewCellDelegate>delegate;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, weak) UIView *backView;

- (CGRect)getCurrentImageFrame;

/**
 TODO:获取当前的图片
 
 @return 图片
 */
- (UIImage *)currentImage;
/**
 TODO:停止播放
 */
- (void)stopPlay;
@end

NS_ASSUME_NONNULL_END
