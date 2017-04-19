//
//  SRPhotoEidtDto.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/18.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRPhotoEidtDto : NSObject
@property (nonatomic) float brightness;
@property (nonatomic) float contrast;
@property (nonatomic) float sharpen;
@property (nonatomic) float saturat;
@property (nonatomic) float whiteBalance;
- (void)resetData;
@end
