# SRAlbum
*自定义相册，带拍照、录像，图片处理（GPUImage），相册获取方式有照片和视频混合获取，照片获取，视频获取。拍照方式是自定义的AVCapture,轻触拍照，按住摄像，拍摄后保存到本地相册。选择照片后使用GPUimage来处理图片。这个是自定义，可以自己添加其他的编辑方式，视频的选择后做了压缩处理。视频的很小，可以直接上传。


![image](https://github.com/sfldzh/SRAlbum/blob/master/IMG_0630.PNG?raw=true)![image](https://github.com/sfldzh/SRAlbum/blob/master/IMG_0631.PNG?raw=true)
![image](https://github.com/sfldzh/SRAlbum/blob/master/IMG_0610.PNG?raw=true)![image](https://github.com/sfldzh/SRAlbum/blob/master/IMG_0632.PNG?raw=true)


# 使用方法
    SRDeviceType deviceType = SRDeviceTypeLibrary;
    SRAssetType assetType = SRAssetTypeNone;
    SRAlbumViewController *vc = [[SRAlbumViewController alloc] initWithDeviceType:deviceType];
    vc.albumDelegate = self;
    vc.assetType = assetType;
    vc.maxItem = 9;
    vc.maxlength = 500*1024;
    vc.isEidt = isEidt;
    vc.isShowPicList = YES;
    [self presentViewController:vc animated:YES completion:nil];
    
资源类型   assetType  SRAssetTypeNone 未知资源类型，SRAssetTypePic 图片资源类型， SRAssetTypeVideo 视频资源类型
 最多选择照片张数 maxItem 默认9张。
 maxlength 照片最大内存大小，不设置不压缩。
 isEidt是否编辑
 isShowPicList是否直接显示图片列表
 
# 回调方法
    相册照片获取
    - (void)srAlbumPickerController:(SRAlbumViewController *)picker didFinishPickingImages:(NSArray *)images
    
    相册视频获取
    - (void)srAlbumPickerController:(SRAlbumViewController *)picker didFinishPickingVedios:(NSArray *)vedios
