//
//  ImageCollectionViewCell.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+Type.h"
#import "ALAsset+Type.h"
@protocol ImageCollectionViewCellDelegate<NSObject>

/**
 TODO:点击选中按钮

 @param indexpath 位置
 */
- (void)didClickSelectActionIndexpath:(NSIndexPath *)indexpath;
@end

@interface SRAlbumImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) id<ImageCollectionViewCellDelegate>delegate;
@property (nonatomic, strong) PHAsset *phAsset;
@property (nonatomic, strong) ALAsset *alAsset;
@property (nonatomic, assign) BOOL showSelect;
@property (nonatomic, assign) BOOL isSelectd;
@property (nonatomic, assign) BOOL isShowMask;
@property (nonatomic, strong) NSIndexPath *indexpath;
@end

