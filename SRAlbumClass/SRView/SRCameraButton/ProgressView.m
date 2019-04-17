//
//  ProgressView.m
//  SRVideoCapture
//
//  Created by 施峰磊 on 2017/4/12.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "ProgressView.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation ProgressView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.progressBarProgressColorForDrawing = [UIColor colorWithRed:53/255.0 green:202/255.0 blue:65/255.0 alpha:1.0];
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

- (void)setProgress:(float)progress{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawProgressBar:(CGContextRef)context progressAngle:(CGFloat)progressAngle center:(CGPoint)center radius:(CGFloat)radius {
    CGFloat barWidth = 5;
    if (barWidth > radius) {
        barWidth = radius;
    }
    
    CGContextSetFillColorWithColor(context, self.progressBarProgressColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(_startAngle), DEGREES_TO_RADIANS(progressAngle), 0);
    CGContextAddArc(context, center.x, center.y, radius - barWidth, DEGREES_TO_RADIANS(progressAngle), DEGREES_TO_RADIANS(_startAngle), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    //    CGContextSetFillColorWithColor(context, self.progressBarTrackColorForDrawing.CGColor);
    //    CGContextBeginPath(context);
    //    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(progressAngle), DEGREES_TO_RADIANS(_startAngle + 360), 0);
    //    CGContextAddArc(context, center.x, center.y, radius - barWidth, DEGREES_TO_RADIANS(_startAngle + 360), DEGREES_TO_RADIANS(progressAngle), 1);
    //    CGContextClosePath(context);
    //    CGContextFillPath(context);
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGPoint innerCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(innerCenter.x, innerCenter.y);
    CGFloat currentProgressAngle = (_progress * 360) + _startAngle;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [self drawProgressBar:context progressAngle:currentProgressAngle center:innerCenter radius:radius];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
