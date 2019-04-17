//
//  SREidtViewController.m
//  T
//
//  Created by 施峰磊 on 2019/3/15.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SREidtViewController.h"

@interface SREidtViewController ()
@property (weak, nonatomic) IBOutlet UIButton *rotateButton;
@property (weak, nonatomic) IBOutlet UIButton *horizontalButton;
@property (weak, nonatomic) IBOutlet UIButton *verticallyButton;
@property (weak, nonatomic) IBOutlet UIButton *tailoringButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;

@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@end

@implementation SREidtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addViews];
    if (@available(iOS 11.0,*)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)addViews{
    CGFloat top = [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.top.constant += top;
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:self.image make:^(JPImageresizerConfigure *configure) {
        configure.jp_contentInsets(UIEdgeInsetsMake(self.top.constant+44+10, 0, (20 + 50 + 20), 0));
    }];
    
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
    
    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {

    }];
    imageresizerView.frameType = JPConciseFrameType;
    [self.view insertSubview:imageresizerView atIndex:0];
    self.imageresizerView = imageresizerView;
}

- (IBAction)popAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rotateAction:(UIButton *)sender {
    [self.imageresizerView rotation];
}

- (IBAction)verticallyAction:(UIButton *)sender {
    [self.imageresizerView setVerticalityMirror:!self.imageresizerView.verticalityMirror animated:YES];
}

- (IBAction)horizontalAction:(UIButton *)sender {
    [self.imageresizerView setHorizontalMirror:!self.imageresizerView.horizontalMirror animated:YES];
}

- (IBAction)resetAction:(UIButton *)sender {
    [self.imageresizerView recovery];
}

- (IBAction)tailoringAction:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imageEidtFinish:)]) {
            [weakSelf.delegate imageEidtFinish:resizeImage];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
