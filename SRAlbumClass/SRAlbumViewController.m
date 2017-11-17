//
//  SRAlbumViewController.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRAlbumViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SRHeaderView.h"
#import "SRAlbumImageCollectionViewCell.h"
#import "SRCameraView.h"
#import "SRAlbumHelper.h"

#import "SRPhotoBrowsViewController.h"//浏览器
#import "SRVideoCaptureViewController.h"//拍摄拍照
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>

#import "MBProgressHUD.h"


@interface SRAlbumViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
@property(nonatomic,weak) UIViewController* currentShowVC;
@end

@implementation SRAlbumViewController
- (void)dealloc{
    [SRAlbumData freeData];
}

- (instancetype)init{
    self = [super initWithRootViewController:[[SRAlbumController alloc] init]];
    if (self) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.navigationBarHidden = YES;
        [self initData];
    }
    return self;
}

- (void)initData{
    self.maxItem = 1;
    self.videoMaximumDuration = 15;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)setResourceType:(NSInteger)resourceType{
    _resourceType = resourceType;
    [SRAlbumData singleton].resourceType = resourceType;
}

- (void)setMaxItem:(NSUInteger)maxItem{
    _maxItem = maxItem;
    [SRAlbumData singleton].maxItem = maxItem;
}

- (void)setVideoMaximumDuration:(NSUInteger)videoMaximumDuration{
    _videoMaximumDuration = videoMaximumDuration;
    [SRAlbumData singleton].videoMaximumDuration = videoMaximumDuration;
}

- (void)setIsCanShot:(BOOL)isCanShot{
    [SRAlbumData singleton].isCanShot = isCanShot;
}

- (void)setAlbumDelegate:(id<SRAlbumControllerDelegate>)albumDelegate{
    //    _albumDelegate = albumDelegate;
    [SRAlbumData singleton].albumDelegate = albumDelegate;
}

- (void)setEidtClass:(Class)eidtClass{
    [SRAlbumData singleton].eidtClass = eidtClass;
}
- (void)setEidtSourceName:(NSString *)eidtSourceName{
    [SRAlbumData singleton].eidtSourceName = eidtSourceName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  @author 施峰磊, 15-07-10 14:07:56
 *
 *  TODO:重写系统push方法，防止push过程中返回crash
 *
 *  @param viewController 控制器
 *  @param animated 是否动画
 *
 *  @since 1.0
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // fix 'nested pop animation can result in corrupted navigation bar'
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
}


-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (navigationController.viewControllers.count == 1)
        self.currentShowVC = Nil;
    else
        self.currentShowVC = viewController;
    
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}


-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return (self.currentShowVC == self.topViewController); //the most important
    }
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
@interface SRAlbumController ()<UICollectionViewDelegate,UICollectionViewDataSource,ImageCollectionViewCellDelegate,SRPhotoBrowsViewControllerDelegate,SRVideoCaptureViewControllerDelegate,PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) SRHeaderView                  *headerView;
@property (nonatomic, strong) UICollectionView              *collectionView;
@property (nonatomic, assign) NSInteger                     columnNumber;

@property (nonatomic, strong) PHFetchResult                 *fetchResult;
@property (nonatomic, strong) NSMutableArray                *fetchAlResult;
@property (nonatomic, strong) UICollectionViewFlowLayout    *layout;
@property (nonatomic, strong) NSMutableArray                *selectPics;//选择的图片
@property (nonatomic, assign) BOOL                          selectIng;

@property (nonatomic, strong) MBProgressHUD                 *progressHud;
@end

@implementation SRAlbumController

- (void)dealloc{
    if (ISIOS8) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    }
}

- (void)loadView{
    [super loadView];
    [self addHeadView];
}

- (void)addHeadView{
    self.headerView.title = [SRAlbumData singleton].resourceType==0?@"所有内容":[SRAlbumData singleton].resourceType==2?@"所有视频":@"所有照片";
    [self.headerView leftBtnSetImage:[UIImage imageNamed:@"SR_Back"] forState:UIControlStateNormal];
    [self.headerView changRightBtnEnable:NO];
    [self.headerView leftBtnAddTarget:self selector:@selector(backViewController)];
    
    if ([SRAlbumData singleton].resourceType != 2) {
        [self.headerView rightBtnSetTitle:@"下一步" forState:UIControlStateNormal];
        [self.headerView rightBtnAddTarget:self selector:@selector(nextOperation)];
    }
    [self.view addSubview:self.headerView];
}

