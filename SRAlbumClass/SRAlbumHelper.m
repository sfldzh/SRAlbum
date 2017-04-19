//
//  SRAlbumHelper.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRAlbumHelper.h"

@implementation SRAlbumHelper
/**
 TODO:是否可以访问照片
 
 @return 是否允许
 */
+ (BOOL)canAccessAlbums {
    BOOL _isAuth = YES;
    if (ISIOS8) {
        PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
        if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
            //无权限
            _isAuth = NO;
        }
    } else {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusNotDetermined) {
            //无权限
            _isAuth = NO;
        }
    }
    return _isAuth;
}

+ (ALAssetsLibrary *)defaultAssetsLibrary{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

/**
 TODO:获取照片或者视频

 @param option 0：全部，1：照片，2：视频
 @param contentBlock 内容
 */
+ (void)fetchAlbumsOption:(NSInteger)option contentBlock:(void(^)(id content, BOOL success))contentBlock{
    if (ISIOS8) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){//检查权限
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (status) {
                    case PHAuthorizationStatusAuthorized:{//有权限
                        PHFetchOptions *options = [[PHFetchOptions alloc] init];
                        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                        if (option == 1) {
                            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                        }else if (option == 2){
                            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                 PHAssetMediaTypeVideo];
                        }
                        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:options];
                        if (fetchResult.count == 0) {
                            if (contentBlock)
                                contentBlock(fetchResult,NO);
                        }else{
                            if (contentBlock)
                                contentBlock(fetchResult,YES);
                        }
                        break;
                    }
                    default:{//没权限
                        NSLog(@"2");
                        break;
                    }
                }
            });
        }];
        
    }else {
        __block NSInteger assetNumber = 0;
        __block NSInteger count = 0;
        __block NSMutableArray *mutableArray =[NSMutableArray arrayWithCapacity:0];
        ALAssetsLibrary *library = [SRAlbumHelper defaultAssetsLibrary];
        void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [mutableArray insertObject:result atIndex:0];
                count++;
            }
            if (count == assetNumber&&contentBlock) {
                count = 0;
                contentBlock(mutableArray,YES);
            }
        };
        void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
            if(group != nil) {
                if (option == 0) {
                    [group setAssetsFilter:[ALAssetsFilter allAssets]];
                }else if (option == 1){
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                }else{
                    [group setAssetsFilter:[ALAssetsFilter allVideos]];
                }
                
                assetNumber += [group numberOfAssets];
                [group enumerateAssetsUsingBlock:assetEnumerator];
//                [group enumerateAssetsWithOptions:NSEnumerationConcurrent usingBlock:assetEnumerator];
            }
        };
        
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetGroupEnumerator failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
    }
}

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion{
    size.width *= 2;
    size.height *= 2;
     ;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    option.resizeMode = resizeMode;//控制照片尺寸
//    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    //option.synchronous = YES;
//        option.networkAccessAllowed = YES;
    //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    PHImageRequestID imageRequestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
            PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
            option.networkAccessAllowed = YES;
            option.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                resultImage = [SRAlbumHelper scaleImage:resultImage toSize:size];
                if (resultImage) {
                    if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            }];
        }
        
        
//        completion(image);
    }];
    return imageRequestID;
}

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}


+ (CGSize)getSizeWithAsset:(id)asset maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth{
    CGFloat scale = 0.0;
    CGFloat width =0.0;
    CGFloat height = 0.0;
    if (ISIOS8) {
        width  = (CGFloat)((PHAsset *)asset).pixelWidth;
        height = (CGFloat)((PHAsset *)asset).pixelHeight;
        scale = width/height;
    }else{
        UIImage *tempImg = asset;
        width = tempImg.size.width;
        height = tempImg.size.height;
    }
    CGFloat sizeWidth = 0.0;
    CGFloat sizeHeight = 0.0;
    if (width>height) {
        sizeWidth = width>maxWidth?maxWidth:width;
        sizeHeight = width>maxWidth?height*(maxWidth/width):height;
    }else{
        sizeHeight = height>maxHeight?maxHeight:height;
        sizeWidth = height>maxHeight?width*(maxHeight/height):width;
    }
    return CGSizeMake(sizeWidth, sizeHeight);
}

