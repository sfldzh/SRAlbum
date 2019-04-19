//
//  PHAsset+Info.h
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <Photos/Photos.h>
#import "SRAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (Info)
@property (nonatomic, strong) UIImage   *thumbnail;//缩略图
@property (nonatomic, strong) NSData    *showData;//GIF图片
@property (nonatomic, strong) UIImage   *showImage;//图片
/**
 TODO:是否是图片
 
 @return 真假
 */
- (BOOL)ctassetsPickerIsPhoto;

/**
 TODO:判断是否是GIF图片
 
 @return 是否是GIF图片
 */
- (BOOL)isGif;

/**
 TODO:获取标志
 
 @return 标志图片
 */
- (UIImage *)badgeImage;


/**
 TODO:获取资源类型

 @return 资源类型
 */
- (SRAssetType)assetType;
@end

NS_ASSUME_NONNULL_END
