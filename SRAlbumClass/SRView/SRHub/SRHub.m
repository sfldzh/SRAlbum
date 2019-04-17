//
//  SRHub.m
//  T
//
//  Created by 施峰磊 on 2019/3/13.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRHub.h"

@implementation SRHub
+ (SRHubView *)show{
    SRHubView *hub = [SRHubView new];
    [hub show];
    return hub;
}

+ (void)hidden:(SRHubView *)hub{
    [hub hiddenView];
}

@end

@interface SRHubView()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end
@implementation SRHubView
- (instancetype)init{
    self = [super init];
    if (self) {
        [self configerView];
    }
    return self;
}

- (void)configerView{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.frame = [UIScreen mainScreen].bounds;
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.indicatorView];
}


- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor blackColor];
        _contentView.layer.cornerRadius = 8;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _indicatorView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat size = 80.0f;
    self.contentView.frame = CGRectMake((CGRectGetWidth(self.frame)-size)/2.0, (CGRectGetHeight(self.frame)-size)/2.0, size, size);
    self.indicatorView.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2.0, CGRectGetHeight(self.contentView.frame)/2.0);
}

- (void)show{
    self.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self.indicatorView startAnimating];
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }];
}

- (void)hiddenView{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.indicatorView startAnimating];
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
