//
//  SRAlbum.h
//  T
//
//  Created by 施峰磊 on 2019/3/4.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#ifndef SRAlbum_h
#define SRAlbum_h
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, SRDeviceType){
    SRDeviceTypeLibrary = 0,    //相册
    SRDeviceTypeCamera = 1      //相机
};

typedef NS_ENUM(NSInteger, SRSelectType){
    SRSelectTypeNone = 0,           //不可选择
    SRSelectTypeSelection = 1,      //选中
    SRSelectTypeNOSelection = 2     //不选中
};

typedef NS_ENUM(NSInteger, SRAssetType){
    SRAssetTypeNone = 0,    //未知资源类型
    SRAssetTypePic = 1,     //图片资源类型
    SRAssetTypeVideo = 2    //视频资源类型
};

#endif /* SRAlbum_h */
