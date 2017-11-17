//
//  SRAlbumViewController.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRAlbumData.h"

@interface SRAlbumViewController : UINavigationController
//资源类型 0：全部 1：照片 2：视频
@property (nonatomic, assign) NSInteger     resourceType;
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

@end

@interface SRAlbumController : UIViewController


@end