- (SRHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[SRHeaderView alloc] init];
    }
    return _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self addView];
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


/**
 TODO:初始化数据
 */
- (void)initData{
    self.selectPics = [NSMutableArray arrayWithCapacity:0];
    self.columnNumber = 4;
    [self getAlbumDatasByCamera:NO contentBlock:nil];
}


- (void)addNotification{
    if (ISIOS8) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryDidChange) name:ALAssetsLibraryChangedNotification object:nil];
    }
}

- (void)assetsLibraryDidChange{
    NSLog(@"相册改变");
}

/**
 TODO:获取相册的内容
 */
- (void)getAlbumDatasByCamera:(BOOL)isCamera contentBlock:(void(^)(BOOL success))contentBlock{
    //    typeof(self) __weak weakSelf = self;
    [SRAlbumHelper fetchAlbumsOption:[SRAlbumData singleton].resourceType contentBlock:^(id content, BOOL success) {
        if (success) {
            if (ISIOS8) {
                self.fetchResult = content;
                if(isCamera){
                    [self.selectPics addObject:[self assetAtIndexPath:0]];
                    [self changeRightButtonStatu];
                }
            }else{
                self.fetchAlResult = content;
                if(isCamera){
                    [self.selectPics addObject:self.fetchAlResult[0]];
                    [self changeRightButtonStatu];
                }
            }
            [self.collectionView reloadData];
        }
        if (contentBlock) {
            contentBlock(success);
        }
    }];
}

- (void)addView{
    [self.view addSubview:self.collectionView];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        CGFloat margin = 5;
        [self layoutSize];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.bounces = YES;
        _collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
        [_collectionView registerClass:[SRAlbumImageCollectionViewCell class] forCellWithReuseIdentifier:@"SRAlbumImageCollectionViewCell"];
        [_collectionView registerClass:[SRCameraView class] forCellWithReuseIdentifier:@"SRCameraView"];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _layout;
}

- (void)layoutSize{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat margin = 5;
    CGFloat itemWH = (size.width - (self.columnNumber + 1) * margin) / self.columnNumber;
    self.layout.itemSize = CGSizeMake(itemWH, itemWH);
    self.layout.minimumInteritemSpacing = margin;
    self.layout.minimumLineSpacing = margin;
}

- (void)backViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextOperation{
    [self showLoadingWithMessage:@"图片处理中..."];
    [self performSelector:@selector(getimages) withObject:nil afterDelay:0];
}


/**
 TODO:获取图片
 */
