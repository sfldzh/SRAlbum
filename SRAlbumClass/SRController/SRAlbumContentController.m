//
//  SRAlbumContentController.m
//  T
//
//  Created by 施峰磊 on 2019/3/4.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRAlbumContentController.h"
#import "ImageCollectionViewCell.h"
#import "UICollectionView+Info.h"
#import "PhotoInfoModel.h"
#import "SRAlbumConfiger.h"
#import "SRHelper.h"
#import "SRPromptManager.h"
#import "SRAlbumBrowseViewController.h"
#import "SRBrowserTransition.h"
#import "SREidtViewController.h"

#import "SRHub.h"

@interface SRAlbumContentController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ImageCollectionViewCellDelegate,SRAlbumBrowseViewControllerDelegate,SREidtViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *compressButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBottom;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) CGFloat interval;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) NSMutableArray *selecteds;
@property (nonatomic, assign) SRAssetType assetType;
@property (nonatomic, assign) BOOL isScrollered;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL isFirstShow;

@property (nonatomic, strong) SRBrowserTransition *transition;
@end

@implementation SRAlbumContentController

- (void)dealloc{
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.transitioningDelegate = self.transition;
    }
    return self;
}

- (NSMutableArray *)selecteds{
    if (!_selecteds) {
        _selecteds = [NSMutableArray arrayWithCapacity:0];
    }
    return _selecteds;
}


- (SRBrowserTransition *)transition{
    if (!_transition) {
        _transition = [SRBrowserTransition new];
    }
    return _transition;
}


/**
 TODO:获取相册内容
 */
- (void)loadAlbumData{
    if (self.assetCollection) {
        self.fetchResult = self.assetCollection.assets;
        self.isLoaded = YES;
    }else{
        SRHubView *hub;
        if (!self.isLoaded)hub = [SRHub show];
        [SRHelper fetchAlbumsOption:0 contentBlock:^(PHFetchResult * _Nonnull content, BOOL success) {
            self.fetchResult = content;
            [self loadViewIfNeeded];
            if (hub)[SRHub hidden:hub];
            self.isLoaded = YES;
            [self.collectionView reloadData];
        }];
    }
}


- (UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc]init];
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _layout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initData];
    [self configerView];
    [self loadAlbumData];
    [self checkSelects];
}

- (void)setAssetCollection:(PHAssetCollection *)assetCollection{
    _assetCollection = assetCollection;
    if (self.isLoaded) {
        self.assetType = [SRAlbumConfiger singleton].assetType;
        [self.selecteds removeAllObjects];
        [self loadAlbumData];
        [self checkSelects];
        [self.collectionView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isFirstShow) {
        self.isFirstShow = NO;
    }else{
        [self.collectionView reloadData];
        [self checkSelects];
    }
}

- (void)collectionViewScrollToBottom{
    if (!self.isScrollered && self.fetchResult.count>0) {
        self.isScrollered = YES;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.fetchResult.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)initData{
    self.isFirstShow = YES;
    self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.interval = 2;
    self.columnNumber = 4;
    self.assetType = [SRAlbumConfiger singleton].assetType;
}

- (void)configerView{
    if (@available(iOS 11.0, *)) {
        CGFloat bottom = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        self.toolBottom.constant += bottom;
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;  
    }else{
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = self.assetCollection == nil?@"所有照片":self.assetCollection.localizedTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.collectionView.collectionViewLayout = self.layout;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)checkSelects{
    self.sendButton.enabled = self.selecteds.count != 0;
    self.sendButton.backgroundColor = self.sendButton.enabled?[UIColor colorWithRed:16/255.0 green:189/255.0 blue:40/255.0 alpha:1.0]:[UIColor colorWithRed:7/255.0 green:86/255.0 blue:19/255.0 alpha:1.0];
    [self.sendButton setTitle:self.sendButton.enabled?[NSString stringWithFormat:@"发送(%@)",@(self.selecteds.count)]:@"发送" forState:UIControlStateNormal];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self collectionViewScrollToBottom];
}

- (IBAction)didClickCompress:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)didClickSend:(UIButton *)sender {
    [self finishAsset];
}


- (void)finishAsset{
    SRHubView *hub = [SRHub show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.assetType==SRAssetTypePic) {
            [self getPhotos];
        }else{
            [self getVedios];
        }
        [SRHub hidden:hub];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}


/**
 TODO:图片获取
 */
- (void)getPhotos{
    NSMutableArray *images = [NSMutableArray arrayWithArray:self.selecteds];
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    //是否压缩
    BOOL iscompress = !self.compressButton.selected;
    
    for (PHAsset *asset in self.selecteds) {
        dispatch_group_async(group, quene, ^{
            if ([asset isGif]) {
                if (asset.showData) {
                    [images replaceObjectAtIndex:[self.selecteds indexOfObject:asset] withObject:asset.showData];
                }else{
                    [SRHelper requestOriginalImageDataForAsset:asset completion:^(NSData * imageData, NSDictionary * dic) {
                        asset.showData = imageData;
                        [images replaceObjectAtIndex:[self.selecteds indexOfObject:asset] withObject:asset.showData];
                    }];
                }
            }else{
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                // 同步获得图片
                options.synchronous = YES;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    if (([SRAlbumConfiger singleton].maxlength != 0 && [SRAlbumConfiger singleton].maxlength < imageData.length) && iscompress) {
                        UIImage *compressImage = [SRHelper compressImage:image toByte:[SRAlbumConfiger singleton].maxlength];
                        [images replaceObjectAtIndex:[self.selecteds indexOfObject:asset] withObject:compressImage];
                    }else{
                        [images replaceObjectAtIndex:[self.selecteds indexOfObject:asset] withObject:image];
                    }
                }];
            }
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishAlbumContentPickingImages:)]) {
            [self.delegate didFinishAlbumContentPickingImages:images];
        }
    });
}


