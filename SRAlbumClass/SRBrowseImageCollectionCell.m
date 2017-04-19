//
//  SRBrowseImageCollectionCell.m
//  SRAlbum
//
//  Created by danica on 2017/4/8.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRBrowseImageCollectionCell.h"
#import "SRAlbumHelper.h"

@interface SRBrowseImageCollectionCell () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView                  *scrollView;
@property (nonatomic, assign) BOOL                          hasZoomIn;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@end

@implementation SRBrowseImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
        [self addGesture];
    }
    return self;
}

- (void)addViews{
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imgView];
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 0.5;
        _scrollView.zoomScale = 1.0;
    }
    return _scrollView;
}

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.backgroundColor = [UIColor clearColor];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}


/**
 TODO:添加手势
 */
- (void)addGesture{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
}

/**
 *
 *  TODO:双击 图片放大缩小
 */
- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale == 1.0){
        float newScale = self.scrollView.zoomScale * 2.0;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)setPhAsset:(PHAsset *)phAsset{
    _phAsset = phAsset;
    typeof(self) __weak weakSelf = self;
    self.representedAssetIdentifier = phAsset.localIdentifier;
    PHImageRequestID imageRequestID = [SRAlbumHelper requestImageForAsset:phAsset size:[SRAlbumHelper getSizeWithAsset:phAsset maxHeight:900 maxWidth:600] resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image,NSDictionary *info, BOOL isDegraded) {
        weakSelf.imgView.image = image;
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
    self.imgView.image = [UIImage imageWithCGImage:alAsset.aspectRatioThumbnail];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    [self setViewPosition];
}

- (void)setViewPosition{
    self.scrollView.frame = self.contentView.bounds;
    self.imgView.frame = self.scrollView.bounds;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.imgView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

- (UIImage *)image {
    return self.imgView.image;
}

@end
