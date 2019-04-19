//
//  SRHelper.m
//  T
//
//  Created by 施峰磊 on 2019/3/4.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRHelper.h"

@implementation SRHelper
/**
 TODO:判断是否有相册权限
 
 @return 是否有相册权限
 */
+ (BOOL)canAccessAlbums {
    BOOL _isAuth = YES;
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
        //无权限
        _isAuth = NO;
    }
    return _isAuth;
}

/**
 TODO:判断是否有麦克风权限

 @return 是否有麦克风权限
 */
+ (BOOL)canAccessVideoMic {
    AVAuthorizationStatus micStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return !(micStatus == AVAuthorizationStatusRestricted || micStatus ==AVAuthorizationStatusDenied);
}

/**
 TODO:判断是否有拍摄权限
 
 @return 是否有拍摄权限
 */
+ (BOOL)canAccessVideoCapture {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return !(authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied);
}



/**
 TODO:获取照片或者视频
 
 @param option 0：全部，1：照片，2：视频
 @param contentBlock 内容
 */
+ (void)fetchAlbumsOption:(NSInteger)option contentBlock:(void(^)(PHFetchResult *content, BOOL success))contentBlock{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){//检查权限
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized:{//有权限
                    PHFetchOptions *options = [[PHFetchOptions alloc] init];
                    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
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
}


/**
 TODO:获取相册

 @param contentBlock 回调
 */
+ (void)fetchAlbumsCollectionBack:(void(^)(NSArray *collection))contentBlock{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){//检查权限
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized:{//有权限
                    NSMutableArray *list = [NSMutableArray arrayWithCapacity:0];
                    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
                    PHFetchResult<PHAssetCollection *> *regularAssetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                    [list addObjectsFromArray:[assetCollections objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, assetCollections.count)]]];
                    //所有图片移动的第一位
                    NSInteger index = -1;
                    for (PHAssetCollection *collection in list) {
                        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                            index = [list indexOfObject:collection];
                            break;
                        }
                    }
                    if (index>-1) {
                        PHAssetCollection *assetCollection = [list objectAtIndex:index];
                        [list removeObject:assetCollection];
                        [list insertObject:assetCollection atIndex:0];
                    }
                    [list addObjectsFromArray:[regularAssetCollections objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, regularAssetCollections.count)]]];
                    if (contentBlock) {
                        contentBlock(list);
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
//                resultImage = [SRAlbumHelper scaleImage:resultImage toSize:size];
                if (resultImage) {
                    if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            }];
        }
        
        
        //        completion(image);
    }];
    return imageRequestID;
}


+ (void)requestOriginalImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *, NSDictionary *))completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.synchronous = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            if (completion) completion(imageData, info);
        }
    }];
}

+ (CGSize)imageSizeByMaxSize:(CGSize)maxSize sourceSize:(CGSize)sourceSize{
    CGFloat scale = 1.0;
    CGFloat sizeWidth = 0.0;
    CGFloat sizeHeight = 0.0;
    scale = maxSize.width/sourceSize.width;
    sizeWidth = maxSize.width;
    sizeHeight = sourceSize.height*scale;
    if (sizeHeight > maxSize.height) {
        sizeHeight = maxSize.height;
        scale = maxSize.height/sourceSize.height;
        sizeWidth = sourceSize.width*scale;
    }
    return CGSizeMake(sizeWidth, sizeHeight);
}



/**
 TODO:压缩视频的地址
 
 @return 地址
 */
