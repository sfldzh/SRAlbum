//
//  SRHeaderView.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRHeaderView : UIView
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL      noStatue;

- (void)leftBtnSetTitle:(NSString *)title forState:(UIControlState)state;
- (void)leftBtnSetImage:(UIImage *)image forState:(UIControlState)state;
- (void)leftBtnAddTarget:(id)target selector:(SEL)selector;

- (void)rightBtnSetTitle:(NSString *)title forState:(UIControlState)state;
- (void)rightBtnSetImage:(UIImage *)image forState:(UIControlState)state;
- (void)rightBtnAddTarget:(id)target selector:(SEL)selector;

- (void)changRightBtnEnable:(BOOL)enable;
- (void)changeRightBthSelect:(BOOL)select;

@end
