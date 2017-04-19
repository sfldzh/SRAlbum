//
//  SRPhotoBrowsViewController.m
//  SRAlbum
//
//  Created by danica on 2017/4/8.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRPhotoBrowsViewController.h"
#import "SRHeaderView.h"
#import "SRBrowseImageCollectionCell.h"
#import "SRAlbumHelper.h"
#import "SRAlbumData.h"

@interface SRPhotoBrowsViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,CAAnimationDelegate>
@property (nonatomic, strong) SRHeaderView                  *headerView;
@property (nonatomic, strong) UICollectionView              *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout    *layout;
@property (nonatomic, strong) UIView                        *toolView;
@property (nonatomic, strong) UILabel                       *numberLabel;
@property (nonatomic, strong) UIButton                      *finishButton;

@end

@implementation SRPhotoBrowsViewController

- (void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    [self addHeadView];
}

- (void)addHeadView{
    self.headerView.noStatue = YES;
    [self.headerView leftBtnSetImage:[UIImage imageNamed:@"SR_WhiteBack"] forState:UIControlStateNormal];
    [self.headerView rightBtnSetImage:[UIImage imageNamed:@"SRAlbum_no_selected"] forState:UIControlStateNormal];
    [self.headerView rightBtnSetImage:[UIImage imageNamed:@"SRAlbum_selected"] forState:UIControlStateSelected];
    [self.headerView leftBtnAddTarget:self selector:@selector(backViewController)];
    [self.headerView rightBtnAddTarget:self selector:@selector(selectAction)];
    [self.view addSubview:self.headerView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    [self addViews];
    [self checkIsSelected];
    [self setToolStatue];
}


- (void)addViews{
    [self.view insertSubview:self.collectionView belowSubview:self.headerView];
    [self.view addSubview:self.toolView];
    [self.toolView addSubview:self.numberLabel];
    [self.toolView addSubview:self.finishButton];
}

- (SRHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[SRHeaderView alloc] init];
        _headerView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    }
    return _headerView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        [self layoutSize];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.exclusiveTouch = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[SRBrowseImageCollectionCell class] forCellWithReuseIdentifier:@"SRBrowseImageCollectionCell"];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
    }
    return _layout;
}

- (UIView *)toolView{
    if (!_toolView) {
        _toolView = [[UIView alloc] init];
        _toolView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    }
    return _toolView;
}

- (UILabel *)numberLabel{
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:12];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.backgroundColor = [UIColor redColor];
        _numberLabel.hidden = YES;
        _numberLabel.layer.cornerRadius = 10;
        _numberLabel.layer.masksToBounds = YES;
    }
    return _numberLabel;
}

- (UIButton *)finishButton{
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(didClickFinish) forControlEvents:UIControlEventTouchUpInside];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _finishButton;
}

- (void)layoutSize{
    self.layout.itemSize = self.view.frame.size;
}

- (void)backViewController{
    [self.navigationController popViewControllerAnimated:YES];;
}

- (void)selectAction{
    if (ISIOS8) {
        PHAsset *phAsset = [self assetAtIndexPath:self.showIndexPath];
        [self selectOrDeleteWithData:phAsset];
    }else{
        ALAsset *alAsset = self.fetchAlResult[self.showIndexPath.row];
        [self selectOrDeleteWithData:alAsset];
    }
    [self setToolStatue];
}


/**
 TODO:设置工具栏的状态
 */