#pragma mark - Save photo

/**
 TODO:保存图片

 @param image 图片
 @param completion 完成回调
 */
+ (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *error))completion {
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    if (ISIOS9) { // 这里有坑... iOS8系统下这个方法保存图片会失败
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    completion(nil);
                } else if (error) {
                    NSLog(@"保存照片出错:%@",error.localizedDescription);
                    if (completion) {
                        completion(error);
                    }
                }
            });
        }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[SRAlbumHelper defaultAssetsLibrary] writeImageToSavedPhotosAlbum:image.CGImage orientation:[SRAlbumHelper orientationFromImage:image] completionBlock:^(NSURL *assetURL, NSError *error) {
#pragma clang diagnostic pop
            if (error) {
                NSLog(@"保存图片失败:%@",error.localizedDescription);
                if (completion) {
                    completion(error);
                }
            } else {
                // 多给系统0.5秒的时间，让系统去更新相册数据
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(nil);
                    }
                });
            }
        }];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (ALAssetOrientation)orientationFromImage:(UIImage *)image {
#pragma clang diagnostic pop
    NSInteger orientation = image.imageOrientation;
    return orientation;
}


/**
 TODO:保存视图到相册

 @param vedioUrl 视频地址
 @param completion 完成回调
 */
+ (void)saveVedioWithurl:(NSURL *)vedioUrl completion:(void (^)(NSError *error,id asset))completion{
    if (ISIOS8) { // 这里有坑... iOS8系统下这个方法保存图片会失败
        __block NSString *createdAssetId = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:vedioUrl];
            //为Asset创建一个占位符，放到相册编辑请求中
            PHObjectPlaceholder *placeHolder = [createAssetRequest placeholderForCreatedAsset];
            createdAssetId = placeHolder.localIdentifier;

        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            PHAsset *phasset;
            if (!error) {
                PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
                phasset = fetchResult.firstObject;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(error,phasset);
                }
            });
        }];
    }else{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:vedioUrl
                                    completionBlock:^(NSURL *assetURL, NSError *error) {
                                        if (!error) {
                                             [[SRAlbumHelper defaultAssetsLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                     if (completion) {
                                                         completion(error,asset);
                                                     }
                                                 });
                                             } failureBlock:^(NSError *error) {
                                                 if (completion) {
                                                     completion(error,nil);
                                                 }
                                             }];
                                        }
                                    }];
    }
}


/**
 TODO:压缩视频的地址

 @return 地址
 */
+ (NSString *)compressedVideoPath{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString * resultPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
    return resultPath;
}

/**
 TODO:压缩视频
 
 @param path 文件地址
 @param completionHandler 完成回调
 */
+ (void)compressedVideoWithPath:(NSURL*)path CompletionHandler:(void (^)(AVAssetExportSession *exportSession,NSURL* path))completionHandler{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:path options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        NSURL *pathUrl = [NSURL fileURLWithPath:[SRAlbumHelper compressedVideoPath]];
        exportSession.outputURL = pathUrl;
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if (completionHandler) {
                completionHandler(exportSession,pathUrl);
            }
        }];
    }
}


/**
 TODO:慢动作视频压缩

 @param composition 源文件
 @param completionHandler 完成回调
 */
+ (void)compressedVideoCompositionWithComposition:(AVComposition *)composition CompletionHandler:(void (^)(AVAssetExportSession *exportSession,NSURL* path))completionHandler{
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    NSURL *pathUrl = [NSURL fileURLWithPath:[SRAlbumHelper compressedVideoPath]];
    exporter.outputURL = pathUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (completionHandler) {
            completionHandler(exporter,pathUrl);
        }
    }];
}

/**
 TODO:生成视频缩略图
 
 @param videoURL 视频地址
 @param time 时间段
 @return 视频缩略图
 */
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    CGImageRelease(thumbnailImageRef);
    return thumbnailImage;
}

/**
 TODO:删除本地文件
 
 @param path 文件地址
 */
+(BOOL)deleteFileByPath:(NSURL *)path{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    BOOL blHave=[fileManager fileExistsAtPath:[path path]];
    if (blHave) {
        blHave = [fileManager removeItemAtURL:path error:nil];
    }
    return blHave;
}

@end
