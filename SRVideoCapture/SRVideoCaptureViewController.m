//
//  SRVideoCaptureViewController.m
//  SRVideoCapture
//
//  Created by 施峰磊 on 2017/4/12.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRVideoCaptureViewController.h"
#import "SRCameraButton.h"
#import "SRAlbumHelper.h"
#import "MBProgressHUD.h"

#define ISIOS10  ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)

@interface SRVideoCaptureViewController ()<SRCameraButtonDelegate,AVCapturePhotoCaptureDelegate,AVCaptureFileOutputRecordingDelegate,CAAnimationDelegate,UIGestureRecognizerDelegate>
//视频和照片组件
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *preViewLayer;
@property (strong, nonatomic) AVCaptureSession              *captureSession;
@property (strong, nonatomic) AVCaptureMovieFileOutput      *movieFileOutput;
@property (nonatomic, strong) AVCapturePhotoOutput          *stillImageOutput;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) AVCaptureStillImageOutput     *stillImageToOutput;
#pragma clang diagnostic pop
@property (strong, nonatomic) AVCaptureDeviceInput          *videoDeviceInput;
@property (strong, nonatomic) AVCaptureDevice               *frontCamera;//前面相机
@property (strong, nonatomic) AVCaptureDevice               *backCamera;//后面相机

//其他控制组件
@property (nonatomic, strong) SRCameraButton                *cameraButton;//按钮
@property (nonatomic, strong) UIButton                      *backButton;
@property (nonatomic, strong) UIImageView                   *showImageView;//显示图片
@property (nonatomic, strong) UIButton                      *selectButton;//选择按钮
@property (nonatomic, strong) UIButton                      *backShowButton;//取消选择按钮
@property (nonatomic, strong) UIVisualEffectView            *visualEffectView;//毛玻璃
@property (nonatomic, strong) UILabel                       *titleLabel;//提示
@property (nonatomic, strong) UIButton                      *flipButton;//翻转按钮
@property (strong, nonatomic) UIImageView                   *focusRectView;//对焦显示界面
@property (nonatomic, strong) CADisplayLink                 *currentTimer;
@property (nonatomic, strong) MBProgressHUD                 *progressHud;

//数据
@property (nonatomic, assign) BOOL                          isShow;
@property (nonatomic, assign) CGFloat                       currentTime;
@property (nonatomic, assign) BOOL                          isVideotape;//是否是录像
@property (nonatomic, assign) BOOL                          isFront;//是前摄像头
@property (nonatomic, assign) CGFloat                       beginGestureScale;//记录开始的缩放比例
@property (nonatomic, assign) CGFloat                       effectiveScale;//最后的缩放比例

//视频显示
@property (nonatomic, strong) AVPlayer                      *player;
@property (nonatomic, strong) AVPlayerLayer                 *playerLayer;
@property (nonatomic, strong) AVPlayerItem                  *playerItem;
@property (nonatomic, strong) AVURLAsset                    *urlAsset;
@property (nonatomic, strong) id                            content;
@end

@implementation SRVideoCaptureViewController

- (void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(swithCamera) object:nil];
}

- (void)loadView{
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor blackColor];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addViews];
    [self configerView];
    [self addNotification];
    //    [self addGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
    });
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if ([self.captureSession isRunning]) {
            [self.captureSession stopRunning];
        }
    });
}

/**
 TODO: 添加通知
 */
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)configerView{
    NSString *title = @"";
    if (self.type == 0) {
        title = @"轻触拍照，按住摄像";
    }else if (self.type == 1){
        title = @"轻触拍照";
    }else{
        title = @"按住摄像";
    }
    self.titleLabel.text = title;
    [self configerPlayLayer];
}

- (void)addViews{
    [self.captureSession addInput:self.videoDeviceInput];
    if (self.type != 1) {
        [self.captureSession addInput:[AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil]];
        [self.captureSession addOutput:self.movieFileOutput];
    }
    if (self.type != 2){
        if (ISIOS10) {
            [self.captureSession addOutput:self.stillImageOutput];
        }else{
            [self.captureSession addOutput:self.stillImageToOutput];
        }
    }
    self.preViewLayer.session = self.captureSession;
    [self.view.layer addSublayer:self.preViewLayer];
    [self.view addSubview:self.cameraButton];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.flipButton];
    [self.view addSubview:self.focusRectView];
    [self.view addSubview:self.showImageView];
    [self.showImageView addSubview:self.selectButton];
    [self.showImageView addSubview:self.visualEffectView];
    [self.visualEffectView.contentView addSubview:self.backShowButton];
}