+ (NSString *)compressedVideoPath{
    NSString *folderName = @"SRVedioCompressed";
    NSString *tempPath  = NSTemporaryDirectory();
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@",tempPath,folderName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:folderPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssfff";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[folderPath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    return fileName;
}

/**
 TODO:获取缓存大小

 @return 缓存大小
 */
+ (NSUInteger)getSize {
    __block NSUInteger size = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempPath  = NSTemporaryDirectory();
    dispatch_queue_t ioQueue = dispatch_queue_create("com.SRAlbum.Cache", DISPATCH_QUEUE_SERIAL);
    NSString *compressFolderPath = [NSString stringWithFormat:@"%@/SRVedioCompressed",tempPath];
    NSString *captureFolderPath = [NSString stringWithFormat:@"%@/SRVedioCapture",tempPath];
    dispatch_sync(ioQueue, ^{
        NSDirectoryEnumerator *compressFileEnumerator = [fileManager enumeratorAtPath:compressFolderPath];
        for (NSString *fileName in compressFileEnumerator) {
            NSString *filePath = [compressFolderPath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }

        NSDirectoryEnumerator *captureFileEnumerator = [fileManager enumeratorAtPath:captureFolderPath];
        for (NSString *fileName in captureFileEnumerator) {
            NSString *filePath = [captureFolderPath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}


/**
 TODO:清除缓存文件

 @param completionBlock 完成回调
 */
+ (void)clearDisk:(void(^)(void))completionBlock{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempPath  = NSTemporaryDirectory();
    dispatch_queue_t ioQueue = dispatch_queue_create("com.SRAlbum.Cache", DISPATCH_QUEUE_SERIAL);
    NSString *compressFolderPath = [NSString stringWithFormat:@"%@/SRVedioCompressed",tempPath];
    NSString *captureFolderPath = [NSString stringWithFormat:@"%@/SRVedioCapture",tempPath];
    dispatch_sync(ioQueue, ^{
        NSDirectoryEnumerator *compressFileEnumerator = [fileManager enumeratorAtPath:compressFolderPath];
        for (NSString *fileName in compressFileEnumerator) {
            NSString *filePath = [compressFolderPath stringByAppendingPathComponent:fileName];
            [self deleteFileByPath:[NSURL fileURLWithPath:filePath]];
        }
        
        NSDirectoryEnumerator *captureFileEnumerator = [fileManager enumeratorAtPath:captureFolderPath];
        for (NSString *fileName in captureFileEnumerator) {
            NSString *filePath = [captureFolderPath stringByAppendingPathComponent:fileName];
            [self deleteFileByPath:[NSURL fileURLWithPath:filePath]];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
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
        NSURL *pathUrl = [NSURL fileURLWithPath:[SRHelper compressedVideoPath]];
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
 TODO:压缩视频

 @param avAsset 视频资源
 @param completionHandler 完成回调
 */
+ (void)compressedVideo:(AVURLAsset *)avAsset completionHandler:(void (^)(AVAssetExportSession *exportSession,NSURL* path))completionHandler{
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        NSURL *pathUrl = [NSURL fileURLWithPath:[SRHelper compressedVideoPath]];
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
    NSURL *pathUrl = [NSURL fileURLWithPath:[SRHelper compressedVideoPath]];
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
 TODO:压缩指定大小的图片(NSData)

 @param data 原始图片数据
 @param maxLength 最大大小
 @return 压缩后图片
 */
+ (UIImage *)compressImageData:(NSData *)data toByte:(NSUInteger)maxLength{
    return [self compressImage:[UIImage imageWithData:data] toByte:maxLength];
}


/**
 TODO:压缩指定大小的图片

 @param image 原始图片
 @param maxLength 最大大小
 @return 压缩后图片
 */
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength{
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    
    compression = maxLength/(CGFloat)data.length;
    data = UIImageJPEGRepresentation(image, compression);
    UIImage *resultImage = [UIImage imageWithData:data];
    
    CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(compression)), (NSUInteger)(resultImage.size.height * sqrtf(compression))); // Use NSUInteger to prevent white blank
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}


/**
 TODO:Alert显示
 
 @param title 标题
 @param message 描述
 @param cancelTitle 取消按钮文字
 @param otherButtonTitle 其他按钮可以是字符串和数组，其他不接受
 @param isSheet 是否是Sheet
 @param callBackHandler 回调
 */
+ (void)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelTitle otherButtonTitle:(nullable id)otherButtonTitle isSheet:(BOOL)isSheet callBackHandler:(void (^ __nullable)(UIAlertTagAction *action))callBackHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:isSheet?UIAlertControllerStyleActionSheet:UIAlertControllerStyleAlert];
    if (otherButtonTitle) {
        if ([otherButtonTitle isKindOfClass:[NSString class]]) {
            NSString *otherTitle = otherButtonTitle;
            if (otherTitle.length > 0) {
                UIAlertTagAction *otherAction = [UIAlertTagAction actionWithTitle:otherTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                    if (callBackHandler) {
                        callBackHandler(((UIAlertTagAction *)action));
                    }
                }];
                otherAction.tag = cancelTitle.length > 0?1:0;
                [alertController addAction:otherAction];
            }
        } else if ([otherButtonTitle isKindOfClass:[NSArray class]]){
            NSArray *otherTitles = otherButtonTitle;
            if (otherTitles.count > 0) {
                for (NSString *title in otherTitles) {
                    UIAlertTagAction *otherAction = [UIAlertTagAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        if (callBackHandler) {
                            callBackHandler(((UIAlertTagAction *)action));
                        }
                    }];
                    otherAction.tag = [otherTitles indexOfObject:title]+(cancelTitle.length > 0?1:0);
                    [alertController addAction:otherAction];
                }
            }
        }
    }
    if (cancelTitle.length > 0) {
        UIAlertTagAction *cancelAction = [UIAlertTagAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            if (callBackHandler) {
                callBackHandler(((UIAlertTagAction *)action));
            }
        }];
        cancelAction.tag = 0;
        [alertController addAction:cancelAction];
    }
    UIViewController *tagerViewController = [self getCurrentController];
    [tagerViewController presentViewController:alertController animated:YES completion:nil];
}



/**
 TODO:获取当前Controller
 
 @return Controller
 */
+ (UIViewController *)getCurrentController{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //        UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    
    return result;
}

/**
 TODO:x权限设置页面
 */
+ (void)prowerSetView{
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *setUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (@available(iOS 10.0, *)){//ios10以后
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:setUrl options:@{} completionHandler:^(BOOL success) {
                if (!success) {
                    [self alertWithTitle:@"提示" message:@"无法跳转到设置，请自行前往。" cancelButtonTitle:@"确定" otherButtonTitle:nil isSheet:NO callBackHandler:nil];
                }
            }];
        }else{
            [self alertWithTitle:@"提示" message:@"无法跳转到设置，请自行前往。" cancelButtonTitle:@"确定" otherButtonTitle:nil isSheet:NO callBackHandler:nil];
        }
    }else{
        if ([application canOpenURL:setUrl]) {
            [application openURL:setUrl];
        }else{
            [self alertWithTitle:@"提示" message:@"无法跳转到设置，请自行前往。" cancelButtonTitle:@"确定" otherButtonTitle:nil isSheet:NO callBackHandler:nil];
        }
    }
}

@end
