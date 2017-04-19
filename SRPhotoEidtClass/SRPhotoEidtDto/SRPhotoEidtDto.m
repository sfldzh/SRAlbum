//
//  SRPhotoEidtDto.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/18.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRPhotoEidtDto.h"

@implementation SRPhotoEidtDto

- (instancetype)init{
    self = [super init];
    if (self) {
        self.brightness = 0.0;
        self.contrast = 1.0;
        self.sharpen = 0.0;
        self.saturat = 1.0;
        self.whiteBalance = 0.0;
    }
    return self;
}

- (void)resetData{
    self.brightness = 0.0;
    self.contrast = 1.0;
    self.sharpen = 0.0;
    self.saturat = 1.0;
    self.whiteBalance = 0.0;
}

@end