- (void)initData{
    self.effectiveScale = self.beginGestureScale = 1.0f;
    self.isFront = NO;
    self.isShow = NO;
    self.currentTime = 0.0;
    self.maxTime = 15;
    if (ISIOS10) {
        self.frontCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        self.backCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        [self.backCamera lockForConfiguration:nil];
        if ([self.backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [self.backCamera unlockForConfiguration];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
        for (AVCaptureDevice *camera in cameras) {
            if (camera.position == AVCaptureDevicePositionFront) {
                self.frontCamera = camera;
            } else {
                self.backCamera = camera;
            }
        }
        [self.backCamera lockForConfiguration:nil];
        if ([self.backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [self.backCamera unlockForConfiguration];
    }
}


/**
 TODO:添加手势
 */
- (void)addGestureRecognizer{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
}


- (AVCaptureVideoPreviewLayer *)preViewLayer{
    if (!_preViewLayer) {
        _preViewLayer = [AVCaptureVideoPreviewLayer layer];
        _preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _preViewLayer;
}

- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    }
    return _captureSession;
}

- (AVCaptureMovieFileOutput *)movieFileOutput{
    if (!_movieFileOutput) {
        _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        AVCaptureConnection *videoConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([videoConnection isVideoStabilizationSupported]) {//录制的稳定
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    return _movieFileOutput;
}


- (AVCapturePhotoOutput *)stillImageOutput{
    if (!_stillImageOutput) {
        _stillImageOutput = [[AVCapturePhotoOutput alloc] init];
    }
    return _stillImageOutput;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (AVCaptureStillImageOutput *)stillImageToOutput{
    if (!_stillImageToOutput) {
        _stillImageToOutput = [[AVCaptureStillImageOutput alloc] init];
    }
    return _stillImageToOutput;
}
#pragma clang diagnostic pop

- (AVCaptureDeviceInput *)videoDeviceInput{
    if (!_videoDeviceInput) {
        _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:nil];
    }
    return _videoDeviceInput;
}

- (SRCameraButton *)cameraButton{
    if (!_cameraButton) {
        _cameraButton = [[SRCameraButton alloc] initWithFrame:CGRectZero];
        _cameraButton.delegate = self;
    }
    return _cameraButton;
}

- (UIButton *)backButton{
    if(!_backButton){
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"SR_Camera_WhiteBack"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backDismissView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIImageView *)showImageView{
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc] init];
        _showImageView.hidden = YES;
        _showImageView.userInteractionEnabled = YES;
        _showImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _showImageView;
}

- (UIButton *)selectButton{
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.backgroundColor = [UIColor whiteColor];
        [_selectButton setImage:[UIImage imageNamed:@"SR_Camera_Selected"] forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(selectFile) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.layer.cornerRadius = 35.0;
        _selectButton.layer.masksToBounds = YES;
    }
    return _selectButton;
}

- (UIButton *)backShowButton{
    if (!_backShowButton) {
        _backShowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backShowButton setImage:[UIImage imageNamed:@"SR_Camera_Cancel"] forState:UIControlStateNormal];
        [_backShowButton addTarget:self action:@selector(cancelSelectPhoto) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backShowButton;
}

- (UIVisualEffectView *)visualEffectView{
    if (!_visualEffectView) {
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _visualEffectView.userInteractionEnabled = YES;
        _visualEffectView.layer.cornerRadius = 35.0;
        _visualEffectView.layer.masksToBounds = YES;
    }
    return _visualEffectView;
}


- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}


- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:13.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _titleLabel.layer.shadowOffset = CGSizeMake(0,0);
        _titleLabel.layer.shadowOpacity = 1.0;
        _titleLabel.layer.shadowRadius = 4;
    }
    return _titleLabel;
}

- (UIButton *)flipButton{
    if (!_flipButton) {
        _flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flipButton setImage:[UIImage imageNamed:@"SRCamera_icon"] forState:UIControlStateNormal];
        [_flipButton addTarget:self action:@selector(fileCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flipButton;
}

- (UIImageView *)focusRectView{
    if (!_focusRectView) {
        _focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        _focusRectView.image = [UIImage imageNamed:@"SR_touch_focus_not"];
        _focusRectView.alpha = 0;
    }
    return _focusRectView;
}

- (void)setVedioPlayUrl:(NSURL *)playUrl{
    if (playUrl) {
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
        //        //填充方式的设置
        //        [self.urlAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        //            if (self.urlAsset.playable) {
        //            }
        //        }];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayer.player = self.player;
        [self.player play];
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem{
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    }
}


/**
 TODO:放大缩小屏幕
 
 @param recognizer 手势
 */
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.preViewLayer convertPoint:location fromLayer:self.preViewLayer.superlayer];
        if ( ! [self.preViewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        NSLog(@"%f-------------->%f------------recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        NSLog(@"%f",maxScaleAndCropFactor);
        //5.f为写死的最大放大倍数
        
        if (self.effectiveScale > 5.f)
            self.effectiveScale = 5.f;
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.preViewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
    }
}


/**
 TODO:对焦界面提示动画
 
 @param point 位置
 */
- (void)showFocusRectAtPoint:(CGPoint)point{
    self.focusRectView.alpha = 1.0f;
    self.focusRectView.center = point;
    self.focusRectView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [UIView animateWithDuration:0.2f animations:^{
        self.focusRectView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.values = @[@0.5f, @1.0f, @0.5f, @1.0f, @0.5f, @1.0f];
        animation.duration = 0.5f;
        [self.focusRectView.layer addAnimation:animation forKey:@"opacity"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f animations:^{
                self.focusRectView.alpha = 0;
            }];
        });
    }];
}

/**
 TODO:播放完了
 *
 *  @param notification 通知
 */
- (void)moviePlayDidEnd:(NSNotification *)notification{
    [self jumpToTime:0 completionHandler:nil];
}

/**
 TODO:跳转到视频的时间
 
 @param time 时间
 @param completionHandler 回调
 */
- (void)jumpToTime:(NSInteger)time completionHandler:(void (^)(BOOL finished))completionHandler {
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.player pause];
        CMTime dragedCMTime = CMTimeMake(time, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            if (completionHandler) {
                completionHandler(finished);
            }
            [weakSelf.player play];
        }];
    }
}


