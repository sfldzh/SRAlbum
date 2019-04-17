//
//  ImageCollectionViewCell.h
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+Info.h"
#import "SRAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ImageCollectionViewCellDelegate <NSObject>


/**
 TODO:操作事件

 @param data 资源数据
 */
- (void)didOperationAction:(PHAsset *)data;

@end

@interface ImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) id<ImageCollectionViewCellDelegate>delegate;
@property (nonatomic, strong) PHAsset *photoData;
@property (nonatomic, assign) SRSelectType selectType;
@property (nonatomic, assign) NSUInteger selectIndex;
@end

NS_ASSUME_NONNULL_END