- (void)getVedios{
    NSMutableArray *vedios = [NSMutableArray arrayWithCapacity:0];
    dispatch_semaphore_t signal = dispatch_semaphore_create(0);
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    for (PHAsset *asset in self.selecteds) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                [SRHelper compressedVideo:(AVURLAsset*)asset completionHandler:^(AVAssetExportSession *exportSession, NSURL *path) {
                    switch (exportSession.status) {
                        case AVAssetExportSessionStatusCompleted:
                            [vedios addObject:path];
                            break;
                        default:
                            
                            break;
                    }
                    dispatch_semaphore_signal(signal);
                }];
            } else if ([asset isKindOfClass:[AVComposition class]]){
                [SRHelper compressedVideoCompositionWithComposition:(AVComposition*)asset CompletionHandler:^(AVAssetExportSession * _Nonnull exportSession, NSURL * _Nonnull path) {
                    switch (exportSession.status) {
                        case AVAssetExportSessionStatusCompleted:
                            [vedios addObject:path];
                            break;
                        default:
                            
                            break;
                    }
                    dispatch_semaphore_signal(signal);
                }];
            }
        }];
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishAlbumContentPickingVedios:)]) {
        [self.delegate didFinishAlbumContentPickingVedios:vedios];
    }
}


#pragma mark - ImageCollectionViewCellDelegate
/**
 TODO:操作事件
 
 @param data 资源数据
 */
