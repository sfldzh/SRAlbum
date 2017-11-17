//
//  SRAlbumData.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/7.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SRAlbumController;
@protocol SRAlbumControllerDelegate <NSObject>
@optional

/**
 TODO:已经选择了视频或者照片
 
 @param content 视频或者照片
 @param isVedio 是否是视频
 @param viewController 相册
 */
- (void)srAlbumDidSeletedFinishWithContent:(id)content isVedio:(BOOL)isVedio viewController:(SRAlbumController *)viewController;
@end

@interface SRAlbumData : NSObject

//资源类型 0：全部 1：照片 2：视频
@property (nonatomic, assign) NSInteger resourceType;
//是否可以拍摄功能
@property (nonatomic, assign) BOOL          isCanShot;
//只有在选择照片时有用。
@property (nonatomic, assign) NSUInteger    maxItem;
//拍摄视频最多时间
@property (nonatomic, assign) NSUInteger    videoMaximumDuration;
//编辑页面
@property (nonatomic, weak) Class         eidtClass;
//图片接收数据的名字
@property (nonatomic, strong) NSString      *eidtSourceName;
@property(nonatomic,weak) id<SRAlbumControllerDelegate>albumDelegate;

/**
 TODO:单例获取数据
 
 @return 数据
 */
+ (SRAlbumData *)singleton;

/**
 TODO:释放单例数据
 */
+ (void)freeData;

@end

