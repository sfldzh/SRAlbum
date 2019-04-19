//
//  SRAlbumData.h
//  T
//
//  Created by 施峰磊 on 2019/3/6.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRAlbumConfiger : NSObject

//选择资源的类型
@property (nonatomic, assign) SRAssetType assetType;
//最大选择数量
@property (nonatomic, assign) NSUInteger maxItem;
//最大内存大小
@property (nonatomic, assign) long maxlength;
//录制视频时间
@property (nonatomic, assign) CGFloat maxTime;
//编辑图片 YES:assetType自动变更为SRAssetTypePic
@property (nonatomic, assign) BOOL isEidt;
//是否直接显示图片列表
@property (nonatomic, assign) BOOL isShowPicList;
/**
 TODO:单例获取数据
 
 @return 数据
 */
+ (SRAlbumConfiger *)singleton;

/**
 TODO:释放单例数据
 */
+ (void)freeData;
@end

NS_ASSUME_NONNULL_END
