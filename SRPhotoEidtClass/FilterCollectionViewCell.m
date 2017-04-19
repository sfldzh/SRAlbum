//
//  FilterCollectionViewCell.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/17.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "FilterCollectionViewCell.h"
@interface FilterCollectionViewCell()

@property (nonatomic, strong) UILabel       *titleLabel;
@end

@implementation FilterCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
    }
    return self;
}

- (void)addViews{
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.borderColor = [UIColor redColor].CGColor;
    }
    return _imageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor lightGrayColor];
    }
    return _titleLabel;
}

- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.imageView.layer.borderWidth = isSelected?1.5:0.0;
}

- (void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    self.titleLabel.text = titleStr;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame));
    self.titleLabel.frame = CGRectMake(0, CGRectGetHeight(self.imageView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetHeight(self.imageView.frame));
}

@end
