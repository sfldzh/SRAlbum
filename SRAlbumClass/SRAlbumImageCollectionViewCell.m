//
//  ImageCollectionViewCell.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRAlbumImageCollectionViewCell.h"
#import "SRAlbumHelper.h"

@interface SRAlbumImageCollectionViewCell()<CAAnimationDelegate>
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) UIImageView   *flagImage;
@property (nonatomic, strong) UIButton      *selectButton;
@property (nonatomic, strong) UIView        *maskView;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end

@implementation SRAlbumImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.backgroundColor = [UIColor lightGrayColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self addViews];
    }
    return self;
}

- (void)addViews{
    [self addSubview:self.imageView];
    [self addSubview:self.flagImage];
    [self addSubview:self.maskView];
    [self addSubview:self.selectButton];
}

- (UIButton *)selectButton{
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"SRAlbum_no_selected"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"SRAlbum_selected"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(didSelectdActionWithButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIImageView *)flagImage{
    if (!_flagImage) {
        _flagImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _flagImage.contentMode = UIViewContentModeScaleAspectFit;
        _flagImage.clipsToBounds = YES;
    }
    return _flagImage;
}

- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        _maskView.hidden = YES;
    }
    return _maskView;
}

- (void)setShowSelect:(BOOL)showSelect{
    _showSelect = showSelect;
    self.selectButton.hidden = !showSelect;
}

- (void)setIsSelectd:(BOOL)isSelectd{
    _isSelectd = isSelectd;
    self.selectButton.selected = isSelectd;
}

- (void)setIsShowMask:(BOOL)isShowMask{
    _isShowMask = isShowMask;
    self.maskView.hidden = !isShowMask;
}

- (void)setPhAsset:(PHAsset *)phAsset{
    _phAsset = phAsset;
    
    typeof(self) __weak weakSelf = self;
    self.flagImage.image = [phAsset badgeImage];
    self.showSelect = [phAsset ctassetsPickerIsPhoto];
    self.representedAssetIdentifier = phAsset.localIdentifier;
    PHImageRequestID imageRequestID = [SRAlbumHelper requestImageForAsset:phAsset size:[SRAlbumHelper getSizeWithAsset:phAsset maxHeight:200 maxWidth:200] resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image,NSDictionary *info, BOOL isDegraded) {

        weakSelf.imageView.image = image;

        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    }];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;

    
}

- (void)setAlAsset:(ALAsset *)alAsset{
    _alAsset = alAsset;
    self.flagImage.image = [alAsset badgeImage];
    self.showSelect = [alAsset ctassetsPickerIsPhoto];
    self.imageView.image = [UIImage imageWithCGImage:alAsset.aspectRatioThumbnail];
}

- (void)didSelectdActionWithButton:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSelectActionIndexpath:)]) {
        [self.delegate didClickSelectActionIndexpath:self.indexpath];
        CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        popAnimation.delegate = self;
        popAnimation.duration = 0.6;
        popAnimation.values = @[@(1.0),@(1.25),@(0.95),@(1.1),@(1.0)];
        popAnimation.keyTimes = @[@(0.0),@(0.25),@(0.5),@(0.75),@(1.0)];
        popAnimation.calculationMode = kCAAnimationLinear;
        [button.layer addAnimation:popAnimation forKey:@"popAnimation"];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.flagImage.frame = CGRectMake(self.bounds.size.width-25, self.bounds.size.height-20, 20, 15);
    self.selectButton.frame = CGRectMake(self.bounds.size.width-30, 0, 30, 30);
    self.maskView.frame = self.bounds;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.selectButton.layer removeAnimationForKey:@"popAnimation"];
}

@end
