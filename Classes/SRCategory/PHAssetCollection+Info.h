//
//  PHAssetCollection+Info.h
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAssetCollection (Info)
@property (nonatomic, strong) PHFetchResult *assets;
@end

NS_ASSUME_NONNULL_END
