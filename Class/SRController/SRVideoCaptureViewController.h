//
//  SRVideoCaptureViewController.h
//  T
//
//  Created by 施峰磊 on 2019/3/13.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@protocol SRVideoCaptureViewControllerDelegate <NSObject>

- (void)captureFinish:(id)content;

@end

@interface SRVideoCaptureViewController : UIViewController
@property (nonatomic, weak) id<SRVideoCaptureViewControllerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
