//
//  EffectView.m
//  SRVideoCapture
//
//  Created by 施峰磊 on 2017/4/12.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "EffectView.h"

@implementation EffectView

- (instancetype)initWithEffect:(UIVisualEffect *)effect{
    self = [super initWithEffect:effect];
    if (self) {
        
//        self.progressBarTrackColorForDrawing = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }else{
        return hitView;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
