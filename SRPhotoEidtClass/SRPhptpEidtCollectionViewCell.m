//
//  SRPhptpEidtCollectionViewCell.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/18.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRPhptpEidtCollectionViewCell.h"

@implementation SRPhptpEidtCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
    }
    return self;
}

- (void)addViews{
    [self.contentView addSubview:self.imgView];
}

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.backgroundColor = [UIColor clearColor];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setViewPosition];
}

- (void)setViewPosition{
    self.imgView.frame = self.contentView.bounds;
}

@end
