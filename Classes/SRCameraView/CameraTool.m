//
//  CameraTool.m
//  SRAlbum
//
//  Created by 施峰磊 on 2021/8/3.
//  Copyright © 2021 施峰磊. All rights reserved.
//

#import "CameraTool.h"


@implementation CameraTool

+ (NSArray *)sortedArrayUsingComparator:list center:(CGPoint)center{
    NSNumber *(^angleFromPoint)(id) = ^(NSValue *value){
        CGPoint point = [value CGPointValue];
        CGFloat theta = atan2f(point.y - center.y, point.x - center.x);
        CGFloat angle = fmodf(M_PI - M_PI_4 + theta, 2 * M_PI);
        return @(angle);
    };
    return [list sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [angleFromPoint(obj1) compare:angleFromPoint(obj2)];
    }];
}

@end
