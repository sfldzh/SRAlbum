//
//  SRHub.h
//  T
//
//  Created by 施峰磊 on 2019/3/13.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SRHubView;
@interface SRHub : NSObject
+ (SRHubView *)show;

+ (void)hidden:(SRHubView *)hub;

@end

@interface SRHubView : UIView
- (void)show;

- (void)hiddenView;
@end



NS_ASSUME_NONNULL_END
