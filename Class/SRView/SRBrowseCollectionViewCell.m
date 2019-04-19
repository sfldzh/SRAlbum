//
//  SRBrowseCollectionViewCell.m
//  T
//
//  Created by 施峰磊 on 2019/3/7.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRBrowseCollectionViewCell.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "SRPromptManager.h"
#import "PHAsset+Info.h"
#import "SRHelper.h"

typedef NS_ENUM(NSInteger, SRSwipeType){
    SRSwipeTypeNone = 0,    //滑动方向未知
    SRSwipeTypeUp = 1,      //滑动方向向上
    SRSwipeTypeDown = 2     //滑动方向向下
};

@interface SRBrowseCollectionViewCell()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) CGPoint moveImgFirstPoint;
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@property (nonatomic, assign) SRSwipeType swipeType;
@property (nonatomic, assign) BOOL isCanEnd;
@property (nonatomic, assign) CGRect imageResetFrame;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
//视频显示
@property (nonatomic, strong) AVPlayer                      *player;
@property (nonatomic, strong) AVPlayerLayer                 *playerLayer;
@property (nonatomic, strong) AVPlayerItem                  *playerItem;
@property (nonatomic, strong) AVURLAsset                    *urlAsset;

@end

@implementation SRBrowseCollectionViewCell

- (FLAnimatedImageView *)imageView{
    if (!_imageView) {
        _imageView = [[FLAnimatedImageView alloc] init];
    }
    return _imageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self addViews];
    [self configerView];
    [self addGesture];
}

- (void)addViews{
    [self.scrollView addSubview:self.imageView];
    [self.imageView.layer insertSublayer:self.playerLayer atIndex:0];
}

- (void)configerView{
    self.scrollView.delegate = self;
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = 1.0;
    if (@available(iOS 11.0, *)) self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}


/**
 TODO:添加手势
 */
- (void)addGesture{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHiddenBarTap:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:tapGesture];
    [tapGesture requireGestureRecognizerToFail:doubleTap];
    [self.scrollView.panGestureRecognizer addTarget:self action:@selector(pan:)];
}

- (void)setAsset:(PHAsset *)asset{
    _asset = asset;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([asset isGif]) {
        if (asset.showData == nil) {
            [SRHelper requestOriginalImageDataForAsset:asset completion:^(NSData * imageData, NSDictionary * dic) {
                asset.showData = imageData;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:asset.showData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.animatedImage = animatedImage;
                        CGSize imageSize = [SRHelper imageSizeByMaxSize:screenSize sourceSize:animatedImage.size];
                        self.imageView.frame = CGRectMake((screenSize.width-imageSize.width)/2.0, (screenSize.height-imageSize.height)/2.0, imageSize.width, imageSize.height);
                        self.imageResetFrame = self.imageView.frame;
                    });
                });
            }];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:asset.showData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.animatedImage = animatedImage;
                    CGSize imageSize = [SRHelper imageSizeByMaxSize:screenSize sourceSize:animatedImage.size];
                    self.imageView.frame = CGRectMake((screenSize.width-imageSize.width)/2.0, (screenSize.height-imageSize.height)/2.0, imageSize.width, imageSize.height);
                    self.imageResetFrame = self.imageView.frame;
                });
            });
        }
    }else{
        if (!asset.showImage) {
            [SRHelper requestImageForAsset:asset size:CGSizeMake(360, 720) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image,NSDictionary *info, BOOL isDegraded) {
                asset.showImage = image;
                self.imageView.image = image;
                CGSize imageSize = [SRHelper imageSizeByMaxSize:screenSize sourceSize:image.size];
                self.imageView.frame = CGRectMake((screenSize.width-imageSize.width)/2.0, (screenSize.height-imageSize.height)/2.0, imageSize.width, imageSize.height);
                self.playerLayer.frame = self.imageView.bounds;
                self.imageResetFrame = self.imageView.frame;
            }];
        } else {
            self.imageView.image = asset.showImage;
            CGSize imageSize = [SRHelper imageSizeByMaxSize:screenSize sourceSize:asset.showImage.size];
            self.imageView.frame = CGRectMake((screenSize.width-imageSize.width)/2.0, (screenSize.height-imageSize.height)/2.0, imageSize.width, imageSize.height);
            self.playerLayer.frame = self.imageView.bounds;
            self.imageResetFrame = self.imageView.frame;
        }
    }
    self.scrollView.zoomScale = 1.0;
    self.playButton.hidden = [asset ctassetsPickerIsPhoto];
}

