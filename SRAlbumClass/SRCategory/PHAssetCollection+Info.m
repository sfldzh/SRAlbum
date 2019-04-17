//
//  PHAssetCollection+Info.m
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "PHAssetCollection+Info.h"
#import <objc/runtime.h>

@implementation PHAssetCollection (Info)

- (void)setAssets:(PHFetchResult *)assets{
    objc_setAssociatedObject(self, @selector(assets), assets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PHFetchResult *)assets{
    PHFetchResult *result = objc_getAssociatedObject(self, _cmd);
    if (result == nil) {
        result = [PHAsset fetchAssetsInAssetCollection:self options:nil];
        self.assets = result;
    }
    return result;
}

@end