- (void)getimages{
    __block NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    for (PHAsset * asset in self.selectPics) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.networkAccessAllowed = YES;
        options.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(imageSize.width, imageSize.height ) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            [images addObject:result];
            if (images.count == self.selectPics.count) {
                [self hideHUB];
                [self didSelectedFiles:images isVedio:NO];
            }
        }];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGSize size = [[UIScreen mainScreen] bounds].size;
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), size.width, size.height-CGRectGetMaxY(self.headerView.frame));
    [self layoutSize];
    if (_collectionView) {
        _collectionView.collectionViewLayout = self.layout;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PHAsset *)assetAtIndexPath:(NSInteger )index{
    return (self.fetchResult.count > index) ? self.fetchResult[index] : nil;
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


- (void)showSheetWithMessage:(NSString *)message firstTitle:(NSString *)firstTitle secondTitle:(NSString *)secondTitle tager:(UIViewController *)tager firstHandler:(void (^ __nullable)(UIAlertAction *action))firstHandler secondHandler:(void (^ __nullable)(UIAlertAction *action))secondHandler{
    UIAlertAction *selectAction = [UIAlertAction actionWithTitle:firstTitle style:UIAlertActionStyleDefault handler:firstHandler];
    UIAlertAction *browsAction = [UIAlertAction actionWithTitle:secondTitle style:UIAlertActionStyleDefault handler:secondHandler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:selectAction];
    [alertController addAction:cancelAction];
    [alertController addAction:browsAction];
    [tager presentViewController:alertController animated:YES completion:nil];
}

/**
 *    @author 施峰磊, 16-06-01 10:06:27
 *
 *    TODO:显示加载信息
 *
 *    @param message    加载信息
 *
 *    @since 1.0
 */
- (void)showLoadingWithMessage:(NSString *)message{
    if (self.progressHud.superview ||self.progressHud) {
        [self.progressHud hideAnimated:NO];
    }
    self.progressHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.progressHud.label.text = message;
}

/**
 *    @author 施峰磊, 16-06-01 10:06:03
 *
 *    TODO:隐藏
 *
 *    @since 1.0
 */
- (void)hideHUB{
    [self.progressHud hideAnimated:NO];
}


/**
 TODO:拍照或者录像
 */
- (void)openVideoCaptureView {
    //权限检测
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus micStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if ((micStatus == AVAuthorizationStatusRestricted || micStatus ==AVAuthorizationStatusDenied) && iOS7Later&&[SRAlbumData singleton].resourceType != 1) {
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        NSString *message = [NSString stringWithFormat:@"请在设置中%@允许使用您的麦克风",appName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"相机无法使用" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (ISIOS8) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            } else {
                NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
                if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                    [[UIApplication sharedApplication] openURL:privacyUrl];
                } else {
                    [self showAlertWithMessage:@"不能跳转到设置页，请自行前往，谢谢" tager:self];
                }
            }
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"取消");
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) && iOS7Later) {
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        NSString *message = [NSString stringWithFormat:@"请在设置中%@允许使用您的相机",appName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"相机无法使用" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (ISIOS8) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            } else {
                NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
                if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                    [[UIApplication sharedApplication] openURL:privacyUrl];
                } else {
                    [self showAlertWithMessage:@"不能跳转到设置页，请自行前往，谢谢" tager:self];
                }
            }
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"取消");
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else { // 调用相机
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            SRVideoCaptureViewController *viewController = [[SRVideoCaptureViewController alloc] init];
            viewController.type = [SRAlbumData singleton].resourceType;
            viewController.delegate = self;
            viewController.maxTime = [SRAlbumData singleton].videoMaximumDuration;
            viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }
}

/**
 TODO:文件已经选择好了
 
 @param files 文件
 @param isVedio 是否是视频
 */
- (void)didSelectedFiles:(id)files isVedio:(BOOL)isVedio{
    if (isVedio) {
        [self showLoadingWithMessage:@"视频压缩中..."];
        [self vedioCompressWithAsset:files contentBlock:^(BOOL success, NSURL *path) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([SRAlbumData singleton].albumDelegate && [[SRAlbumData singleton].albumDelegate respondsToSelector:@selector(srAlbumDidSeletedFinishWithContent:isVedio:viewController:)]) {
                    [[SRAlbumData singleton].albumDelegate srAlbumDidSeletedFinishWithContent:path isVedio:isVedio viewController:self];
                    [self hideHUB];
                }
            });
            
        }];
    } else {
        if ([SRAlbumData singleton].eidtClass) {
            UIViewController *viewController = [[[SRAlbumData singleton].eidtClass alloc] init];
            if (![SRAlbumData singleton].eidtSourceName){
                NSLog(@"请指定图片接收对象名");
            }else{
                if (![self isHaveTheAttributeWithAttributeName:[SRAlbumData singleton].eidtSourceName attribute:files class:[SRAlbumData singleton].eidtClass targer:viewController]) {
                    NSLog(@"该编辑页面中没有%@对象",[SRAlbumData singleton].eidtSourceName);
                }
            }
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
            if ([SRAlbumData singleton].albumDelegate && [[SRAlbumData singleton].albumDelegate respondsToSelector:@selector(srAlbumDidSeletedFinishWithContent:isVedio:viewController:)]) {
                [[SRAlbumData singleton].albumDelegate srAlbumDidSeletedFinishWithContent:files isVedio:isVedio viewController:self];
            }
        }
    }
}


