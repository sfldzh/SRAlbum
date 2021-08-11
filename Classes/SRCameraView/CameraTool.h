//
//  CameraTool.h
//  SRAlbum
//
//  Created by 施峰磊 on 2021/8/3.
//  Copyright © 2021 施峰磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraTool : NSObject
+ (NSArray *)sortedArrayUsingComparator:list center:(CGPoint)center;

@end

NS_ASSUME_NONNULL_END
