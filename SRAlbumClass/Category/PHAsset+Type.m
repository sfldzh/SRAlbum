//
//  PHAsset+Type.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "PHAsset+Type.h"
//#import <AssetsLibrary/AssetsLibrary.h>
@implementation PHAsset (Type)
- (BOOL)ctassetsPickerIsPhoto{
    return (self.mediaType == PHAssetMediaTypeImage);
}

- (BOOL)ctassetsPickerIsVideo{
    return (self.mediaType == PHAssetMediaTypeVideo);
}

- (BOOL)ctassetsPickerIsHighFrameRateVideo{
    return (self.mediaType == PHAssetMediaTypeVideo && (self.mediaSubtypes & PHAssetMediaSubtypeVideoHighFrameRate));
}

- (BOOL)ctassetsPickerIsTimelapseVideo{
    return (self.mediaType == PHAssetMediaTypeVideo && (self.mediaSubtypes & PHAssetMediaSubtypeVideoTimelapse));
}

- (UIImage *)badgeImage{
    NSString *imageName;
    
    if (self.ctassetsPickerIsHighFrameRateVideo)
        imageName = @"BadgeSlomoSmall";
    
    else if (self.ctassetsPickerIsTimelapseVideo)
        imageName = @"BadgeTimelapseSmall";
    
    else if (self.ctassetsPickerIsVideo)
        imageName = @"BadgeVideoSmall";
    
    if (imageName)
        return [UIImage imageNamed:imageName];
    else
        return nil;
}


@end
