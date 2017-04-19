//
//  PHAsset+Type.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//


#import <Photos/Photos.h>
@interface PHAsset (Type)
- (BOOL)ctassetsPickerIsPhoto;
- (BOOL)ctassetsPickerIsVideo;
- (BOOL)ctassetsPickerIsHighFrameRateVideo;
- (BOOL)ctassetsPickerIsTimelapseVideo;
- (UIImage *)badgeImage;

@end
