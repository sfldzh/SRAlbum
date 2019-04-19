//
//  SRVideoCaptureViewController.m
//  T
//
//  Created by 施峰磊 on 2019/3/13.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRVideoCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "SREidtViewController.h"
#import "SRAlbumConfiger.h"
#import "SRCameraButton.h"
#import "SRHelper.h"

@interface SRVideoCaptureViewController ()<SRCameraButtonDelegate,AVCapturePhotoCaptureDelegate,AVCaptureFileOutputRecordingDelegate,SREidtViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;
@property (weak, nonatomic) IBOutlet SRCameraButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIImageView *showImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

//视频和照片组件
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *preViewLayer;
@property (nonatomic, strong) AVCaptureSession              *captureSession;
@property (nonatomic, strong) AVCaptureMovieFileOutput      *movieFileOutput;
@property (nonatomic, strong) AVCapturePhotoOutput          *stillImageOutput API_AVAILABLE(ios(10.0));
@property (nonatomic, strong) AVCaptureStillImageOutput     *stillImageToOutput;
@property (nonatomic, strong) AVCaptureDeviceInput          *videoDeviceInput;
@property (nonatomic, strong) AVCaptureDevice               *frontCamera;//前面相机
@property (nonatomic, strong) AVCaptureDevice               *backCamera;//后面相机

//视频显示
@property (nonatomic, strong) AVPlayerLayer                 *playerLayer;
@property (nonatomic, strong) AVPlayerItem                  *playerItem;
@property (strong, nonatomic) UIImageView                   *focusRectView;//对焦显示界面

@property (strong, nonatomic) CMMotionManager               *motionManager;//加速器
@property (assign, nonatomic) NSInteger                     screenDirection;//0:竖屏1:靠左横屏2:靠右横屏3:倒屏

@property (nonatomic, assign) CGFloat                       currentTime;
@property (nonatomic, strong) CADisplayLink                 *currentTimer;
@property (nonatomic, strong) id                            content;
@end

@implementation SRVideoCaptureViewController

- (void)dealloc{
    [self removeNotification];
}


- (CMMotionManager *)motionManager{
    if (!_motionManager) {
        _motionManager = [CMMotionManager new];
        _motionManager.deviceMotionUpdateInterval = 0.3;
    }
    return _motionManager;
}

/**
 TODO:前面相机GET方法

 @return 前面相机
 */
- (AVCaptureDevice *)frontCamera{
    if (!_frontCamera) {
        if (@available(iOS 10.0, *)) {
            _frontCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }else{
            NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            for (AVCaptureDevice *camera in cameras) {
                if (camera.position == AVCaptureDevicePositionFront) {
                    _frontCamera = camera;
                    break;
                }
            }
        }
    }
    return _frontCamera;
}

/**
 TODO:后面相机GET方法
 
 @return 后面相机
 */