/**
 TODO:返回
 */
- (void)backDismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self resetVedioshow];
    [self resetImageView];
}


/**
 TODO:确定选择文件
 */
- (void)selectFile{
    if (self.iscompress) {
        if (self.isVideotape) {
            [self showLoadingWithMessage:@"视频压缩中"];
            [SRAlbumHelper compressedVideoWithPath:self.content CompletionHandler:^(AVAssetExportSession *exportSession, NSURL *path) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (exportSession.status) {
                        case AVAssetExportSessionStatusCompleted:
                            [self deleteFileByPath:self.content];
                            self.content = nil;
                            if (self.delegate && [self.delegate respondsToSelector:@selector(videoCaptureViewDidFinishWithContent:isVedio:)]) {
                                [self.delegate videoCaptureViewDidFinishWithContent:path isVedio:self.isVideotape];
                                [self backDismissView];
                            }
                            break;
                        default:
                            break;
                    }
                    [self hideHUB];
                });
            }];
        }else{
            if (self.content && self.delegate && [self.delegate respondsToSelector:@selector(videoCaptureViewDidFinishWithContent:isVedio:)]) {
                [self.delegate videoCaptureViewDidFinishWithContent:[self imageCompressForWidth:self.content targetWidth:600] isVedio:self.isVideotape];
                [self backDismissView];
            }
        }
    }else{
        if (self.content && self.delegate && [self.delegate respondsToSelector:@selector(videoCaptureViewDidFinishWithContent:isVedio:)]) {
            [self.delegate videoCaptureViewDidFinishWithContent:self.content isVedio:self.isVideotape];
            [self backDismissView];
        }
    }
}


-(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}


/**
 *    @author 施峰磊, 16-06-01 10:06:27
 *
 *    TODO:显示加载信息
 *
 *    @param message    加载信息
 *
 *    @since 1.0
 */
- (void)showLoadingWithMessage:(NSString *)message{
    if (self.progressHud.superview ||self.progressHud) {
        [self.progressHud hide:NO];
    }
    self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHud.labelText = message;
}

/**
 *    @author 施峰磊, 16-06-01 10:06:03
 *
 *    TODO:隐藏
 *
 *    @since 1.0
 */
- (void)hideHUB{
    [self.progressHud hide:NO];
}


/**
 TODO:翻转镜头
 */
- (void)fileCamera{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = .6f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"oglFlip";
    if (self.isFront){
        animation.subtype = kCATransitionFromRight;
    }else{
        animation.subtype = kCATransitionFromLeft;
    }
    [self.view.layer addAnimation:animation forKey:@"animation"];
    [self performSelector:@selector(swithCamera) withObject:nil afterDelay:0.1];
}


