//
//  PromptManager.m
//  Car
//
//  Created by hlet on 2018/5/15.
//  Copyright © 2018年 hlet. All rights reserved.
//

#import "SRPromptManager.h"

static SRPromptManager *_promptManager = nil;
#define SRAPPSIZE [[UIScreen mainScreen] bounds].size

@implementation SRPromptAnimating

@end

@interface SRPromptManager()
@property (nonatomic, strong) UILabel           *promptLabel;
@property (nonatomic, strong) SRPromptAnimating   *promptAnimating;
@property (nonatomic, assign) BOOL              showIng;
@property (nonatomic, assign) CGFloat           bottomValue;
@property (nonatomic, weak) NSTimer             *timer;
@end

@implementation SRPromptManager

- (void)dealloc{
    [self removeNotification];
}

+ (void)load{
    [SRPromptManager single];
}

/**
 TODO:获取单例
 
 @return 单例
 */
+ (instancetype)single{
    @synchronized(self) {
        if (!_promptManager) {
            _promptManager = [[self alloc] init];
        }
    }
    return _promptManager;
}

/**
 TODO:释放
 */
+ (void)freeData{
    if (_promptManager) {
        _promptManager = nil;
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initData];
        [self addNotification];
    }
    return self;
}

- (void)initData{
    self.promptAnimating = [SRPromptAnimating new];
    self.promptAnimating.dismissTransform = CGAffineTransformMakeTranslation(0, -15);;
    self.promptAnimating.showInitialTransform = CGAffineTransformMakeTranslation(0, -15);
    self.promptAnimating.showFinalTransform = CGAffineTransformIdentity;
    self.promptAnimating.springDamping = 0.7;
    self.promptAnimating.springVelocity = 0.7;
    self.promptAnimating.showInitialAlpha = 0.f;
    self.promptAnimating.dismissFinalAlpha = 0.f;
    self.promptAnimating.showDuration = 0.5f;
    self.promptAnimating.dismissDuration = 0.5;
    self.showIng = NO;
    self.bottomValue = 0.0;
}


/**
 TODO:添加通知
 */
- (void)addNotification{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


/**
 TODO:移除通知
 */
- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    
}

- (UILabel *)promptLabel{
    if (!_promptLabel) {
        _promptLabel = [UILabel new];
        _promptLabel.textAlignment =NSTextAlignmentCenter;
        _promptLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:0/255.0 alpha:1.0];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.layer.cornerRadius = 5.0f;
        _promptLabel.layer.masksToBounds = YES;
        _promptLabel.numberOfLines = 0;
        _promptLabel.font = [UIFont systemFontOfSize:14];
    }
    return _promptLabel;
}



/**
 TODO:键盘将要出现

 @param notification 通知
 */
- (void)keyboardWillShow:(NSNotification *)notification{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    self.bottomValue = keyboardRect.size.height;
}


/**
 TODO:键盘将要退出

 @param notification 通知
 */
- (void)keyboardWillHide:(NSNotification *)notification{
    self.bottomValue = 0.0f;
}


/**
 TODO:屏幕旋转回调方法

 @param interfaceOrientation 方向
 */
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation{
    if (self.showIng) {
        CGSize contentSize = [SRPromptManager textSizeWithText:self.promptLabel.text font:self.promptLabel.font maxSize:CGSizeMake(SRAPPSIZE.width-30, 200) compensationSize:CGSizeMake(10, 15)];
        contentSize.width = MAX(contentSize.width, 200);
        self.promptLabel.frame = CGRectMake((SRAPPSIZE.width-contentSize.width)/2.0, SRAPPSIZE.height-contentSize.height-100-self.bottomValue, contentSize.width, contentSize.height);
    }
}

/**
 TODO:显示提示内容

 @param content 提示内容
 */
- (void)showContent:(NSString *)content{
    if(content && content.length>0){
        if (!self.promptLabel.superview) {
            [[UIApplication sharedApplication].keyWindow addSubview:self.promptLabel];
        }
        
        CGAffineTransform initialTransform = self.promptAnimating.showInitialTransform;
        CGAffineTransform finalTransform = self.promptAnimating.showFinalTransform;
        CGFloat initialAlpha = self.promptAnimating.showInitialAlpha;
        CGFloat damping = self.promptAnimating.springDamping;
        CGFloat velocity = self.promptAnimating.springVelocity;
        
        CGSize contentSize = [SRPromptManager textSizeWithText:content font:self.promptLabel.font maxSize:CGSizeMake(SRAPPSIZE.width-30, 200) compensationSize:CGSizeMake(10, 15)];
        contentSize.width = MAX(contentSize.width, 200);
        self.promptLabel.text = content;
        self.promptLabel.frame = CGRectMake((SRAPPSIZE.width-contentSize.width)/2.0, SRAPPSIZE.height-contentSize.height-80-self.bottomValue, contentSize.width, contentSize.height);
        if (!self.showIng) {
            self.promptLabel.transform = initialTransform;
            self.promptLabel.alpha = initialAlpha;
            
            [UIView animateWithDuration:self.promptAnimating.showDuration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.promptLabel.transform = finalTransform;
                self.promptLabel.alpha = 1.0f;
            } completion:nil];
        }
        self.showIng = YES;
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    }
}


/**
 TODO:消失
 */
- (void)dismiss{
    CGFloat damping = self.promptAnimating.springDamping;
    CGFloat velocity = self.promptAnimating.springVelocity;
    [UIView animateWithDuration:self.promptAnimating.dismissDuration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.promptLabel.transform = self.promptAnimating.dismissTransform;
                            self.promptLabel.alpha = self.promptAnimating.dismissFinalAlpha;
                        } completion:^(BOOL finished) {
                            [self.promptLabel removeFromSuperview];
                            self.promptLabel.transform = CGAffineTransformIdentity;
                            self.showIng = NO;
                        }];
}

/**
 TODO:计算文字文本的尺寸
 
 @param text 文字文本
 @param font 字号
 @param maxSize 最大尺寸
 @param compensationSize 补偿尺寸
 @return 文字文本的尺寸
 */
+ (CGSize)textSizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize compensationSize:(CGSize)compensationSize{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(maxSize.width-compensationSize.height, maxSize.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    textSize.width = ceilf(textSize.width+compensationSize.width);
    textSize.height = ceilf(textSize.height+compensationSize.height);
    return textSize;
}


/**
 TODO:显示提示内容
 
 @param message 提示内容
 */
+ (void)showMessage:(NSString *)message{
    [[SRPromptManager single] showContent:message];
}

@end
