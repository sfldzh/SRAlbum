# SRAlbum
自定义相册，带拍照、录像，图片处理（GPUImage），相册获取方式有照片和视频混合获取，照片获取，视频获取。拍照方式是自定义的AVCapture,轻触拍照，按住摄像，
拍摄后保存到本地相册。选择照片后使用GPUimage来处理图片。这个是自定义，可以自己添加其他的编辑方式，在vc.eidtClass定义。视频的选择后做了压缩处理。视频
的很小，可以直接上传。

# 使用方法
    SRAlbumViewController *vc = [[SRAlbumViewController alloc] init];
    vc.resourceType = sender.tag;
    vc.albumDelegate = self;
    vc.maxItem = 9;
    //编辑页的对象名,可以自定义
    vc.eidtClass = [SRPhotoEidtViewController class];
    //编辑页接收图片的对象名
    vc.eidtSourceName = @"imageSource";
    [self presentViewController:vc animated:YES completion:nil];
    
 资源类型   resourceType  0：全部 1：照片 2：视频。
 最多选择照片张数 maxItem 默认一张。
 编辑页类名 eidtClass 自定义，可以自己创建加入。delegate不需要传，albumDelegate有值就可以了。
 编辑页类照片数组传递对象名：eidtSourceName。
 
# 回调方法
  srAlbumDidSeletedFinishWithContent: isVedio: viewController:
# 视频获取缩略图方法
  [SRAlbumHelper thumbnailImageForVideo:url atTime:1];