- (void)setToolStatue{
    self.finishButton.userInteractionEnabled = self.selectPics.count!=0;
    self.numberLabel.hidden = self.selectPics.count==0;
    self.numberLabel.text = [NSString stringWithFormat:@"%@",@(self.selectPics.count)];
    if (!self.numberLabel.hidden) {
        CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        popAnimation.delegate = self;
        popAnimation.duration = 0.6;
        popAnimation.values = @[@(1.0),@(1.25),@(0.95),@(1.1),@(1.0)];
        popAnimation.keyTimes = @[@(0.0),@(0.25),@(0.5),@(0.75),@(1.0)];
        popAnimation.calculationMode = kCAAnimationLinear;
        [self.numberLabel.layer addAnimation:popAnimation forKey:@"popAnimation"];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
    self.toolView.frame = CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 40);
    self.finishButton.frame = CGRectMake(CGRectGetWidth(self.toolView.frame)-60, 0, 50, CGRectGetHeight(self.toolView.frame));
    self.numberLabel.frame = CGRectMake(CGRectGetMinX(self.finishButton.frame)-20, CGRectGetHeight(self.toolView.frame)/2-10, 20, 20);
    [self layoutSize];
    if (_collectionView) {
        _collectionView.collectionViewLayout = self.layout;
    }
    [self.collectionView scrollToItemAtIndexPath:self.showIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  @author 施峰磊, 15-09-10 17:09:31
 *
 *  TODO:显示提示
 *
 *  @param message  提示消息
 *  @param tager    显示的地方
 *
 *  @since 1.0
 */
- (void)showAlertWithMessage:(NSString *)message tager:(UIViewController *)tager{
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleCancel) handler:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:cancelAction];
    [tager presentViewController:alertController animated:YES completion:nil];
}

/**
 TODO:删除或者添加到数值
 
 @param data 内容
 */
- (void)selectOrDeleteWithData:(id)data{
    if ([self.selectPics containsObject:data]) {
        if (self.selectPics.count <= [SRAlbumData singleton].maxItem) {
            [self.selectPics removeObject:data];
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectDidChangeIndexpath:)]) {
                [self.delegate selectDidChangeIndexpath:[NSIndexPath indexPathForRow:self.showIndexPath.row+1 inSection:0]];
            }
        }
    }else{
        if (self.selectPics.count < [SRAlbumData singleton].maxItem) {
            [self.selectPics addObject:data];
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectDidChangeIndexpath:)]) {
                [self.delegate selectDidChangeIndexpath:[NSIndexPath indexPathForRow:self.showIndexPath.row+1 inSection:0]];
            }

        }else{
            [self showAlertWithMessage:[NSString stringWithFormat:@"最多选取%@张图片",@([SRAlbumData singleton].maxItem)] tager:self];
        }
    }
    [self checkIsSelected];
}


/**
 TODO点击完成
 */
- (void)didClickFinish{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickFinishAction)]) {
        [self.delegate didClickFinishAction];
    }
}

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath{
    return (self.fetchResult.count > 0) ? self.fetchResult[indexPath.item] : nil;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.numberLabel.layer removeAnimationForKey:@"popAnimation"];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count;
    if (ISIOS8) {
        count = self.fetchResult.count;
    }else{
        count = self.fetchAlResult.count;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SRBrowseImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SRBrowseImageCollectionCell" forIndexPath:indexPath];
    if (ISIOS8) {
        PHAsset *phAsset = [self assetAtIndexPath:indexPath];
        cell.phAsset = phAsset;
    }else{
        ALAsset *alAsset = self.fetchAlResult[indexPath.row];
        cell.alAsset = alAsset;
    }
    return cell;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = (int)(scrollView.contentOffset.x/scrollView.frame.size.width);
    self.showIndexPath = [NSIndexPath indexPathForRow:page inSection:0];
    [self checkIsSelected];
}


/**
 TODO:检查是否选择
 */
- (void)checkIsSelected{
    if (ISIOS8) {
        PHAsset *phAsset = [self assetAtIndexPath:self.showIndexPath];
        [self.headerView changeRightBthSelect:[self.selectPics containsObject:phAsset]];
    }else{
        ALAsset *alAsset = self.fetchAlResult[self.showIndexPath.row];
        [self.headerView changeRightBthSelect:[self.selectPics containsObject:alAsset]];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
