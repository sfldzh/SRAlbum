//
//  ToolView.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/17.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRPhotoEidtDto.h"

@protocol ToolViewDelegate<NSObject>
@optional
/**
 TODO:选择滤镜

 @param index 序号
 */
- (void)didSelectFilterIndex:(NSUInteger)index;


/**
 TODO:调整图片的样式

 @param value 值
 @param type 类型
 */
- (void)didAdjustmentWithValue:(CGFloat)value type:(NSUInteger)type;


/**
 TODO:选择了第几工具序号

 @param index 序号
 */
- (void)didSeletToolIndex:(NSUInteger)index;
@end
@interface ToolView : UIView
@property (nonatomic, weak) id<ToolViewDelegate>delegate;
@property (nonatomic, assign) NSUInteger selectIndex;
@property (nonatomic, strong) NSArray *effectList;//效果
@property (nonatomic, strong) NSArray *titleList;//效果
@property (nonatomic, assign) int imageIndex;//图片第几个
@property (nonatomic, strong) SRPhotoEidtDto *photoEidtDto;

/**
 TODO:获取滤镜的序号
 
 @param imageIndex 图片序号
 @return 滤镜的序号
 */
- (NSUInteger)filterStyleByImageIndex:(NSUInteger)imageIndex;
@end