/**
 TODO:判断并保存数据到该属性
 
 @param attributeName 属性名
 @param attribute 值
 @param class 对象的class
 @param target 对象
 @return 是否有该属性
 */
- (BOOL)isHaveTheAttributeWithAttributeName:(NSString *)attributeName attribute:(id)attribute class:(Class)class targer:(id)target{
    unsigned int count;
    BOOL isHave = NO;
    Ivar *allVariables = class_copyIvarList(class, &count);
    for (unsigned int i=0; i<count; i++) {
        Ivar ivar = allVariables[i];
        const char *Variablename = ivar_getName(ivar);
        NSString *name = [NSString stringWithUTF8String:Variablename];
        if ([name isEqualToString:[NSString stringWithFormat:@"_%@",attributeName]]) {
            isHave = YES;
            [target setValue:attribute forKey:attributeName];
        }else if ([name isEqualToString:@"_delegate"]){
            [target setValue:[SRAlbumData singleton].albumDelegate forKey:@"delegate"];
            
        }
    }
    free(allVariables);
    return isHave;
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    //    NSLog(@"%@",changeInstance);
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self assetsLibraryDidChange];
    });
}

#pragma mark - SRPhotoBrowsViewControllerDelegate
/**
 TODO:选择的已经改变
 
 @param indexpath 位置
 */
- (void)selectDidChangeIndexpath:(NSIndexPath *)indexpath{
    NSArray *cells = [self.collectionView visibleCells];
    id data;
    if (ISIOS8) {
        data = [self assetAtIndexPath:indexpath.item-([SRAlbumData singleton].isCanShot?1:0)];
        if (![(PHAsset *)data ctassetsPickerIsPhoto]) {
            [self didSelectedFiles:data isVedio:YES];
            return;
        }
    }else{
        data = self.fetchAlResult[indexpath.row-([SRAlbumData singleton].isCanShot?1:0)];
        if (![(ALAsset *)data ctassetsPickerIsPhoto]) {
            [self didSelectedFiles:data isVedio:YES];
            return;
        }
    }
    
    
    if ([self.selectPics containsObject:data]) {
        for (id cell in cells) {
            if ([cell isKindOfClass:[SRAlbumImageCollectionViewCell class]]) {
                if (((SRAlbumImageCollectionViewCell*)cell).phAsset == data || ((SRAlbumImageCollectionViewCell*)cell).alAsset == data) {
                    ((SRAlbumImageCollectionViewCell*)cell).isSelectd = YES;
                    continue;
                }else{
                    if (self.selectPics.count == [SRAlbumData singleton].maxItem && !((SRAlbumImageCollectionViewCell*)cell).isSelectd) {
                        ((SRAlbumImageCollectionViewCell*)cell).isShowMask = YES;
                    }
                    
                    BOOL isMovie;
                    if (((SRAlbumImageCollectionViewCell*)cell).phAsset) {
                        isMovie = ![((SRAlbumImageCollectionViewCell*)cell).phAsset ctassetsPickerIsPhoto];
                    }else{
                        isMovie = ![((SRAlbumImageCollectionViewCell*)cell).alAsset ctassetsPickerIsPhoto];
                    }
                    if (isMovie) {
                        ((SRAlbumImageCollectionViewCell*)cell).isShowMask = self.selectPics.count>0;
                    }else{
                        ((SRAlbumImageCollectionViewCell*)cell).isShowMask = ((SRAlbumImageCollectionViewCell*)cell).isSelectd?NO:self.selectPics.count == [SRAlbumData singleton].maxItem;
                    }
                    
                    
                }
                
            }
        }
    }else{
        for (id cell in cells) {
            if ([cell isKindOfClass:[SRAlbumImageCollectionViewCell class]] ) {
                if (((SRAlbumImageCollectionViewCell*)cell).phAsset == data || ((SRAlbumImageCollectionViewCell*)cell).alAsset == data) {
                    ((SRAlbumImageCollectionViewCell*)cell).isSelectd = NO;
                }else{
                    //                    ((SRAlbumImageCollectionViewCell*)cell).isShowMask = NO;
                    BOOL isMovie;
                    if (((SRAlbumImageCollectionViewCell*)cell).phAsset) {
                        isMovie = ![((SRAlbumImageCollectionViewCell*)cell).phAsset ctassetsPickerIsPhoto];
                    }else{
                        isMovie = ![((SRAlbumImageCollectionViewCell*)cell).alAsset ctassetsPickerIsPhoto];
                    }
                    if (isMovie) {
                        ((SRAlbumImageCollectionViewCell*)cell).isShowMask = self.selectPics.count>0;
                    }else{
                        ((SRAlbumImageCollectionViewCell*)cell).isShowMask = NO;
                    }
                    
                }
            }
        }
    }
    [self changeRightButtonStatu];
}