- (AVCaptureDevice *)backCamera{
    if (!_backCamera) {
        if (@available(iOS 10.0, *)) {
            _backCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        }else{
            NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            for (AVCaptureDevice *camera in cameras) {
                if (camera.position == AVCaptureDevicePositionBack) {
                    _backCamera = camera;
                    break;
                }
            }
        }
        [_backCamera lockForConfiguration:nil];
        if ([_backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [_backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [_backCamera unlockForConfiguration];
    }
    return _backCamera;
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


- (AVCapturePhotoOutput *)stillImageOutput NS_AVAILABLE_IOS(10_0) {
    if (!_stillImageOutput) {
        _stillImageOutput = [[AVCapturePhotoOutput alloc] init];
    }
    return _stillImageOutput;
}

- (AVCaptureStillImageOutput *)stillImageToOutput NS_DEPRECATED_IOS(4_0, 10_0){
    if (!_stillImageToOutput) {
        _stillImageToOutput = [[AVCaptureStillImageOutput alloc] init];
    }
    return _stillImageToOutput;
}

- (AVCaptureDeviceInput *)videoDeviceInput{
    if (!_videoDeviceInput) {
        _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:nil];
    }
    return _videoDeviceInput;
}

- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

- (UIImageView *)focusRectView{
    if (!_focusRectView) {
        _focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        _focusRectView.image = [UIImage imageNamed:@"SR_touch_focus_not"];
        _focusRectView.alpha = 0;
    }
    return _focusRectView;
}


- (void)setScreenDirection:(NSInteger)screenDirection{
    _screenDirection = screenDirection;
    [UIView animateWithDuration:0.25 animations:^{
        //0:竖屏1:靠左横屏2:靠右横屏3:倒屏
        if (screenDirection == 0) {
            self.dismissButton.layer.affineTransform = CGAffineTransformMakeRotation(0);
            self.switchButton.layer.affineTransform = CGAffineTransformMakeRotation(0);
        } else if (screenDirection == 1){
            self.dismissButton.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
            self.switchButton.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
        } else if (screenDirection == 2){
            self.dismissButton.layer.affineTransform = CGAffineTransformMakeRotation(M_PI+ M_PI_2);
            self.switchButton.layer.affineTransform = CGAffineTransformMakeRotation(M_PI+ M_PI_2);
        } else {
            self.dismissButton.layer.affineTransform = CGAffineTransformMakeRotation(M_PI);
            self.switchButton.layer.affineTransform = CGAffineTransformMakeRotation(M_PI);
        }
    }];
}


- (void)loadView{
    [super loadView];
    //权限判断
    NSString *desc;
    if ([self checkAuthorization:&desc]) {
        [self addViews];
    }else{
        [SRHelper alertWithTitle:@"提示" message:desc cancelButtonTitle:@"取消" otherButtonTitle:@"设置" isSheet:NO callBackHandler:^(UIAlertTagAction *action) {
            if (action.tag == 1) {
                [SRHelper prowerSetView];
            }
            [self dismissViewControllerAnimated:action.tag==0?YES:NO completion:nil];
        }];
    }
}


/**
 TODO:检查权限

 @param desc 描述
 @return 权限
 */
- (BOOL)checkAuthorization:(NSString **)desc{
    BOOL capture = [SRHelper canAccessVideoCapture];
    BOOL isAuthorization = NO;
    if ([SRAlbumConfiger singleton].assetType != SRAssetTypePic) {
        BOOL mic = [SRHelper canAccessVideoMic];
        NSMutableArray *descList = [NSMutableArray arrayWithCapacity:0];
        if (!mic || !capture) {
            if (!capture) {
                [descList addObject:@"摄像"];
            }
            if (!mic) {
                [descList addObject:@"录音"];
            }
            *desc = [NSString stringWithFormat:@"没有权限来%@，要设置权限吗？",[descList componentsJoinedByString:@"和"]];
        }
        isAuthorization = (mic && capture);
    }else{
        isAuthorization = capture;
        *desc = @"没有权限来拍照，要设置权限吗？";
    }
    return isAuthorization;
}


- (void)addViews{
    [self.captureSession addInput:self.videoDeviceInput];
    if ([SRAlbumConfiger singleton].assetType != SRAssetTypePic) {
        [self.captureSession addInput:[AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil]];
        [self.captureSession addOutput:self.movieFileOutput];
    }
    if ([SRAlbumConfiger singleton].assetType != SRAssetTypeVideo){
        if (@available(iOS 10.0, *)) {
            [self.captureSession addOutput:self.stillImageOutput];
        }else{
            [self.captureSession addOutput:self.stillImageToOutput];
        }
    }
    self.preViewLayer.session = self.captureSession;
    [self.view.layer insertSublayer:self.preViewLayer atIndex:0];
    [self.showImage.layer insertSublayer:self.playerLayer atIndex:0];
    [self.view addSubview:self.focusRectView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configerView];
    [self checkDeviceOrientation];
    [self.captureSession startRunning];
}

- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configerView{
    if (@available(iOS 11.0, *)) {
        self.bottom.constant += [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    self.cameraButton.delegate = self;
    self.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.titleLabel.layer.shadowOffset = CGSizeMake(0,0);
    self.titleLabel.text = [SRAlbumConfiger singleton].assetType == SRAssetTypeNone?@"轻触拍照，按住摄像":([SRAlbumConfiger singleton].assetType == SRAssetTypePic?@"轻触拍照":@"按住摄像");
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


/**
 TODO:灯光控制事件

 @param sender 按钮
 */
- (IBAction)lightControlAction:(UIButton *)sender {
    AVCaptureDevice *captureDevice = self.videoDeviceInput.device;
    if ([captureDevice hasTorch]) {
        [captureDevice lockForConfiguration:nil];
        [captureDevice setTorchMode: captureDevice.torchMode != AVCaptureTorchModeOn?AVCaptureTorchModeOn:AVCaptureTorchModeOff];
        [captureDevice unlockForConfiguration];
    }
}

- (IBAction)didClickDismiss:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



/**
 TODO:摄像头选择事件

 @param sender 按钮
 */
- (IBAction)switchCameraAction:(UIButton *)sender {
    [self swithCamera];
}

- (IBAction)cancelSelectedAction:(UIButton *)sender {
    self.showView.hidden = YES;
    if ([self.content isKindOfClass:[UIImage class]]) {
        self.content = nil;
    }else{
        [self.playerLayer.player pause];
        [SRHelper deleteFileByPath:self.content];
        self.content = nil;
    }
}

- (IBAction)didSelectedAction:(UIButton *)sender {
    if ([SRAlbumConfiger singleton].isEidt && [self.content isKindOfClass:[UIImage class]]) {//编辑图片
        SREidtViewController *vc = [[SREidtViewController alloc] initWithNibName:@"SREidtViewController" bundle:nil];
        vc.delegate = self;
        vc.image = self.content;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(captureFinish:)]) {
            if ([self.content isKindOfClass:[UIImage class]]) {
                NSData *imageData = UIImageJPEGRepresentation(self.content, 1);
                if ([SRAlbumConfiger singleton].maxlength != 0 && [SRAlbumConfiger singleton].maxlength < imageData.length) {//如果图片这压缩
                    [self.delegate captureFinish:[SRHelper compressImage:self.content toByte:[SRAlbumConfiger singleton].maxlength]];
                }else{
                    [self.delegate captureFinish:self.content];
                }
            }else{
                [self.delegate captureFinish:self.content];
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


/**
 TODO:播放视频

 @param playUrl 视频地址
 */
- (void)vedioPlayUrl:(NSURL *)playUrl{
    if (playUrl) {
        AVURLAsset *urlAsset = [AVURLAsset assetWithURL:playUrl];
        self.playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
        self.playerLayer.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        [self.playerLayer.player play];
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
    if (self.playerLayer.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.playerLayer.player pause];
        CMTime dragedCMTime = CMTimeMake(time, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [self.playerLayer.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            if (completionHandler) {
                completionHandler(finished);
            }
            [weakSelf.playerLayer.player play];
        }];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.content) {//还未拍摄
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self.view];
        [self showFocusRectAtPoint:touchPoint];
        [self focusInPoint:touchPoint];
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
 TODO:切换摄像头
 */
- (void)swithCamera{
    [self.captureSession stopRunning];
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.videoDeviceInput];
    if (self.videoDeviceInput.device == self.backCamera) {
        self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.frontCamera error:nil];
    }else{
        self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:nil];
    }
    [self.captureSession addInput:self.videoDeviceInput];
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
    
    
}

/**
 TODO:检测屏幕方向
 */
- (void)checkDeviceOrientation{
    // 确定是否使用任何可用的态度参考帧来决定设备的运动是否可用
    if (self.motionManager.deviceMotionAvailable) {
        // 启动设备的运动更新，通过给定的队列向给定的处理程序提供数据。
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            if (!error) {
                NSInteger direction = 0;
                double x = motion.gravity.x;
                double y = motion.gravity.y;
                if (fabs(y) >= fabs(x)){
                    direction = y<0?0:3;
                }else{
                    direction = x<0?1:2;
                }
                if (direction != self.screenDirection) {
                    self.screenDirection = direction;
                }
            }
        }];
    }else{//不可以使用则释放
        self.motionManager = nil;
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.preViewLayer.frame = self.view.bounds;
    self.playerLayer.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate {
    return NO;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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

/**
 TODO:拍照
 */
- (void)shutterCamera{
    if (@available(iOS 10.0,*)) {
        AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        if (videoConnection) {
            AVCapturePhotoSettings *settings = [AVCapturePhotoSettings new];
            [self.stillImageOutput capturePhotoWithSettings:settings delegate:self];
        }
    }else{
        AVCaptureConnection *videoConnection = [self.stillImageToOutput connectionWithMediaType:AVMediaTypeVideo];
        if (videoConnection) {
            [self.stillImageToOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                if (imageDataSampleBuffer == NULL) {
                    return;
                }
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [UIImage imageWithData:imageData];
                self.showView.hidden = NO;
                self.showImage.image = image;
                self.content = image;
            }];
        }
    }
}

/**
 TODO:开始录制视频
 
 @param fileURL 文件路径
 */
- (void)startRecordingToOutputFileURL:(NSURL *)fileURL{
    AVCaptureConnection *videoConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if (![self.movieFileOutput isRecording]) {
        //开始录制视频使用到了代理 AVCaptureFileOutputRecordingDelegate 同时还有录制视频保存的文件地址的
        [self.movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
        self.cameraButton.progress = 0.0;
        self.currentTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTriggered)];
        [self.currentTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)displayLinkTriggered{
    self.currentTime++;
    self.cameraButton.progress = (self.currentTime/60.0f)/[SRAlbumConfiger singleton].maxTime;
    if ((self.currentTime/60.0f)>=[SRAlbumConfiger singleton].maxTime) {
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

#pragma mark - SREidtViewControllerDelegate
/**
 TODO:编辑图片完成
 
 @param image 图片
 */
- (void)imageEidtFinish:(UIImage *)image{
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureFinish:)]) {
        self.content = image;
        NSData *imageData = UIImageJPEGRepresentation(self.content, 1);
        if ([SRAlbumConfiger singleton].maxlength != 0 && [SRAlbumConfiger singleton].maxlength < imageData.length) {//如果图片这压缩
            [self.delegate captureFinish:[SRHelper compressImage:self.content toByte:[SRAlbumConfiger singleton].maxlength]];
        }else{
            [self.delegate captureFinish:self.content];
        }
    }
}

#pragma mark - SRCameraButtonDelegate
/**
 TODO:拍照按钮点击
 
 @param isVideotape 是否是录像
 @param isStart 是否开始录像
 */
- (void)didClickCameraButtonIsVideotape:(BOOL)isVideotape isStart:(BOOL)isStart{
    if (!isVideotape && [SRAlbumConfiger singleton].assetType != SRAssetTypeVideo) {//拍照
        [self shutterCamera];
    }else{//录像
        if ([SRAlbumConfiger singleton].assetType != SRAssetTypePic) {
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
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error NS_AVAILABLE_IOS(10_0){
    if (!error) {
        NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        self.showView.hidden = NO;
        self.showImage.image = image;
        self.content = image;
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    self.currentTime = 0.0f;
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    if (!error) {
        [self vedioPlayUrl:outputFileURL];
        self.showView.hidden = NO;
        self.content = outputFileURL;
    }
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
