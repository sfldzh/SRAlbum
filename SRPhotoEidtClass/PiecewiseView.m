//
//  PiecewiseView.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/17.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "PiecewiseView.h"
@interface PiecewiseView()
@property (nonatomic, strong) UIView            *cueline;
@property (nonatomic, strong) NSMutableArray    *buttonList;
@end

@implementation PiecewiseView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initData];
        [self addViews];
    }
    return self;
}


- (void)initData{
    self.ordinaryColor = [UIColor lightGrayColor];
    self.selectedColor = [UIColor redColor];
    self.buttonList = [NSMutableArray arrayWithCapacity:0];
    self.selectIndex = 0;
}

- (void)addViews{
    [self addSubview:self.cueline];
}

- (void)setButtons:(NSArray *)buttons{
    _buttons = buttons;
    NSUInteger tag = 0;
    for (NSString *name in buttons) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = tag;
        if (tag == self.selectIndex) {
            button.selected = YES;
        }
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:name forState:UIControlStateNormal];
        [button setTitleColor:self.ordinaryColor forState:UIControlStateNormal];
        [button setTitleColor:self.selectedColor forState:UIControlStateSelected];
        [button addTarget:self action:@selector(didClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonList addObject:button];
        [self addSubview:button];
        tag++;
    }
}

- (UIView *)cueline{
    if (!_cueline) {
        _cueline = [[UIView alloc] init];
        _cueline.backgroundColor = self.selectedColor;
    }
    return _cueline;
}

- (void)setOrdinaryColor:(UIColor *)ordinaryColor{
    _ordinaryColor = ordinaryColor;
    for (UIButton *button in self.buttonList) {
        [button setTitleColor:ordinaryColor forState:UIControlStateNormal];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor = selectedColor;
    if (_cueline) {
        self.cueline.backgroundColor = selectedColor;
    }
    for (UIButton *button in self.buttonList) {
        [button setTitleColor:selectedColor forState:UIControlStateSelected];
    }
}

- (void)setSelectIndex:(NSUInteger)selectIndex{
    _selectIndex = selectIndex;
    for (UIButton *tempButton in self.buttonList) {
        if (tempButton.tag != selectIndex) {
            tempButton.selected = NO;
        }else{
            tempButton.selected = YES;
        }
    }
    [self showCuelinePosotion];
}

- (void)didClickAction:(UIButton *)button{
    self.selectIndex = button.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didselectindex:)]) {
        [self.delegate didselectindex:self.selectIndex];
    }
}

- (void)showCuelinePosotion{
    if (_cueline) {
        CGFloat lineWidth = CGRectGetWidth(self.frame)/self.buttons.count;
        [UIView animateWithDuration:0.3 animations:^{
            self.cueline.frame = CGRectMake(self.selectIndex*lineWidth, CGRectGetHeight(self.frame)-2, lineWidth, 2);
        }];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat lineWidth = CGRectGetWidth(self.frame)/self.buttons.count;
    NSUInteger count = 0;
    for (UIButton *button in self.buttonList) {
        button.frame = CGRectMake(count*lineWidth, 0, lineWidth, CGRectGetHeight(self.frame)-2);
        count++;
    }
    self.cueline.frame = CGRectMake(self.selectIndex*lineWidth, CGRectGetHeight(self.frame)-2, lineWidth, 2);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
