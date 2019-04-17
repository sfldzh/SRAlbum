//
//  PromptManager.h
//  Car
//
//  Created by hlet on 2018/5/15.
//  Copyright © 2018年 hlet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SRPromptManager : NSObject
/**
 TODO:获取单例
 
 @return 单例
 */
+ (instancetype)single;

/**
 TODO:释放
 */
+ (void)freeData;

/**
 TODO:显示提示内容
 
 @param content 提示内容
 */
- (void)showContent:(NSString *)content;

/**
 TODO:显示提示内容
 
 @param message 提示内容
 */
+ (void)showMessage:(NSString *)message;

@end

@interface SRPromptAnimating : NSObject
@property (nonatomic, assign) CGAffineTransform dismissTransform;
@property (nonatomic, assign) CGAffineTransform showInitialTransform;
@property (nonatomic, assign) CGAffineTransform showFinalTransform;
@property (nonatomic, assign) CGFloat springDamping; //阻尼率
@property (nonatomic, assign) CGFloat springVelocity;//加速率
@property (nonatomic, assign) CGFloat showInitialAlpha;
@property (nonatomic, assign) CGFloat dismissFinalAlpha;
@property (nonatomic, assign) CGFloat showDuration;
@property (nonatomic, assign) CGFloat dismissDuration;
@end
