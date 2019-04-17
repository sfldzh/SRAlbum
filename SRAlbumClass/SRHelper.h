//
//  SRHelper.h
//  T
//
//  Created by 施峰磊 on 2019/3/4.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRAlbum.h"
#import "UIAlertTagAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRHelper : NSObject
/**
 TODO:判断是否有相册权限
 
 @return 是否有相册权限
 */
+ (BOOL)canAccessAlbums;

/**
 TODO:判断是否有麦克风权限
 
 @return 是否有麦克风权限
 */
+ (BOOL)canAccessVideoMic;

/**
 TODO:判断是否有拍摄权限
 
 @return 是否有拍摄权限
 */
+ (BOOL)canAccessVideoCapture;

/**
 TODO:获取照片或者视频
 
 @param option 0：全部，1：照片，2：视频
 @param contentBlock 内容
 */
+ (void)fetchAlbumsOption:(NSInteger)option contentBlock:(void(^)(PHFetchResult *content, BOOL success))contentBlock;

/**
 TODO:获取相册
 
 @param contentBlock 回调
 */
+ (void)fetchAlbumsCollectionBack:(void(^)(NSArray *collection))contentBlock;

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion;


+ (void)requestOriginalImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *, NSDictionary *))completion;

+ (CGSize)imageSizeByMaxSize:(CGSize)maxSize sourceSize:(CGSize)sourceSize;


/**
 TODO:压缩视频
 
 @param path 文件地址
 @param completionHandler 完成回调
 */
+ (void)compressedVideoWithPath:(NSURL*)path CompletionHandler:(void (^)(AVAssetExportSession *exportSession,NSURL* path))completionHandler;

/**
 TODO:压缩视频
 
 @param avAsset 视频资源
 @param completionHandler 完成回调
 */
+ (void)compressedVideo:(AVURLAsset *)avAsset completionHandler:(void (^)(AVAssetExportSession *exportSession,NSURL* path))completionHandler;

/**
 TODO:慢动作视频压缩
 
 @param composition 源文件
 @param completionHandler 完成回调
 */
+ (void)compressedVideoCompositionWithComposition:(AVComposition *)composition CompletionHandler:(void (^)(AVAssetExportSession *exportSession,NSURL* path))completionHandler;

/**
 TODO:获取缓存大小
 
 @return 缓存大小
 */
+ (NSUInteger)getSize;

/**
 TODO:清除缓存文件
 
 @param completionBlock 完成回调
 */
+ (void)clearDisk:(void(^)(void))completionBlock;

/**
 TODO:删除本地文件
 
 @param path 文件地址
 */
+(BOOL)deleteFileByPath:(NSURL *)path;

/**
 TODO:压缩指定大小的图片(NSData)
 
 @param data 原始图片数据
 @param maxLength 最大大小
 @return 压缩后图片
 */
+ (UIImage *)compressImageData:(NSData *)data toByte:(NSUInteger)maxLength;

/**
 TODO:压缩指定大小的图片
 
 @param image 原始图片
 @param maxLength 最大大小
 @return 压缩后图片
 */
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;

#pragma mark - tool
/**
 TODO:Alert显示
 
 @param title 标题
 @param message 描述
 @param cancelTitle 取消按钮文字
 @param otherButtonTitle 其他按钮可以是字符串和数组，其他不接受
 @param isSheet 是否是Sheet
 @param callBackHandler 回调
 */
+ (void)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelTitle otherButtonTitle:(nullable id)otherButtonTitle isSheet:(BOOL)isSheet callBackHandler:(void (^ __nullable)(UIAlertTagAction *action))callBackHandler;

/**
 TODO:x权限设置页面
 */
+ (void)prowerSetView;
@end

NS_ASSUME_NONNULL_END
