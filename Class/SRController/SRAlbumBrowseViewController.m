//
//  SRAlbumBrowseViewController.m
//  T
//
//  Created by 施峰磊 on 2019/3/6.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRAlbumBrowseViewController.h"
#import "SRBrowseCollectionViewCell.h"
#import "SRBrowserTransition.h"
#import "SRAlbumConfiger.h"
#import "SRPromptManager.h"

@interface SRAlbumBrowseViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SRBrowseCollectionViewCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBottom;
@property (weak, nonatomic) IBOutlet UIButton *compressButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *toolView;

@property (nonatomic, strong) SRBrowserTransition *transition;
@property (nonatomic, assign) BOOL isScrollered;
@property (nonatomic, assign) BOOL isHiddenStatue;
@property (nonatomic, assign) BOOL isShowNavigation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *naveigationTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statuHeight;
@end

@implementation SRAlbumBrowseViewController

- (instancetype)init{
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData{
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.transitioningDelegate = self.transition;
    self.isShowNavigation = YES;
}


- (SRBrowserTransition *)transition{
    if (!_transition) {
        _transition = [SRBrowserTransition new];
    }
    return _transition;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
    [self configerView];
    [self checkSelects];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


- (void)setAssetType:(SRAssetType)assetType{
    _assetType = assetType;
    if (self.delegate && [self.delegate respondsToSelector:@selector(setAlbumAssetType:)]) {
        [self.delegate setAlbumAssetType:assetType];
    }
}

- (void)checkSelects{
    self.sendButton.enabled = self.selecteds.count != 0;
    self.sendButton.backgroundColor = self.sendButton.enabled?[UIColor colorWithRed:16/255.0 green:189/255.0 blue:40/255.0 alpha:1.0]:[UIColor colorWithRed:7/255.0 green:86/255.0 blue:19/255.0 alpha:1.0];
    [self.sendButton setTitle:self.sendButton.enabled?[NSString stringWithFormat:@"发送(%@)",@(self.selecteds.count)]:@"发送" forState:UIControlStateNormal];
}

- (IBAction)didClickCompress:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(setFileCompress:)]) {
        [self.delegate setFileCompress:sender.selected];
    }
}

- (IBAction)didClickSend:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSendAction)]) {
        [self.delegate didClickSendAction];
    }
    
}

- (IBAction)didClickDismiss:(UIButton *)sender {
    SRBrowseCollectionViewCell *cell = (SRBrowseCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.showIndexPath];
    _imageRect = [cell getCurrentImageFrame];
    [self didSwipeClose];
}


- (IBAction)didClickSelected:(UIButton *)sender {
    PHAsset *asset = [self.assetList objectAtIndex:self.showIndexPath.row];
    [self didOperationAction:asset];
    [self checkSelects];
}

- (void)didOperationAction:(PHAsset *)data{
    //没有选择过或者同类型的可以操作
    if (self.assetType == [data assetType] || self.assetType == SRAssetTypeNone) {
        if ([self.selecteds containsObject:data]) {
            [self.selecteds removeObject:data];
            if (self.selecteds.count == 0)self.assetType = [SRAlbumConfiger singleton].assetType;
        }else{
            if (self.selecteds.count == 0)self.assetType = [data ctassetsPickerIsPhoto]?SRAssetTypePic:SRAssetTypeVideo;
            if (self.selecteds.count < [SRAlbumConfiger singleton].maxItem) {//判断最多选择的数量
                [self.selecteds addObject:data];
            }else{
                [[SRPromptManager single] showContent:[NSString stringWithFormat:@"最多选择%@个！您已经不可以再选择了。",@([SRAlbumConfiger singleton].maxItem)]];
            }
        }
        [self checkSelected];
    }else{
        [[SRPromptManager single] showContent:self.assetType == SRAssetTypePic?@"不能选择视频":@"不能选择图片"];
    }
}

/**
 TODO:检测选择状态
 */
- (void)checkSelected{
    PHAsset *asset = [self.assetList objectAtIndex:self.showIndexPath.row];
    self.selectedButton.selected = [self.selecteds containsObject:asset];
}

- (void)showBar:(BOOL)show{
    self.isShowNavigation = show;
    [UIView animateWithDuration:0.25 animations:^{
        self.naveigationTop.constant = show?0:-(self.statuHeight.constant + 44);
        self.toolBottom.constant = show?0:-self.toolHeight.constant;
        [self.view layoutIfNeeded];
    }];
    
   
    self.isHiddenStatue = !show;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)scrollerToIndex{
    if (!self.isScrollered) {
        self.isScrollered = YES;
        NSInteger index = [self.assetList indexOfObject:self.asset];
        self.showIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:self.showIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)configerView{
    if (@available(iOS 11.0, *)) {
        CGFloat bottom = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        self.toolHeight.constant += bottom;
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;  
    }else{
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    self.statuHeight.constant = [[UIApplication sharedApplication] statusBarFrame].size.height;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.exclusiveTouch = YES;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *))_collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SRBrowseCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SRBrowseCollectionViewCell"];
    self.selectedButton.selected = [self.selecteds containsObject:self.asset];
    self.compressButton.selected = self.isCompress;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self scrollerToIndex];
}

/**
 TODO:获取当前的图片
 
 @return 图片
 */
- (UIImage *)currentImage{
    SRBrowseCollectionViewCell *cell = (SRBrowseCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.showIndexPath];
    return [cell currentImage];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = (int)(scrollView.contentOffset.x/scrollView.frame.size.width);
    self.showIndexPath = [NSIndexPath indexPathForRow:page inSection:0];
    [self checkSelected];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assetList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SRBrowseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SRBrowseCollectionViewCell" forIndexPath:indexPath];
    cell.asset = [self.assetList objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.backView = self.backView;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [(SRBrowseCollectionViewCell *)cell stopPlay];
}

#pragma mark - SRBrowseCollectionViewCellDelegate
/**
 TODO:关闭相册浏览器
 */
- (void)didSwipeClose{
    if (self.delegate && [self.delegate respondsToSelector:@selector(willBeginCloseAnimationRect:)]) {
        _closeRect = [self.delegate willBeginCloseAnimationRect:self.showIndexPath];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 TODO:获取当前图片的frame
 
 @param frame 当前图片的frame
 */
- (void)currentImageFrame:(CGRect)frame{
    _imageRect = frame;
}

/**
 TODO:将要滑动关闭
 */
- (void)willSwipeClose{
    if (!self.isShowNavigation) {
        self.isHiddenStatue = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    self.navigationView.hidden = YES;
    self.toolView.hidden = YES;
}

/**
 TODO:取消滑动关闭
 */
- (void)cancelSwipeClose{
    if (!self.isShowNavigation) {
        self.isHiddenStatue = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    self.navigationView.hidden = NO;
    self.toolView.hidden = NO;
}


/**
 TODO:点击获取导航栏
 */
- (void)didClickBar{
    [self showBar:!self.isShowNavigation];
}


- (BOOL)prefersStatusBarHidden {
    return self.isHiddenStatue;
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
