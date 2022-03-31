# SRAlbum
*自定义相册，图片编辑，相册获取方式有照片和视频混合获取，照片获取，视频获取，照相和录像功能，有矩形卡片检测功能，自动截取矩形卡片。
![](IMG_0010.PNG)
![](IMG_0011.PNG)
![](IMG_0012.PNG)
![](IMG_0013.PNG)
![](IMG_0113.PNG)


# 安装方法
    在Podfile中添加 pod 'SRAlbum','~> 0.2.4'
    然后使用 pod install 命令
    
# Info.plist需要添加：
    Privacy - Photo Library Usage Description
    Privacy - Camera Usage Description
    Privacy - Microphone Usage Description
    Prevent limited photos access alert 这个设置为YES
    

# swift使用方法
    导入模块：import SRAlbum
    
    图片编辑配置：
    let config:SREidtConfigure = SREidtConfigure.init()
    config.type = .Gird
    config.girdIndex = IndexPath.init(item: 4, section: 4)
    
    相册使用：
    调用方法1：
    SRAlbumWrapper.openAlbum(tager: self, assetType: .Photo, maxCount: 2, isEidt: true, isSort: false, maxSize: 200*1024, eidtConfigure: config) { files in
        self.fileshandel(files: files)
    }
    调用方法2：
    self.openAlbum(assetType: .None, maxCount: 2, isEidt: true, isSort: false, maxSize: 200*1024, eidtConfigure: config) {[weak self] files in
        self?.fileshandel(files: files)
    }
    
    相机使用：
    调用方法1：
    SRAlbumWrapper.openCamera(tager: self, cameraType: .Photo, isRectangleDetection: false, isEidt: true, maxSize: 200*1024, eidtConfigure: config) { files in
        self.fileshandel(files: files)
    }
    调用方法2：
    self.openCamera(cameraType: .Photo, isRectangleDetection: false, isEidt: true, maxSize: 200*1024, eidtConfigure: config) {[weak self] files in
        self?.fileshandel(files: files)
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
    
    图片编辑配置：
    SREidtConfigure *config = [[SREidtConfigure alloc] init];
    config.type = SRCutTypeGird;
    config.girdIndex = [NSIndexPath indexPathForRow:4 inSection:4];
    
    相册使用：
    调用方法1：
    [SRAlbumWrapper openAlbumWithTager:self assetType:SRAssetTypePhoto maxCount:2 isEidt:true isSort:true maxSize:200 * 1024 eidtConfigure:config completeHandle:^(NSArray * files) {
        [self fileshandel:files];
    }];
    调用方法2：
    [self openAlbumWithAssetType:SRAssetTypePhoto maxCount:2 isEidt:true isSort:true maxSize:200 * 1024  eidtConfigure:config completeHandle:^(NSArray * files) {
        [weakSelf fileshandel:files];
    }];
    
    相机使用：
    调用方法1：
    [SRAlbumWrapper openCameraWithTager:self cameraType:SRCameraTypeVideo isRectangleDetection:false isEidt:true maxSize:200 * 1024 eidtConfigure:config completeHandle:^(NSArray * files) {
        [self fileshandel:files];
    }];
    调用方法2：
    [self openCameraWithCameraType:SRCameraTypePhoto isRectangleDetection:false isEidt:true maxSize:200 * 1024 eidtConfigure:config completeHandle:^(NSArray * files) {
        [weakSelf fileshandel:files];
    }];
    
