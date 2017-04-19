//
//  SRCameraButton.h
//  SRVideoCapture
//
//  Created by 施峰磊 on 2017/4/12.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SRCameraButtonDelegate<NSObject>

/**
 TODO:拍照按钮点击

 @param isVideotape 是否是录像
 @param isStart 是否开始录像
 */
- (void)didClickCameraButtonIsVideotape:(BOOL)isVideotape isStart:(BOOL)isStart;
@end

@interface SRCameraButton : UIControl

@property (nonatomic, weak) id<SRCameraButtonDelegate>delegate;
@property (nonatomic) float progress;
@end
