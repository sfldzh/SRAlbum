//
//  SRPhotoEidtViewDelegate.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/18.
//  Copyright © 2017年 sfl. All rights reserved.
//

#ifndef SRPhotoEidtViewDelegate_h
#define SRPhotoEidtViewDelegate_h

#import <UIKit/UIKit.h>
@class SRPhotoEidtViewController;
@protocol SRPhotoEidtViewDelegate <NSObject>

/**
 TODO:图片编辑完成

 @param datas 图片数组
 @param viewController 编辑页面
 */
- (void)didEidtEndWithDatas:(NSArray *)datas viewController:(SRPhotoEidtViewController *)viewController;

@end


#endif /* SRPhotoEidtViewDelegate_h */
