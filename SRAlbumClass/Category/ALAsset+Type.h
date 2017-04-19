//
//  ALAsset+Type.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
@interface ALAsset (Type)
/**
 TODO:是否是照片
 
 @return bool值
 */
- (BOOL)ctassetsPickerIsPhoto;


/**
 TODO:是否是视频
 
 @return bool值
 */
- (BOOL)ctassetsPickerIsVideo;
- (UIImage *)badgeImage;
@end
