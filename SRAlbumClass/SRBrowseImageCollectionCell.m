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

//视频显示
@property (nonatomic, strong) AVPlayer                      *player;
@property (nonatomic, strong) AVPlayerLayer                 *playerLayer;
@property (nonatomic, strong) AVPlayerItem                  *playerItem;
@property (nonatomic, strong) AVURLAsset                    *urlAsset;
@property (nonatomic, strong) UIButton                      *playButton;
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
    [self.contentView addSubview:self.playButton];
    [self.scrollView addSubview:self.imgView];
    [self.imgView.layer insertSublayer:self.playerLayer atIndex:0];
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


- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"SRAlbum_Play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}


/**
 TODO:播放视频
 */
- (void)playAction{
    self.playButton.hidden = YES;
    if (ISIOS8) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.phAsset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setVedioPlayUrl:urlAsset.URL];
                });
            }else if ([asset isKindOfClass:[AVComposition class]]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该视频为混合剪辑视频，无法预览" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                    self.playButton.hidden = NO;
                });
            }
        }];
    }else{
        [self setVedioPlayUrl:self.alAsset.defaultRepresentation.url];
    }
}

- (void)setVedioPlayUrl:(NSURL *)playUrl{
    if (playUrl) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        if (_urlAsset) {
            _urlAsset = nil;
        }
        if (_playerItem) {
            _playerItem = nil;
        }
        if (_player) {
            _player = nil;
        }
        
        self.urlAsset = [AVURLAsset assetWithURL:playUrl];
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayer.player = self.player;
        [self.player play];
    }
}

/**
 TODO:播放完了
 *
 *  @param notification 通知
 */
- (void)moviePlayDidEnd:(NSNotification *)notification{
    self.playButton.hidden = NO;
    self.playerLayer.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}


/**
 TODO:停止播放
 */
- (void)stopPlay{
    [self.player pause];
    if (self.alAsset)
        self.playButton.hidden = [self.alAsset ctassetsPickerIsPhoto];
    else
        self.playButton.hidden = [self.phAsset ctassetsPickerIsPhoto];
    self.playerLayer.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
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
    self.playButton.hidden = [phAsset ctassetsPickerIsPhoto];
    self.scrollView.zoomScale = 1.0;
}

- (void)setAlAsset:(ALAsset *)alAsset{
    _alAsset = alAsset;
    self.imgView.image = [UIImage imageWithCGImage:alAsset.aspectRatioThumbnail];
    self.playButton.hidden = [alAsset ctassetsPickerIsPhoto];
    self.scrollView.zoomScale = 1.0;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setViewPosition];
}

- (void)setViewPosition{
    self.scrollView.frame = self.contentView.bounds;
    self.imgView.frame = self.scrollView.bounds;
    self.playerLayer.frame = self.contentView.bounds;
    self.playButton.frame = CGRectMake(CGRectGetWidth(self.frame)/2.0-20, CGRectGetHeight(self.frame)/2.0-20, 40, 40);
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
