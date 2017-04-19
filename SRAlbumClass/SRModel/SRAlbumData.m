//
//  SRAlbumData.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/7.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRAlbumData.h"

static SRAlbumData *_albumData;
@implementation SRAlbumData

/**
 TODO:单例获取数据
 
 @return 数据
 */
+ (SRAlbumData *)singleton{
    @synchronized(self){
        if (!_albumData) {
            _albumData = [[self alloc] init];
        }
    }
    return _albumData;
}

/**
 TODO:释放单例数据
 */
+ (void)freeData{
    if (_albumData) {
        _albumData = nil;
    }
}

@end
