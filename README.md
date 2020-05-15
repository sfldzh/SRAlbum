# SRAlbum
*自定义相册，图片编辑，相册获取方式有照片和视频混合获取，照片获取，视频获取。


![image](https://github.com/sfldzh/SRAlbum/blob/master/IMG_0010.PNG?raw=true)![image](https://github.com/sfldzh/SRAlbum/blob/master/IMG_0011.PNG?raw=true)
![image](https://github.com/sfldzh/SRAlbum/blob/master/IMG_0012.PNG?raw=true)![image](https://github.com/sfldzh/SRAlbum/blob/master/IMG_0013.PNG?raw=true)


# 安装方法
    在Podfile中添加 pod 'SRAlbum'
    然后使用 pod install 命令
    

# swift使用方法
    导入模块：import SRAlbum
    
    调用方法1：
    SRAlbumWrapper.openAlbum(tager: self, maxCount: 5, isEidt: true, isSort: true) { (assets) in
        print("assets")
    }
    调用方法2：
    self.openAlbum( maxCount: 5, isEidt: true, isSort: true) { [weak self](assets) in
        print("assets")
    }
    
    
# Objective-C使用方法
    导入模块：#import <SRAlbum-Swift.h>
    
    调用方法1：
    [SRAlbumWrapper openAlbumWithTager:(UIViewController * _Nonnull) assetType:(enum SRAssetType) maxCount:(NSInteger) isEidt:(BOOL) isSort:(BOOL) maxSize:(NSInteger) completeHandle:^(NSArray * list) {
        
    }];
    调用方法2：
    [self openAlbumWithAssetType:SRAssetTypeNone maxCount:5 isEidt:true isSort:true maxSize:2*1024*1024 completeHandle:^(NSArray * list) {
        NSLog(@"");
    }];
    
    
assetType: .None：任意列席，.Photo：图片类型，.Video：视频类型；默认为.None
maxCount: 取图片或者视频的数量；默认为1
isEidt: 是否要编辑；默认为false
isSort: 是否要排序输出图片；默认为false
maxSize: 限制图片的M数，；默认为2*1024*1024，也就是2M
