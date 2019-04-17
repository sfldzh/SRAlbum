//
//  UICollectionView+Info.m
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "UICollectionView+Info.h"
#import <objc/runtime.h>

@implementation UICollectionView (Info)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(didMoveToWindow);
        SEL swizzledSelector = @selector(didSRMoveToWindow);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL didAddMethod=class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }else{
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)didSRMoveToWindow{
    [self didSRMoveToWindow];
    self.isShowed = self.window != nil;
}

- (void)setIsShowed:(BOOL)isShowed{
     objc_setAssociatedObject(self, @selector(isShowed), @(isShowed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isShowed{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
