//
//  SRCameraButton.m
//  SRVideoCapture
//
//  Created by 施峰磊 on 2017/4/12.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRCameraButton.h"
#import "EffectView.h"
#import "TransparentView.h"
#import "ProgressView.h"

@interface SRCameraButton()
@property (nonatomic, strong) EffectView        *effectview;
@property (nonatomic, assign) BOOL              isVideotape;
@property (nonatomic, assign) BOOL              videotapeing;
@property (nonatomic, strong) TransparentView   *whiteLayer;
@property (nonatomic, strong) ProgressView      *progressView;
@end

@implementation SRCameraButton

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configerView];
        [self addViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configerView];
        [self addViews];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self configerView];
    [self addViews];
}

- (void)addViews{
    [self addSubview:self.effectview];
    [self.effectview.contentView addSubview:self.progressView];
    [self addSubview:self.whiteLayer];
}

- (TransparentView *)whiteLayer{
    if (!_whiteLayer) {
        _whiteLayer = [TransparentView new];
        _whiteLayer.backgroundColor = [UIColor whiteColor];
        _whiteLayer.userInteractionEnabled = YES;
    }
    return _whiteLayer;
}
- (ProgressView *)progressView{
    if (!_progressView) {
        _progressView = [ProgressView new];
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.userInteractionEnabled = YES;
        _progressView.startAngle = -90;
        _progressView.hidden = YES;
    }
    return _progressView;
}

- (EffectView *)effectview{
    if (!_effectview) {
        _effectview = [[EffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        _effectview.layer.masksToBounds = YES;
        _effectview.userInteractionEnabled = YES;
        
    }
    return _effectview;
}

- (void)setProgress:(float)progress{
    _progress = progress;
    self.progressView.progress = progress;
}

- (void)configerView{
    self.backgroundColor = [UIColor clearColor];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPressGesture];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapClick)]];
    [self addTarget:self action:@selector(didTapClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [self startVideotape];//长按开始
    }else if (longPressGesture.state == UIGestureRecognizerStateEnded){
        [self endVideotape];//长按结束
    }
}

- (void)didTapClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCameraButtonIsVideotape:isStart:)]) {
        [self.delegate didClickCameraButtonIsVideotape:NO isStart:NO];
    }
}

/**
 TODO:开始录像
 */
- (void)startVideotape{
    self.isVideotape = YES;
    self.videotapeing = YES;
    self.progressView.hidden = NO;
    self.progressView.progress =  0.0;
    [self setNeedsLayout];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCameraButtonIsVideotape:isStart:)]) {
        [self.delegate didClickCameraButtonIsVideotape:YES isStart:YES];
    }
}

- (void)endVideotape{
    self.videotapeing = NO;
    self.progressView.progress = 0.0f;
    self.progressView.hidden = YES;
    [self setNeedsLayout];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCameraButtonIsVideotape:isStart:)]) {
        [self.delegate didClickCameraButtonIsVideotape:YES isStart:NO];
    }
}

/**
 TODO:设置视图的位置
 */
- (void)setViewPosition{
    if (self.isVideotape) {
        [UIView animateWithDuration:0.3 animations:^{
            if (self.videotapeing) {
                self.effectview.transform = CGAffineTransformScale(self.effectview.transform, 1.25,1.25);
                self.whiteLayer.transform = CGAffineTransformScale(self.whiteLayer.transform, 0.5,0.5);
            }else{
                self.effectview.transform = CGAffineTransformScale(self.effectview.transform, 1.0/1.25,1.0/1.25);
                self.whiteLayer.transform = CGAffineTransformScale(self.whiteLayer.transform, 1.0/0.5,1.0/0.5);
            }
        } completion:^(BOOL finished) {
        }];
        
    }else{
        self.effectview.frame = self.bounds;
        self.progressView.frame = self.bounds;
        self.effectview.layer.cornerRadius = self.bounds.size.width/2.0;
        CGFloat size = CGRectGetWidth(self.frame)*(2.0/3.0);
        self.whiteLayer.frame = CGRectMake((CGRectGetWidth(self.frame)-size)/2, (CGRectGetWidth(self.frame)-size)/2, size, size);
        self.whiteLayer.layer.cornerRadius = size/2.0;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setViewPosition];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