/**
 TODO:已经点击了完成
 */
- (void)didClickFinishAction{
    [self nextOperation];
}


/**
 TODO:压缩视频
 
 @param asset asset
 @param contentBlock 完成回调
 */
- (void)vedioCompressWithAsset:(id)asset contentBlock:(void(^)(BOOL success,NSURL* path))contentBlock{
    if (ISIOS8) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                [SRAlbumHelper compressedVideoWithPath:urlAsset.URL CompletionHandler:^(AVAssetExportSession *exportSession, NSURL *path) {
                    if (contentBlock) {
                        switch (exportSession.status) {
                            case AVAssetExportSessionStatusCompleted:
                                contentBlock(YES,path);
                                break;
                            default:
                                contentBlock(NO,path);
                                break;
                        }
                    }
                    
                }];
            }else if ([asset isKindOfClass:[AVComposition class]]){
                AVComposition* urlAsset = (AVComposition*)asset;
                [SRAlbumHelper compressedVideoCompositionWithComposition:urlAsset CompletionHandler:^(AVAssetExportSession *exportSession, NSURL *path) {
                    if (contentBlock) {
                        switch (exportSession.status) {
                            case AVAssetExportSessionStatusCompleted:
                                contentBlock(YES,path);
                                break;
                            default:
                                contentBlock(NO,path);
                                break;
                        }
                    }
                }];
            }
        }];
    }else{
        [SRAlbumHelper compressedVideoWithPath:((ALAsset *)asset).defaultRepresentation.url CompletionHandler:^(AVAssetExportSession *exportSession, NSURL *path) {
            if (contentBlock) {
                switch (exportSession.status) {
                    case AVAssetExportSessionStatusCompleted:
                        contentBlock(YES,path);
                        break;
                    default:
                        contentBlock(NO,path);
                        break;
                }
            }
        }];
    }
}

/**
 TODO:确定是否包含
 
 @param datas 数组
 @param alasset 视频信息
 @return 是否包含
 */
- (BOOL)isContainWithDatas:(NSArray *)datas alasset:(ALAsset *)alasset{
    BOOL isContain = NO;
    for (ALAsset *asset in datas) {
        if ([asset.defaultRepresentation.url  isEqual:alasset.defaultRepresentation.url ]) {
            isContain = YES;
            break;
        }
    }
    return isContain;
}

#pragma mark - ImageCollectionViewCellDelegate

/**
 TODO:点击选中按钮
 
 @param indexpath 位置
 */
- (void)didClickSelectActionIndexpath:(NSIndexPath *)indexpath{
    if (ISIOS8) {
        PHAsset *phAsset = [self assetAtIndexPath:indexpath.item-([SRAlbumData singleton].isCanShot?1:0)];
        [self selectOrDeleteWithData:phAsset withCollectionView:self.collectionView indexPath:indexpath];
    }else{
        ALAsset *alAsset = self.fetchAlResult[indexpath.row-([SRAlbumData singleton].isCanShot?1:0)];
        [self selectOrDeleteWithData:alAsset withCollectionView:self.collectionView indexPath:indexpath];
    }
    [self changeRightButtonStatu];
}

#pragma mark - SRVideoCaptureViewControllerDelegate
/**
 TODO:拍照或者录像已经确定完成和选择
 
 @param content 照片或者视频地址
 @param isVedio 是否是视频
 */