- (void)swithCamera{
    [self.captureSession stopRunning];
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.videoDeviceInput];
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.isFront?self.backCamera:self.frontCamera error:nil];
    [self.captureSession addInput:self.videoDeviceInput];
    [self.captureSession commitConfiguration];
    self.isFront = !self.isFront;
    [self.captureSession startRunning];
}


/**
 TODO:取消选择的图片
 */
- (void)cancelSelectPhoto{
    if (self.isVideotape) {//删除视频内容
        if ([self.content isKindOfClass:[NSURL class]]) {
            [self deleteFileByPath:self.content];
        }
    }
    [self showPhotoIsShow:NO];
    self.content = nil;
}

/**
 TODO:删除本地文件
 
 @param path 文件地址
 */
-(void)deleteFileByPath:(NSURL *)path{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    BOOL blHave=[fileManager fileExistsAtPath:[path path]];
    if (blHave) {
        [fileManager removeItemAtURL:path error:nil];
    }
}

/**
 TODO:播放器服务
 */
- (void)resetVedioshow{
    [self.player pause];
    if (_urlAsset) {
        _urlAsset = nil;
    }
    if (_playerItem) {
        _playerItem = nil;
    }
    if (_player) {
        _player = nil;
    }
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
}


/**
 TODO:图片显示复位
 */
- (void)resetImageView{
    self.showImageView.image = nil;
}


/**
 TODO:屏幕旋转通知
 
 @param notification 通知
 */
- (void)statusBarOrientationChange:(NSNotification *)notification{
    [self configerPlayLayer];
}

- (void)configerPlayLayer{
    UIDeviceOrientation orientation =[[UIDevice currentDevice]orientation];
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            self.preViewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI+ M_PI_2); // 270 degress
            break;
        case UIDeviceOrientationLandscapeRight:
            self.preViewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_2); // 90 degrees
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.preViewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI); // 180 degrees
            break;
        default:
            self.preViewLayer.affineTransform = CGAffineTransformMakeRotation(0.0);
            break;
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.preViewLayer.frame = self.view.bounds;
    self.cameraButton.frame = CGRectMake(size.width/2-35, size.height-90, 70, 70);
    self.titleLabel.frame = CGRectMake(size.width/2-75, CGRectGetMinY(self.cameraButton.frame)-50, 150, 20);
    self.backButton.frame = CGRectMake(CGRectGetMinX(self.cameraButton.frame)/2-20, CGRectGetMidY(self.cameraButton.frame)-20, 40, 40);
    self.flipButton.frame = CGRectMake(size.width-70, 30, 50, 40);
    self.showImageView.frame = self.view.bounds;
    self.playerLayer.frame = self.view.bounds;
    [self setViewFrameByIsShow:self.isShow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 TODO:设置图片选择按钮的位置
 
 @param isShow 是否显示
 */
- (void)setViewFrameByIsShow:(BOOL)isShow{
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.selectButton.frame = CGRectMake(isShow?(size.width/2+(size.width/4)-35):size.width/2-35, size.height-90, 70, 70);
    self.visualEffectView.frame = CGRectMake(isShow?(size.width/4.0-35):size.width/2-35, size.height-90, 70, 70);
    self.backShowButton.frame = self.visualEffectView.bounds;
}


/**
 TODO:显示图片
 
 @param isShow 是否显示
 */
- (void)showPhotoIsShow:(BOOL)isShow{
    self.isShow = isShow;
    if (isShow) {
        self.showImageView.hidden = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self setViewFrameByIsShow:self.isShow];
    } completion:^(BOOL finished) {
        if (!isShow) {
            self.showImageView.hidden = YES;
            [self resetVedioshow];
            [self resetImageView];
        }
    }];
}


/**
 TODO:拍照
 */
- (void)shutterCamera{
    if (ISIOS10) {
        AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        UIDeviceOrientation orientation =[[UIDevice currentDevice]orientation];
        AVCaptureVideoOrientation Orientation;
        switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
                Orientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                Orientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                Orientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                Orientation = AVCaptureVideoOrientationPortrait;
                break;
        }
        //预览图层和视频方向保持一致
        videoConnection.videoOrientation = Orientation;
        if (videoConnection) {
            AVCapturePhotoSettings *settings = [AVCapturePhotoSettings new];
            //            id previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.firstObject;
            //            NSDictionary *previewFormat = @{kCVPixelBufferPixelFormatTypeKey:previewPixelType,
            //                                            kCVPixelBufferWidthKey:@(160),
            //                                            kCVPixelBufferHeightKey:@(160)};
            //            settings.previewPhotoFormat = previewFormat;
            [self.stillImageOutput capturePhotoWithSettings:settings delegate:self];
        }
    }else{
        AVCaptureConnection *videoConnection = [self.stillImageToOutput connectionWithMediaType:AVMediaTypeVideo];
        UIDeviceOrientation orientation =[[UIDevice currentDevice]orientation];
        AVCaptureVideoOrientation Orientation;
        switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
                Orientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                Orientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                Orientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                Orientation = AVCaptureVideoOrientationPortrait;
                break;
        }
        //预览图层和视频方向保持一致
        videoConnection.videoOrientation = Orientation;
        if (videoConnection) {
            [self.stillImageToOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                if (imageDataSampleBuffer == NULL) {
                    return;
                }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
#pragma clang diagnostic pop
                UIImage *image = [UIImage imageWithData:imageData];
                [self showPhotoIsShow:YES];
                self.showImageView.image = image;
                self.content = image;
                NSLog(@"image size = %@", NSStringFromCGSize(image.size));
            }];
        }
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    [self showFocusRectAtPoint:touchPoint];
    [self focusInPoint:touchPoint];
}


