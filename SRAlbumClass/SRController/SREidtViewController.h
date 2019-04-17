//
//  SREidtViewController.h
//  T
//
//  Created by 施峰磊 on 2019/3/15.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SREidtViewControllerDelegate <NSObject>

/**
 TODO:编辑图片完成

 @param image 图片
 */
- (void)imageEidtFinish:(UIImage *)image;

@end

@interface SREidtViewController : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<SREidtViewControllerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