- (void)videoCaptureViewDidFinishWithContent:(id)content isVedio:(BOOL)isVedio{
    if (isVedio) {
        if ([content isKindOfClass:[NSURL class]]) {
            [SRAlbumHelper saveVedioWithurl:((NSURL *)content) completion:^(NSError *error, id asset) {
                if (!error) {
                    [SRAlbumHelper deleteFileByPath:((NSURL *)content)];
                    [self getAlbumDatasByCamera:NO contentBlock:^(BOOL success) {
                        if (success) {
                            if (ISIOS8) {
                                PHAsset *phAsset = [self assetAtIndexPath:0];
                                [self didSelectedFiles:phAsset isVedio:YES];
                            }else{
                                ALAsset *alAsset = self.fetchAlResult[0];
                                [self didSelectedFiles:alAsset isVedio:YES];
                            }
                        }
                    }];
                }
            }];
        }
    }else{
        if ([content isKindOfClass:[UIImage class]]) {
            [SRAlbumHelper savePhotoWithImage:((UIImage *)content) completion:^(NSError *error){
                if (!error) {
                    [self getAlbumDatasByCamera:YES contentBlock:nil];
                }
            }];
        }
    }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count;
    if (ISIOS8) {
        count = self.fetchResult.count;
    }else{
        count = self.fetchAlResult.count;
    }
    return count+([SRAlbumData singleton].isCanShot?1:0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([SRAlbumData singleton].isCanShot){
        if (indexPath.row == 0) {
            SRCameraView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SRCameraView" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:[SRAlbumData singleton].resourceType != 2?@"SRAlbum_Photo":@"SRAlbum_Vedio"];
            return cell;
        }
    }
    
    BOOL isMovie;
    SRAlbumImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SRAlbumImageCollectionViewCell" forIndexPath:indexPath];
    cell.indexpath = indexPath;
    cell.delegate = self;
    if (ISIOS8) {
        PHAsset *phAsset = [self assetAtIndexPath:indexPath.item- ([SRAlbumData singleton].isCanShot?1:0)];
        isMovie = ![phAsset ctassetsPickerIsPhoto];
        if (!self.selectIng) {
            cell.phAsset = phAsset;
        }
        
        if ([SRAlbumData singleton].resourceType != 2) {
            cell.isSelectd = [self.selectPics containsObject:phAsset];
        }
    }else{
        ALAsset *alAsset = self.fetchAlResult[indexPath.row-([SRAlbumData singleton].isCanShot?1:0)];
        isMovie = ![alAsset ctassetsPickerIsPhoto];
        if (!self.selectIng) {
            cell.alAsset = alAsset;
        }
        if ([SRAlbumData singleton].resourceType != 2) {
            cell.isSelectd = [self isContainWithDatas:self.selectPics alasset:alAsset];
        }
    }
    if (isMovie) {
        cell.isShowMask = self.selectPics.count>0;
    }else{
        cell.isShowMask = cell.isSelectd?NO:[SRAlbumData singleton].maxItem<=self.selectPics.count;
    }
    
    
    //        cell.showSelect = [SRAlbumData singleton].resourceType != 2;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([SRAlbumData singleton].isCanShot){
        if (indexPath.row == 0) {
            if (self.selectPics.count < [SRAlbumData singleton].maxItem) {
                [self openVideoCaptureView];
            }else{
                [self showAlertWithMessage:[NSString stringWithFormat:@"最多选取%@张图片",@([SRAlbumData singleton].maxItem)] tager:self];
            }
        }
    }else{
        if ([SRAlbumData singleton].resourceType == 2) {//选择了视频
            if (ISIOS8) {
                PHAsset *phAsset = [self assetAtIndexPath:indexPath.item-([SRAlbumData singleton].isCanShot?1:0)];
                typeof(self) __weak weakSelf = self;
                [self showSheetWithMessage:@"选择或者浏览" firstTitle:@"选择" secondTitle:@"浏览" tager:self firstHandler:^(UIAlertAction *action) {
                    [weakSelf didSelectedFiles:phAsset isVedio:YES];
                } secondHandler:^(UIAlertAction *action) {
                    [weakSelf browsMoveWithAsset:phAsset];
                }];
            }else{
                ALAsset *alAsset = self.fetchAlResult[indexPath.row-([SRAlbumData singleton].isCanShot?1:0)];
                typeof(self) __weak weakSelf = self;
                [self showSheetWithMessage:@"选择或者浏览" firstTitle:@"选择" secondTitle:@"浏览" tager:self firstHandler:^(UIAlertAction *action) {
                    [weakSelf didSelectedFiles:alAsset isVedio:YES];
                } secondHandler:^(UIAlertAction *action) {
                    [weakSelf browsMoveWithAsset:alAsset];
                }];
            }
        }else if ([SRAlbumData singleton].resourceType == 1){//图片
            SRPhotoBrowsViewController *viewController = [[SRPhotoBrowsViewController alloc] init];
            viewController.delegate = self;
            viewController.fetchAlResult = self.fetchAlResult;
            viewController.fetchResult = self.fetchResult;
            viewController.selectPics = self.selectPics;
            viewController.showIndexPath = [NSIndexPath indexPathForRow:indexPath.row-([SRAlbumData singleton].isCanShot?1:0) inSection:0];
            [self.navigationController pushViewController:viewController animated:YES];
        }else{//图片和视频混合
            
            if (ISIOS8) {
                PHAsset *phAsset = [self assetAtIndexPath:indexPath.item-([SRAlbumData singleton].isCanShot?1:0)];
                if (![phAsset ctassetsPickerIsPhoto]) {
                    if (self.selectPics.count == 0) {
                        SRPhotoBrowsViewController *viewController = [[SRPhotoBrowsViewController alloc] init];
                        viewController.delegate = self;
                        viewController.fetchAlResult = self.fetchAlResult;
                        viewController.fetchResult = self.fetchResult;
                        viewController.selectPics = self.selectPics;
                        viewController.showIndexPath = [NSIndexPath indexPathForRow:indexPath.row-([SRAlbumData singleton].isCanShot?1:0) inSection:0];
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                }else{
                    SRPhotoBrowsViewController *viewController = [[SRPhotoBrowsViewController alloc] init];
                    viewController.delegate = self;
                    viewController.fetchAlResult = self.fetchAlResult;
                    viewController.fetchResult = self.fetchResult;
                    viewController.selectPics = self.selectPics;
                    viewController.showIndexPath = [NSIndexPath indexPathForRow:indexPath.row-([SRAlbumData singleton].isCanShot?1:0) inSection:0];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
            }else{
                ALAsset *alAsset = self.fetchAlResult[indexPath.row-([SRAlbumData singleton].isCanShot?1:0)];
                if (![alAsset ctassetsPickerIsPhoto]) {
                    if (self.selectPics.count == 0) {
                        SRPhotoBrowsViewController *viewController = [[SRPhotoBrowsViewController alloc] init];
                        viewController.delegate = self;
                        viewController.fetchAlResult = self.fetchAlResult;
                        viewController.fetchResult = self.fetchResult;
                        viewController.selectPics = self.selectPics;
                        viewController.showIndexPath = [NSIndexPath indexPathForRow:indexPath.row-([SRAlbumData singleton].isCanShot?1:0) inSection:0];
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                }else{
                    SRPhotoBrowsViewController *viewController = [[SRPhotoBrowsViewController alloc] init];
                    viewController.delegate = self;
                    viewController.fetchAlResult = self.fetchAlResult;
                    viewController.fetchResult = self.fetchResult;
                    viewController.selectPics = self.selectPics;
                    viewController.showIndexPath = [NSIndexPath indexPathForRow:indexPath.row-([SRAlbumData singleton].isCanShot?1:0) inSection:0];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
            }
        }
    }
}


/**
 TODO:浏览视频
 
 @param asset 视屏源
 */
- (void)browsMoveWithAsset:(id)asset{
    if (ISIOS8) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                dispatch_async(dispatch_get_main_queue(), ^{
                    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:urlAsset.URL];
                    [moviePlayerController.moviePlayer prepareToPlay];
                    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
                });
            }else if ([asset isKindOfClass:[AVComposition class]]){
                [self showAlertWithMessage:@"该视频为混合剪辑视频，无法预览" tager:self];
            }
        }];
    }else{
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:((ALAsset *)asset).defaultRepresentation.url];
        [moviePlayerController.moviePlayer prepareToPlay];
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    }
}


