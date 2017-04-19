//
//  SRAlbumHelper.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#define ISIOS9 ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define ISIOS8      ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define iOS7Later   ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
@interface SRAlbumHelper : NSObject
/**
 TODO:是否可以访问照片
 
 @return 是否允许
 */
+ (BOOL)canAccessAlbums;

/**
 TODO:获取照片或者视频
 
 @param option 0：全部，1：照片，2：视频
 @param contentBlock 内容
 */
+ (void)fetchAlbumsOption:(NSInteger)option contentBlock:(void(^)(id content, BOOL success))contentBlock;

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion;

+ (CGSize)getSizeWithAsset:(id)asset maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth;
/**
 TODO:保存图片
 
 @param image 图片
 @param completion 完成回调
 */
+ (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *error))completion;

/**
 TODO:保存视图到相册
 
 @param vedioUrl 视频地址
 @param completion 完成回调
 */
+ (void)saveVedioWithurl:(NSURL *)vedioUrl completion:(void (^)(NSError *error,id asset))completion;

/**
 TODO:压缩视频
 
 @param path 文件地址
 @param completionHandler 完成回调
 */
+ (void)compressedVideoWithPath:(NSURL*)path CompletionHandler:(void (^)(AVAssetExportSession *exportSession,NSURL* path))completionHandler;

/**
 TODO:慢动作视频压缩
 
 @param composition 源文件
 @param completionHandler 完成回调
 */
+ (void)compressedVideoCompositionWithComposition:(AVComposition *)composition CompletionHandler:(void (^)(AVAssetExportSession *exportSession,NSURL* path))completionHandler;


/**
 TODO:生成视频缩略图
 
 @param videoURL 视频地址
 @param time 时间段
 @return 视频缩略图
 */
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
/**
 TODO:删除本地文件
 
 @param path 文件地址
 */
+ (BOOL)deleteFileByPath:(NSURL *)path;
@end