- (void)didOperationAction:(PHAsset *)data{
    if ([SRAlbumConfiger singleton].isEidt && [SRAlbumConfiger singleton].assetType == SRAssetTypePic) {//编辑图片
        if ([data ctassetsPickerIsPhoto]) {//是图片编辑
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            // 同步获得图片, 只会返回1张图片
            options.synchronous = YES;
            options.networkAccessAllowed = YES;
            SRHubView *hub = [SRHub show];
            [[PHImageManager defaultManager] requestImageDataForAsset:data options:options resultHandler:^(NSData * _Nullable imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                [SRHub hidden:hub];
                UIImage *image = [UIImage imageWithData:imageData];
                SREidtViewController *vc = [[SREidtViewController alloc] initWithNibName:@"SREidtViewController" bundle:nil];
                vc.delegate = self;
                vc.image = image;
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }
    }else{
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
                    NSLog(@"超过了");
                }
            }
            [self checkSelects];
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - SREidtViewControllerDelegate
/**
 TODO:编辑图片完成
 
 @param image 图片
 */
- (void)imageEidtFinish:(UIImage *)image{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishAlbumContentPickingImages:)]) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        if ([SRAlbumConfiger singleton].maxlength != 0 && [SRAlbumConfiger singleton].maxlength < imageData.length) {//如果图片这压缩
            [self.delegate didFinishAlbumContentPickingImages:@[[SRHelper compressImage:image toByte:[SRAlbumConfiger singleton].maxlength]]];
        }else{
            [self.delegate didFinishAlbumContentPickingImages:@[image]];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width =((CGRectGetWidth(collectionView.frame)- (self.columnNumber-1)*self.interval - self.edgeInsets.left - self.edgeInsets.right)/self.columnNumber)-1;
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return self.interval;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return self.interval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return self.edgeInsets;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    PHAsset *phAsset = [self.fetchResult objectAtIndex:indexPath.row];
    cell.photoData = phAsset;
    if (self.assetType == SRAssetTypeNone) {
        cell.selectType = SRSelectTypeNOSelection;
    }else if (self.assetType == SRAssetTypePic) {
        cell.selectType = [phAsset ctassetsPickerIsPhoto]?([self.selecteds containsObject:phAsset]?SRSelectTypeSelection:SRSelectTypeNOSelection):SRSelectTypeNone;
    } else {
        cell.selectType = [phAsset ctassetsPickerIsPhoto] == NO?([self.selecteds containsObject:phAsset]?SRSelectTypeSelection:SRSelectTypeNOSelection):SRSelectTypeNone;
    }
    if ([self.selecteds containsObject:phAsset]) {
        cell.selectIndex = [self.selecteds indexOfObject:phAsset]+1;
    }
    cell.delegate = self;
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *phAsset = [self.fetchResult objectAtIndex:indexPath.row];
    if ([SRAlbumConfiger singleton].isEidt && [SRAlbumConfiger singleton].assetType == SRAssetTypePic) {//编辑图片
        if ([phAsset ctassetsPickerIsPhoto]) {//是图片编辑
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            // 同步获得图片, 只会返回1张图片
            options.synchronous = YES;
            options.networkAccessAllowed = YES;
            SRHubView *hub = [SRHub show];
            [[PHImageManager defaultManager] requestImageDataForAsset:phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                [SRHub hidden:hub];
                UIImage *image = [UIImage imageWithData:imageData];
                SREidtViewController *vc = [[SREidtViewController alloc] initWithNibName:@"SREidtViewController" bundle:nil];
                vc.delegate = self;
                vc.image = image;
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }
    }else{
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        SRAlbumBrowseViewController *vc = [[SRAlbumBrowseViewController alloc] initWithNibName:@"SRAlbumBrowseViewController" bundle:nil];
        vc.delegate = self;
        vc.assetType = self.assetType;
        vc.clickeRect = [self.collectionView convertRect:cell.frame toView:self.view];
        vc.assetList = self.fetchResult;
        vc.asset = phAsset;
        vc.selecteds = self.selecteds;
        vc.isCompress = self.compressButton.selected;
        [self presentViewController:vc animated:YES completion:nil];
    }
}


#pragma mark - SRAlbumBrowseViewControllerDelegate

/**
 TODO:关闭获取前一个页面的frame
 
 @param indexPath 序号索引
 @return 前一个页面的frame
 */
- (CGRect)willBeginCloseAnimationRect:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    //cell在当前屏幕的位置
    CGRect rect = [self.collectionView convertRect:cell.frame toView:self.view];
    return rect;
}


/**
 TODO:设置相册资源类型
 
 @param assetType 资源类型
 */
- (void)setAlbumAssetType:(SRAssetType)assetType{
    self.assetType = assetType;
}


/**
 TODO:设置图片或者视频压缩
 
 @param isCompress 是否压缩
 */
- (void)setFileCompress:(BOOL)isCompress{
    self.compressButton.selected = isCompress;
}

/**
 TODO:点击发送
 */
- (void)didClickSendAction{
    [self finishAsset];
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
