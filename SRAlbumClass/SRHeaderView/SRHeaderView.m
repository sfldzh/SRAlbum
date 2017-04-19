//
//  SRHeaderView.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRHeaderView.h"
@interface SRHeaderView()
@property (nonatomic, strong)UIView *lineView;
@property (nonatomic, strong)UIButton *rightButton;
@property (nonatomic, strong)UIButton *leftButton;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UIImage *rightImage;
@property (nonatomic, strong)UIImage *leftImage;
@end

@implementation SRHeaderView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configerView];
        [self addViews];
        [self addNotification];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configerView];
        [self addViews];
        [self addNotification];
    }
    return self;
}

- (void)addNotification{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)addViews{
    [self addSubview:self.lineView];
}

- (void)configerView{
    self.backgroundColor = [UIColor whiteColor];
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor lightGrayColor];
    }
    return _lineView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _leftButton;
}
- (UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
    return _rightButton;
}

- (void)statusBarOrientationChange:(NSNotification *)notification{
    [self setNeedsLayout];
}


/**
 TODO:设置view的位置
 */
- (void)setViewPosition{
    BOOL landscape = NO;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight||orientation ==UIInterfaceOrientationLandscapeLeft){
        landscape = YES;
    }else if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown){
        landscape = NO;
    }
    if (self.noStatue) {
        landscape = YES;
    }
    CGSize size = [[UIScreen mainScreen] bounds].size;
    self.frame = CGRectMake(0, 0, size.width, landscape?44:64);
    self.lineView.frame = CGRectMake(0, landscape?43.5:63.5, size.width, 0.5);
    CGFloat interval = 6;
    if(_titleLabel.superview){
        self.titleLabel.frame = CGRectMake((size.width-120)/2, landscape?0:20, 120, 44);
    }
    if(_rightButton.superview){
        if (self.rightImage) {
            self.rightButton.frame = CGRectMake(size.width-44-interval, landscape?0:20, 44, 44);
        }else{
            CGSize buttonSize = [self.rightButton.titleLabel.text boundingRectWithSize:CGSizeMake(size.width/2-60-interval,44) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.rightButton.titleLabel.font} context:nil].size;
            self.rightButton.frame = CGRectMake(size.width-buttonSize.width-interval, landscape?0:20, buttonSize.width, 44);
        }
    }
    if (_leftButton.superview) {
        if (self.leftImage) {
            self.leftButton.frame = CGRectMake(interval, landscape?0:20, 44, 44);
        }else{
            CGSize buttonSize = [self.leftButton.titleLabel.text boundingRectWithSize:CGSizeMake(size.width/2-60-interval,44) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.leftButton.titleLabel.font} context:nil].size;
            self.leftButton.frame = CGRectMake(interval, landscape?0:20, buttonSize.width, 44);
        }
    }
}

- (void)setTitle:(NSString *)title{
    _title = title;
    if (!self.titleLabel.superview) {
        [self addSubview:self.titleLabel];
    }
    self.titleLabel.text = title;
}

- (void)leftBtnSetTitle:(NSString *)title forState:(UIControlState)state{
    if (!self.leftButton.superview) {
        [self addSubview:self.leftButton];
    }
    [self.leftButton setTitle:title forState:state];
    [self setNeedsLayout];
}

- (void)leftBtnSetImage:(UIImage *)image forState:(UIControlState)state{
    if (!self.leftButton.superview) {
        [self addSubview:self.leftButton];
    }
    [self.leftButton setImage:image forState:state];
    self.leftImage = image;
    [self setNeedsLayout];
}

- (void)leftBtnAddTarget:(id)target selector:(SEL)selector{
    if (!self.leftButton.superview) {
        [self addSubview:self.leftButton];
    }
    [self.leftButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)rightBtnSetTitle:(NSString *)title forState:(UIControlState)state{
    if (!self.rightButton.superview) {
        [self addSubview:self.rightButton];
    }
    [self.rightButton setTitle:title forState:state];
    [self setNeedsLayout];
}

- (void)rightBtnSetImage:(UIImage *)image forState:(UIControlState)state{
    if (!self.rightButton.superview) {
        [self addSubview:self.rightButton];
    }
    [self.rightButton setImage:image forState:state];
    self.rightImage = image;
    [self setNeedsLayout];
}

- (void)rightBtnAddTarget:(id)target selector:(SEL)selector{
    if (!self.rightButton.superview) {
        [self addSubview:self.rightButton];
    }
    [self.rightButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)changRightBtnEnable:(BOOL)enable{
    self.rightButton.userInteractionEnabled = enable;
}

- (void)changeRightBthSelect:(BOOL)select{
    self.rightButton.selected = select;
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