/**
 TODO:开始录制视频
 
 @param fileURL 文件路径
 */
- (void)startRecordingToOutputFileURL:(NSURL *)fileURL{
    AVCaptureConnection *videoConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if (![self.movieFileOutput isRecording]) {
        UIDeviceOrientation orientation =[[UIDevice currentDevice]orientation];
        AVCaptureVideoOrientation Orientation;
        switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
                Orientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                Orientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                Orientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                Orientation = AVCaptureVideoOrientationPortrait;
                break;
        }
        //预览图层和视频方向保持一致
        videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
        //开始录制视频使用到了代理 AVCaptureFileOutputRecordingDelegate 同时还有录制视频保存的文件地址的
        [self.movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
        
        self.currentTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTriggered)];
        [self.currentTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)displayLinkTriggered{
    self.currentTime++;
    self.cameraButton.progress = (self.currentTime/60.0f)/(CGFloat)self.maxTime;
    if ((self.currentTime/60.0f)>=self.maxTime) {
        [self stopCurrentVideoRecording];
    }
}


/**
 TODO:结束录制视频
 */
- (void)stopCurrentVideoRecording{
    self.currentTime = 0;
    [self.currentTimer invalidate];
    self.currentTimer = nil;
    [self.movieFileOutput stopRecording];
}


/**
 TODO:对焦
 
 @param touchPoint 点击位置
 */
- (void)focusInPoint:(CGPoint)touchPoint{
    CGPoint cameraPoint= [self.preViewLayer captureDevicePointOfInterestForPoint:touchPoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:cameraPoint monitorSubjectAreaChange:YES];
}


/**
 TODOD:焦距设置
 
 @param focusMode 对焦模式
 @param exposureMode 曝光模式
 @param point 位置
 @param monitorSubjectAreaChange 监控主区域变化
 */
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [self.videoDeviceInput device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported]) {
                [device setFocusPointOfInterest:point];
            }
            
            if ([device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
            }
            
            if ([device isExposurePointOfInterestSupported]) {
                [device setExposurePointOfInterest:point];
            }
            
            if ([device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
            }
            
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            NSLog(@"对焦错误:%@", error);
        }
    });
}


/**
 TODO:文件路径获取
 
 @return 文件路径
 */
- (NSString *)getVideoSaveFilePathString{
    NSString *folderName = @"SRVedioCapture";
    NSString *tempPath  = NSTemporaryDirectory();
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@",tempPath,folderName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:folderPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[folderPath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    return fileName;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.view.layer removeAllAnimations];
}


#pragma mark - SRCameraButtonDelegate
/**
 TODO:拍照按钮点击
 
 @param isVideotape 是否是录像
 @param isStart 是否开始录像
 */
- (void)didClickCameraButtonIsVideotape:(BOOL)isVideotape isStart:(BOOL)isStart{
    self.isVideotape = isVideotape;
    if (!isVideotape && self.type != 2) {//拍照
        [self shutterCamera];
    }else{//录像
        if (self.type != 1) {
            if (isStart) {
                NSString *filePath = [self getVideoSaveFilePathString];
                [self startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath]];
            }else{
                [self stopCurrentVideoRecording];
            }
        }
    }
}

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error{
    if (!error) {
        NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        [self showPhotoIsShow:YES];
        self.showImageView.image = image;
        self.content = image;
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    self.currentTime = 0.0f;
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    self.content = outputFileURL;
    [self setVedioPlayUrl:outputFileURL];
    [self.showImageView.layer insertSublayer:self.playerLayer atIndex:0];
    [self showPhotoIsShow:YES];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

