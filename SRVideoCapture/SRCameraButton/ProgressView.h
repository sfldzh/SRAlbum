//
//  ProgressView.h
//  SRVideoCapture
//
//  Created by 施峰磊 on 2017/4/12.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView
@property (nonatomic) float progress;
@property(nonatomic, strong) UIColor *progressBarProgressColorForDrawing;
@property (nonatomic) IBInspectable CGFloat startAngle;
@end
