//
//  SRBrowseImageCollectionCell.h
//  SRAlbum
//
//  Created by danica on 2017/4/8.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+Type.h"
#import "ALAsset+Type.h"

@interface SRBrowseImageCollectionCell : UICollectionViewCell
@property (nonatomic, strong) PHAsset                       *phAsset;
@property (nonatomic, strong) ALAsset                       *alAsset;
@property (nonatomic, strong) UIImageView                   *imgView;
@property (nonatomic, strong) NSIndexPath                   *indexpath;
/**
 TODO:停止播放
 */
- (void)stopPlay;
@end

