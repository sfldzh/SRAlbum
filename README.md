# SRAlbum
*自定义相册，图片编辑，相册获取方式有照片和视频混合获取，照片获取，视频获取，照相和录像功能，有矩形卡片检测功能，自动截取矩形卡片。
![](IMG_0010.PNG)
![](IMG_0011.PNG)
![](IMG_0012.PNG)
![](IMG_0013.PNG)
![](IMG_0113.PNG)


# 安装方法
    在Podfile中添加 pod 'SRAlbum','~> 0.2.9'
    然后使用 pod install 命令
    
# Info.plist需要添加：
    Privacy - Photo Library Usage Description
    Privacy - Camera Usage Description
    Privacy - Microphone Usage Description
    Prevent limited photos access alert 这个设置为YES
    

# swift使用方法
    导入模块：import SRAlbum
    
    相册使用：
    调用方法1：
    SRAlbumWrapper.openAlbum(tager: self, assetType: .Photo, maxCount: 2, isEidt: true, isSort: false, maxSize: 200*1024) { files in
    
    }
    调用方法2：
    self.openAlbum(assetType: .None, maxCount: 3, isEidt: true, isSort: false, maxSize: 200*1024) {[weak self] files in
    
    }
    
    相机使用：
    调用方法1：
    SRAlbumWrapper.openCamera(tager: self, cameraType: .Photo, isRectangleDetection: false, isEidt: true, maxSize: 200*1024) { file in

    }
    调用方法2：
    self.openCamera(cameraType: .Photo, isRectangleDetection: false, isEidt: true, maxSize: 200*1024) {[weak self] file in
    
    }
    
    人脸采集使用：
    调用方法1：
    SRAlbumWrapper.openFaceTrack(faceTaskCount: 3, tager: self, maxSize: 200*1024) { file in

    }
    调用方法2：
    self.openFaceTrack(faceTaskCount: 3, maxSize: 200*1024) {[weak self] file in

    }
    
    assetType: .None：任意列席，.Photo：图片类型，.Video：视频类型；默认为.None
    maxCount: 取图片或者视频的数量；默认为1
    isEidt: 是否要编辑；默认为false
    isSort: 是否要排序输出图片；默认为false
    maxSize: 限制图片的M数，；默认为2*1024*1024，也就是2M
    cameraType: .Photo 拍照，.Video 录像
    isRectangleDetection: 是否矩形检测
    
    
# Objective-C使用方法
    导入模块：#import <SRAlbum/SRAlbum-Swift.h>
    
    相册使用：
    调用方法1：
    [SRAlbumWrapper openAlbumWithTager:self assetType:SRAssetTypeNone maxCount:2 isEidt:true isSort:false maxSize:200*1024completeHandle:^(NSArray<SRFileInfoData *> * files) {

    }];
    调用方法2：
    [self openAlbumWithAssetType:SRAssetTypeNone maxCount:3 isEidt:true isSort:false maxSize:200*1024completeHandle:^(NSArray<SRFileInfoData *> * files) {

    }];
    
    相机使用：
    调用方法1：
    [SRAlbumWrapper openCameraWithTager:self cameraType:SRCameraTypePhoto isRectangleDetection:false isEidt:true maxSize:200*1024completeHandle:^(SRFileInfoData * file) {

    }];
    调用方法2：
    [self openCameraWithCameraType:SRCameraTypePhoto isRectangleDetection:false isEidt:true maxSize:200*1024completeHandle:^(SRFileInfoData * file) {

    }];
    
    人脸采集使用：
    调用方法1：
    [SRAlbumWrapper openFaceTrackWithFaceTaskCount:2 tager:self maxSize:200*1024 completeHandle:^(SRFileInfoData * file) {

    }];
    调用方法2：
    [self openFaceTrackWithFaceTaskCount:2 maxSize:200*1024 completeHandle:^(SRFileInfoData * file) {
    
    }];
