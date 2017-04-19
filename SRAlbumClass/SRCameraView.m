//
//  SRCameraView.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/7.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRCameraView.h"
@interface SRCameraView ()

@end

@implementation SRCameraView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configerView];
        [self addViews];
    }
    return self;
}

- (void)configerView{
    self.backgroundColor = [UIColor lightGrayColor];
}


- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (void)addViews{
    [self addSubview:self.imageView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end