/**
 TODO:删除或者添加到数值
 
 @param data 内容
 @param collectionView 表单
 @param indexPath 序号
 */
- (void)selectOrDeleteWithData:(id)data withCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
    
    NSArray *cells = [collectionView visibleCells];
    
    if ([self.selectPics containsObject:data]) {
        if (self.selectPics.count <= [SRAlbumData singleton].maxItem) {
            [self.selectPics removeObject:data];
            for (id cell in cells) {
                if ([cell isKindOfClass:[SRAlbumImageCollectionViewCell class]]) {
                    if (((SRAlbumImageCollectionViewCell*)cell).phAsset == data || ((SRAlbumImageCollectionViewCell*)cell).alAsset == data) {
                        ((SRAlbumImageCollectionViewCell*)cell).isSelectd = NO;
                    }else{
                        BOOL isMovie;
                        if (((SRAlbumImageCollectionViewCell*)cell).phAsset) {
                            isMovie = ![((SRAlbumImageCollectionViewCell*)cell).phAsset ctassetsPickerIsPhoto];
                        }else{
                            isMovie = ![((SRAlbumImageCollectionViewCell*)cell).alAsset ctassetsPickerIsPhoto];
                        }
                        if (isMovie) {
                            ((SRAlbumImageCollectionViewCell*)cell).isShowMask = self.selectPics.count>0;
                        }else{
                            ((SRAlbumImageCollectionViewCell*)cell).isShowMask = NO;
                        }
                    }
                }
            }
        }
    }else{
        if (self.selectPics.count < [SRAlbumData singleton].maxItem) {
            [self.selectPics addObject:data];
            for (id cell in cells) {
                if ([cell isKindOfClass:[SRAlbumImageCollectionViewCell class]]) {
                    if (((SRAlbumImageCollectionViewCell*)cell).phAsset == data || ((SRAlbumImageCollectionViewCell*)cell).alAsset == data) {
                        ((SRAlbumImageCollectionViewCell*)cell).isSelectd = YES;
                    }
                    BOOL isMovie;
                    if (((SRAlbumImageCollectionViewCell*)cell).phAsset) {
                        isMovie = ![((SRAlbumImageCollectionViewCell*)cell).phAsset ctassetsPickerIsPhoto];
                    }else{
                        isMovie = ![((SRAlbumImageCollectionViewCell*)cell).alAsset ctassetsPickerIsPhoto];
                    }
                    if (isMovie) {
                        ((SRAlbumImageCollectionViewCell*)cell).isShowMask = self.selectPics.count>0;
                    }else{
                        ((SRAlbumImageCollectionViewCell*)cell).isShowMask = ((SRAlbumImageCollectionViewCell*)cell).isSelectd?NO:self.selectPics.count == [SRAlbumData singleton].maxItem;
                    }
                }
            }
        }else{
            [self showAlertWithMessage:[NSString stringWithFormat:@"最多选取%@张图片",@([SRAlbumData singleton].maxItem)] tager:self];
        }
    }
}


/**
 TODO:复位选择列表
 */
- (void)resetAllSelectStatu{
    [self.selectPics removeAllObjects];
    NSArray *cells = [self.collectionView visibleCells];
    for (id cell in cells) {
        if ([cell isKindOfClass:[SRAlbumImageCollectionViewCell class]]) {
            ((SRAlbumImageCollectionViewCell*)cell).isSelectd = NO;
            ((SRAlbumImageCollectionViewCell*)cell).isShowMask = NO;
        }
    }
}


/**
 TODO:改变状态
 */
- (void)changeRightButtonStatu{
    NSString *message;
    if (self.selectPics.count>0) {
        message = [NSString stringWithFormat:@"下一步(%@)",@(self.selectPics.count)];
    }else{
        message = @"下一步";
    }
    [self.headerView rightBtnSetTitle:message forState:UIControlStateNormal];
    [self.headerView changRightBtnEnable:self.selectPics.count>0];
}


@end