- (IBAction)playAction:(UIButton *)sender {
    self.playButton.hidden = YES;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)asset;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setVedioPlayUrl:urlAsset.URL];
            });
        }else if ([asset isKindOfClass:[AVComposition class]]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SRPromptManager single] showContent:@"该视频为混合剪辑视频，无法预览"];
                self.playButton.hidden = NO;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SRPromptManager single] showContent:@"该视频无法预览"];
                self.playButton.hidden = NO;
            });
        }
    }];
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
 TODO:获取当前的图片
 
 @return 图片
 */
- (UIImage *)currentImage{
    return self.imageView.image;
}


/**
 TODO:停止播放
 */
- (void)stopPlay{
    [self.player pause];
    self.playButton.hidden = [self.asset ctassetsPickerIsPhoto];
    self.playerLayer.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    self.scrollView.zoomScale = 1.0;
}

- (void)showOrHiddenBarTap:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickBar)]) {
        [self.delegate didClickBar];
    }
}

/**
 *
 *  TODO:双击 图片放大缩小
 */
- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale == 1.0){
        float newScale = self.scrollView.zoomScale * 3.5;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}


- (void)pan:(UIPanGestureRecognizer *)pan {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGPoint movePoint = [pan locationInView:self.contentView];
        switch (pan.state) {
            case UIGestureRecognizerStateBegan:{
                self.moveImgFirstPoint = movePoint;
                CGFloat offsetY = self.scrollView.contentOffset.y+self.scrollView.contentInset.top;
                self.swipeType = offsetY>= 0?SRSwipeTypeUp:SRSwipeTypeDown;
                if (self.delegate && [self.delegate respondsToSelector:@selector(willSwipeClose)]) {
                    [self.delegate willSwipeClose];
                }
                if (![self.asset ctassetsPickerIsPhoto]) {
                    self.playButton.hidden = YES;
                }
            }
                break;
            case UIGestureRecognizerStateChanged:{
                NSArray *result = [self panResult:pan];
                self.imageView.frame = [[result objectAtIndex:0] CGRectValue];
                CGFloat alpha = [[result objectAtIndex:1] floatValue];
                self.isCanEnd = alpha <= 0.8;
                self.backView.alpha = alpha;
            }
                break;
            case UIGestureRecognizerStateEnded:{
                self.swipeType = SRSwipeTypeNone;
                if (self.isCanEnd) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(currentImageFrame:)]) {
                        CGRect rect = [self.scrollView convertRect:self.imageView.frame toView:self];
                        [self.delegate currentImageFrame:rect];
                    }
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didSwipeClose)]) {
                        [self.delegate didSwipeClose];
                    }
                }else{
                    [self resetImageView];
                }
            }
                break;
            default:
                [self resetImageView];
                break;
        }
    }
}


/**
 TODO:计算拖动时图片应调整的frame和scale值

 @param pan 拖动手势
 @return frame和scale值
 */
- (NSArray *)panResult:(UIPanGestureRecognizer*)pan{
    CGPoint translation = [pan translationInView:self.scrollView];
    CGPoint currentTouch = [pan locationInView:self.scrollView];
    CGFloat scaleValue = MIN(1.0, MAX(0.3, (1 - translation.y / CGRectGetHeight(self.bounds))));
    CGFloat width = CGRectGetWidth(self.imageResetFrame) * scaleValue;
    CGFloat height = CGRectGetHeight(self.imageResetFrame) * scaleValue;
    
    CGFloat xRate = (self.moveImgFirstPoint.x - self.imageResetFrame.origin.x)/CGRectGetWidth(self.imageResetFrame);
    CGFloat currentTouchDeltaX = xRate * width;
    CGFloat x = currentTouch.x - currentTouchDeltaX;
    
    
    CGFloat yRate = (self.moveImgFirstPoint.y - self.imageResetFrame.origin.y)/CGRectGetHeight(self.imageResetFrame);
    CGFloat currentTouchDeltaY = yRate * height;
    CGFloat y = currentTouch.y - currentTouchDeltaY;
    return @[[NSValue valueWithCGRect:CGRectMake(isnan(x)?0:x, isnan(y)?0:y, width, height)], @(scaleValue)];
}


- (void)resetImageView{
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.frame = self.imageResetFrame;
        self.backView.alpha = 1.0;
    }completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cancelSwipeClose)]) {
            [self.delegate cancelSwipeClose];
        }
        if (![self.asset ctassetsPickerIsPhoto]) {
            self.playButton.hidden = NO;
        }
    }];
}


- (CGRect)getCurrentImageFrame{
    return self.imageView.frame;
}


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

@end
