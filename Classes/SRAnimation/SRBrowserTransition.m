//
//  SRBrowserTransition.m
//  T
//
//  Created by 施峰磊 on 2019/3/7.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRBrowserTransition.h"
#import "SRAlbumBrowseViewController.h"
#import "PHAsset+Info.h"
#import "SRHelper.h"

@interface SRTransitionView : UIView
@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation SRTransitionView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (UIView *)backgroudView{
    if (!_backgroudView) {
        _backgroudView = [UIView new];
    }
    return _backgroudView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (void)initView {
    self.backgroundColor = UIColor.clearColor;
    [self addSubview:self.backgroudView];
    [self addSubview:self.imageView];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroudView.frame = self.bounds;
}
@end

@interface SRBrowserTransition () <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL isShow;
@end

#define k_transitionTime 0.4f

@implementation SRBrowserTransition

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _isShow = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _isShow = NO;
    return self;
}



- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return k_transitionTime;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (_isShow) {
        [self pushAnimation:transitionContext];
    } else {
        [self popAnimation:transitionContext];
    }
}


- (UIViewController *)analyticAccessViewController:(UIViewController *)source{
    UIViewController *vc;
    if ([source isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController *)source).topViewController;
    }else{
        vc = source;
    }
    return vc;
}

- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIViewController *fromVC = [self analyticAccessViewController:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]];
    SRAlbumBrowseViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    UIView *toBackView = [toVC.view viewWithTag:1001];
    toBackView.alpha = 0;
    UIView *containerView = transitionContext.containerView;
    [containerView addSubview:toVC.view];
    
    SRTransitionView *transitionView = [[SRTransitionView alloc] initWithFrame:containerView.bounds];
    __weak UIView *bgView = transitionView.backgroudView;
    bgView.alpha = 0.f;
    bgView.backgroundColor = [UIColor blackColor];
    
    __weak UIImageView *imageView = transitionView.imageView;
    imageView.image = toVC.asset.thumbnail;
    imageView.frame = toVC.clickeRect;
    [containerView addSubview:transitionView];
    
    CGSize imageSize = [SRHelper imageSizeByMaxSize:screenSize sourceSize:imageView.image.size];
    CGRect openFrame = CGRectMake((screenSize.width-imageSize.width)/2.0, (screenSize.height-imageSize.height)/2.0, imageSize.width, imageSize.height);
    [fromVC viewWillDisappear:YES];
    [UIView animateWithDuration:k_transitionTime delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:15.f options:UIViewAnimationOptionShowHideTransitionViews animations:^{
        imageView.frame = openFrame;
        bgView.alpha = 1.f;
    } completion:^(BOOL finished) {
        transitionView.hidden = YES;
        toBackView.alpha = 1.f;
        [transitionView removeFromSuperview];
        [transitionContext completeTransition:YES];
        [fromVC viewDidDisappear:finished];
    }];
}

- (void)popAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [self analyticAccessViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    SRAlbumBrowseViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromVC.view.alpha = 0.f;

    UIView *containerView = transitionContext.containerView;
    UIView *toBackView = [fromVC.view viewWithTag:1001];
    
    SRTransitionView *transitionView = [[SRTransitionView alloc] initWithFrame:containerView.bounds];
    transitionView.backgroudView.alpha = toBackView.alpha;
    transitionView.backgroudView.backgroundColor = [UIColor blackColor];
    transitionView.imageView.image = [fromVC currentImage];
    [containerView addSubview:transitionView];
    
    transitionView.imageView.frame = fromVC.imageRect;
    
    [toVC viewWillAppear:YES];
    [UIView animateWithDuration:k_transitionTime animations:^{
        transitionView.imageView.frame = fromVC.closeRect;
        transitionView.backgroudView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [transitionView removeFromSuperview];
        [transitionContext completeTransition:YES];
        [toVC viewDidAppear:finished];
    }];
}

@end
