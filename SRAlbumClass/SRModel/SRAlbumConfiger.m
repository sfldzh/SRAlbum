//
//  SRAlbumData.m
//  T
//
//  Created by 施峰磊 on 2019/3/6.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRAlbumConfiger.h"

static SRAlbumConfiger *_albumConfiger;

@implementation SRAlbumConfiger

/**
 TODO:单例获取数据
 
 @return 数据
 */
+ (SRAlbumConfiger *)singleton{
    @synchronized(self){
        if (!_albumConfiger) {
            _albumConfiger = [[self alloc] init];
            [_albumConfiger initData];
        }
    }
    return _albumConfiger;
}

/**
 TODO:释放单例数据
 */
+ (void)freeData{
    if (_albumConfiger) {
        _albumConfiger = nil;
    }
}

- (void)initData{
    _maxItem = 9;
    _maxTime = 10;
    _maxlength = 2*1024*1024;
}

- (void)setIsEidt:(BOOL)isEidt{
    _isEidt = isEidt;
    if(isEidt){
        _maxItem = 1;
    }
    if (isEidt) {
        _assetType = SRAssetTypePic;
    }
}

- (void)setMaxItem:(NSUInteger)maxItem{
    _maxItem = self.isEidt?1:maxItem;
}

- (void)setAssetType:(SRAssetType)assetType{
    _assetType = self.isEidt?SRAssetTypePic:assetType;
}
@end
