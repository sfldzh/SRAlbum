//
//  SRVideoCaptureViewController.h
//  SRVideoCapture
//
//  Created by 施峰磊 on 2017/4/12.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol SRVideoCaptureViewControllerDelegate<NSObject>

/**
 TODO:拍照或者录像已经确定完成和选择

 @param content 照片或者视频地址
 @param isVedio 是否是视频
 */
- (void)videoCaptureViewDidFinishWithContent:(id)content isVedio:(BOOL)isVedio;
@end

@interface SRVideoCaptureViewController : UIViewController
@property (nonatomic, assign) NSUInteger    maxTime;
@property (nonatomic, assign) NSUInteger    type;//0:录像和拍照 1：拍照 2：录像
@property (nonatomic, weak) id<SRVideoCaptureViewControllerDelegate>delegate;


@end
