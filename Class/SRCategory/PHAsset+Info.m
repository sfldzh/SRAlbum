//
//  PHAsset+Info.m
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "PHAsset+Info.h"
#import <objc/runtime.h>

@implementation PHAsset (Info)
- (UIImage *)thumbnail{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setThumbnail:(UIImage *)thumbnail{
    objc_setAssociatedObject(self, @selector(thumbnail), thumbnail, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)showImage{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setShowImage:(UIImage *)showImage{
    objc_setAssociatedObject(self, @selector(showImage), showImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSData *)showData{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setShowData:(NSData *)showData{
    objc_setAssociatedObject(self, @selector(showData), showData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 TODO:判断是否是GIF图片
 
 @return 是否是GIF图片
 */
- (BOOL)isGif{
    return [[self valueForKey:@"filename"] hasSuffix:@"GIF"];
}


/**
 TODO:是否是图片
 
 @return 真假
 */
- (BOOL)ctassetsPickerIsPhoto{
    return (self.mediaType == PHAssetMediaTypeImage);
}


/**
 TODO:是否是视频
 
 @return 真假
 */
- (BOOL)ctassetsPickerIsVideo{
    return (self.mediaType == PHAssetMediaTypeVideo);
}


/**
 TODO:是否是高清视频
 
 @return 真假
 */
- (BOOL)ctassetsPickerIsHighFrameRateVideo{
    return (self.mediaType == PHAssetMediaTypeVideo && (self.mediaSubtypes & PHAssetMediaSubtypeVideoHighFrameRate));
}


/**
 TODO:是否延时视频
 
 @return 真假
 */
- (BOOL)ctassetsPickerIsTimelapseVideo{
    return (self.mediaType == PHAssetMediaTypeVideo && (self.mediaSubtypes & PHAssetMediaSubtypeVideoTimelapse));
}

/**
 TODO:获取资源类型
 
 @return 资源类型
 */
- (SRAssetType)assetType{
    return [self ctassetsPickerIsPhoto]?SRAssetTypePic:SRAssetTypeVideo;
}


/**
 TODO:获取标志
 
 @return 标志图片
 */
- (UIImage *)badgeImage{
    NSString *imageName;
    if (self.ctassetsPickerIsHighFrameRateVideo)
        imageName = @"BadgeSlomoSmall";
    else if (self.ctassetsPickerIsTimelapseVideo)
        imageName = @"BadgeTimelapseSmall";
    else if (self.ctassetsPickerIsVideo)
        imageName = @"BadgeVideoSmall";
    
    if (imageName)
        return [UIImage imageNamed:imageName];
    else
        return nil;
}

@end
