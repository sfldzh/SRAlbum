//
//  ALAsset+Type.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "ALAsset+Type.h"

@implementation ALAsset (Type)

/**
 TODO:是否是照片

 @return bool值
 */
- (BOOL)ctassetsPickerIsPhoto{
    return ([[self valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]);
}


/**
 TODO:是否是视频

 @return bool值
 */
- (BOOL)ctassetsPickerIsVideo{
    return ([[self valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]);
}

- (UIImage *)badgeImage{
    NSString *imageName;
    if (self.ctassetsPickerIsVideo)
        imageName = @"BadgeVideoSmall";
    if (imageName)
        return [UIImage imageNamed:imageName];
    else
        return nil;
}

@end
