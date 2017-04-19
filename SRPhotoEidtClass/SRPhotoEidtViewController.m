//
//  SRPhotoEidtViewController.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/17.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "SRPhotoEidtViewController.h"
#import "SRHeaderView.h"
#import "GPUImage.h"
#import "SRPhptpEidtCollectionViewCell.h"
#import "PiecewiseView.h"
#import "ToolView.h"
#import "SRPhotoEidtDto.h"

@interface SRPhotoEidtViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,PiecewiseViewDelegate,ToolViewDelegate>{

}
@property (nonatomic, strong) SRHeaderView                  *headerView;
@property (nonatomic, strong) UICollectionView              *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout    *layout;
@property (nonatomic, strong) PiecewiseView                 *piecewiseView;//分段选择
@property (nonatomic, strong) ToolView                      *toolView;//工具

@property (nonatomic, strong) NSMutableArray                *imageList;

@property (nonatomic, strong) NSMutableArray                *picturelist;
@property (nonatomic, strong) NSMutableArray                *effectList;//效果
@property (nonatomic, strong) NSMutableArray                *beautificationList;//美化效果
@property (nonatomic, strong) NSMutableArray                *beautificationDatalist;

@property (nonatomic, assign) CGFloat                       toolHeight;
@property (nonatomic, strong) NSIndexPath                   *showIndexPath;

@end

@implementation SRPhotoEidtViewController

- (void)dealloc{
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
}

- (void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addHeadView];
}

- (void)addHeadView{
    [self.view addSubview:self.headerView];
    self.headerView.title = [NSString stringWithFormat:@"编辑(1/%@)",@(self.imageSource.count)];
    [self.headerView leftBtnSetTitle:@"上一步" forState:UIControlStateNormal];
    [self.headerView leftBtnAddTarget:self selector:@selector(backViewController)];
    [self.headerView rightBtnSetTitle:@"下一步" forState:UIControlStateNormal];
    [self.headerView rightBtnAddTarget:self selector:@selector(nextOperation)];
}

- (SRHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[SRHeaderView alloc] init];
    }
    return _headerView;
}

- (void)exChangeMessageDataSourceQueue:(void (^)())queue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), queue);
}

- (void)exMainQueue:(void (^)())queue {
    dispatch_async(dispatch_get_main_queue(), queue);
}

- (void)setImageSource:(NSArray *)imageSource{
    _imageSource = imageSource;
    [self.imageList addObjectsFromArray:imageSource];
    for (int i = 0; i < imageSource.count; i++) {
        [self.beautificationDatalist addObject:[SRPhotoEidtDto new]];
        [self.picturelist addObject:[[GPUImagePicture alloc] initWithImage:[imageSource objectAtIndex:i]]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self addViews];
}



- (void)initData{
    self.toolHeight = 180;
    self.showIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    GPUImageHazeFilter *hazeFilter = [[GPUImageHazeFilter alloc] init];//原图
    hazeFilter.distance = 0.0;
    [self.effectList addObject:hazeFilter];
    GPUImageHazeFilter *hazeFilterBrighter = [[GPUImageHazeFilter alloc] init];//阳光
    hazeFilterBrighter.distance = -0.3;
    [self.effectList addObject:hazeFilterBrighter];
    GPUImageHazeFilter *hazeFilterDarker = [[GPUImageHazeFilter alloc] init];//幽暗
    hazeFilterDarker.distance = 0.3;
    [self.effectList addObject:hazeFilterDarker];
    [self.effectList addObject:[[GPUImageGrayscaleFilter alloc] init]];//灰白
    [self.effectList addObject:[[GPUImageSepiaFilter alloc] init]];//怀旧
    
    
    [self.beautificationList addObject:[[GPUImageBrightnessFilter alloc] init]];//亮度
    [self.beautificationList addObject:[[GPUImageContrastFilter alloc] init]];//对比度
    [self.beautificationList addObject:[[GPUImageSharpenFilter alloc] init]];//锐度
    [self.beautificationList addObject:[[GPUImageSaturationFilter alloc] init]];//饱和度
    [self.beautificationList addObject:[[GPUImageWhiteBalanceFilter alloc] init]];//色温
}


- (void)addViews{
    [self.view insertSubview:self.collectionView belowSubview:self.headerView];
    [self.view addSubview:self.piecewiseView];
    [self.view addSubview:self.toolView];
}

- (NSMutableArray *)imageList{
    if (!_imageList) {
        _imageList = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageList;
}

- (NSMutableArray *)picturelist{
    if (!_picturelist) {
        _picturelist = [NSMutableArray arrayWithCapacity:0];
    }
    return _picturelist;
}

- (NSMutableArray *)effectList{
    if (!_effectList) {
        _effectList = [NSMutableArray arrayWithCapacity:0];
    }
    return _effectList;
}

- (NSMutableArray *)beautificationList{
    if (!_beautificationList) {
        _beautificationList = [NSMutableArray arrayWithCapacity:0];
    }
    return _beautificationList;
}

- (NSMutableArray *)beautificationDatalist{
    if (!_beautificationDatalist) {
        _beautificationDatalist = [NSMutableArray arrayWithCapacity:0];
    }
    return _beautificationDatalist;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        [self layoutSize];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.exclusiveTouch = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[SRPhptpEidtCollectionViewCell class] forCellWithReuseIdentifier:@"SRPhptpEidtCollectionViewCell"];
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

- (PiecewiseView *)piecewiseView{
    if (!_piecewiseView) {
        _piecewiseView = [PiecewiseView new];
        _piecewiseView.buttons = @[@"滤镜",@"美化"];
        _piecewiseView.delegate = self;
    }
    return _piecewiseView;
}

- (ToolView *)toolView{
    if (!_toolView) {
        _toolView = [[ToolView alloc] init];
        _toolView.delegate = self;
        _toolView.titleList = @[@"原图",@"阳光",@"幽暗",@"灰白",@"怀旧"];
        _toolView.effectList = self.effectList;
        _toolView.photoEidtDto = [self.beautificationDatalist objectAtIndex:0];
    }
    return _toolView;
}

- (void)layoutSize{
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.layout.itemSize = CGSizeMake(size.width, size.height-CGRectGetHeight(self.headerView.frame)-self.toolHeight);
}


/**
 TODO:返回
 */
- (void)backViewController{
    [self.navigationController popViewControllerAnimated:YES];;
}


/**
 TODO:下一步
 */
- (void)nextOperation{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEidtEndWithDatas:viewController:)]) {
        [self.delegate didEidtEndWithDatas:self.imageList viewController:self];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(self.headerView.frame)-self.toolHeight);
    [self layoutSize];
    if (_collectionView) {
        self.collectionView.collectionViewLayout = self.layout;
    }
    
    self.piecewiseView.frame = CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 40);
    self.toolView.frame =CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), self.view.bounds.size.width, CGRectGetMinY(self.piecewiseView.frame)-CGRectGetMaxY(self.collectionView.frame));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SRPhptpEidtCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SRPhptpEidtCollectionViewCell" forIndexPath:indexPath];
    cell.imgView.image = [self.imageList objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = (int)(scrollView.contentOffset.x/scrollView.frame.size.width);
    self.toolView.imageIndex = page;
    self.showIndexPath = [NSIndexPath indexPathForRow:page inSection:0];
    self.headerView.title = [NSString stringWithFormat:@"编辑(%@/%@)",@(page+1),@(self.imageSource.count)];
    self.toolView.photoEidtDto = [self.beautificationDatalist objectAtIndex:page];
}

#pragma mark - PiecewiseViewDelegate
/**
 TODO:已经选择序号
 
 @param index 序号
 */
- (void)didselectindex:(NSInteger)index{
    self.toolView.selectIndex = index;
}


#pragma mark - ToolViewDelegate
/**
TODO:选择滤镜

@param index 序号
*/
- (void)didSelectFilterIndex:(NSUInteger)index{
    if(self.showIndexPath.row<self.beautificationDatalist.count){
        SRPhotoEidtDto *photoEidtDto = [self.beautificationDatalist objectAtIndex:self.showIndexPath.row];
        [photoEidtDto resetData];
        [self startFilterIndex:index];
    }
}


/**
 TODO:为图片添加滤镜

 @param index 滤镜序号
 */
- (void)startFilterIndex:(NSUInteger)index{
    GPUImagePicture *picGpu = [self.picturelist objectAtIndex:self.showIndexPath.row];
    GPUImageFilter *fillter = [self.effectList objectAtIndex:index];
    [picGpu addTarget:fillter];
    [fillter useNextFrameForImageCapture];
    [picGpu processImage];
    [self.imageList replaceObjectAtIndex:self.showIndexPath.row withObject:[fillter imageFromCurrentFramebuffer]];
    [self.collectionView reloadItemsAtIndexPaths:@[self.showIndexPath]];
    [fillter removeAllTargets];
    [picGpu removeAllTargets];
}

/**
 TODO:选择了第几工具序号
 
 @param index 序号
 */
- (void)didSeletToolIndex:(NSUInteger)index{
    self.piecewiseView.selectIndex = index;
}

/**
 TODO:调整图片的样式
 
 @param value 值
 @param type 类型
 */
- (void)didAdjustmentWithValue:(CGFloat)value type:(NSUInteger)type{
    GPUImagePicture *picGpu = [self.picturelist objectAtIndex:self.showIndexPath.row];
    GPUImageFilterGroup *filterGroup  = [[GPUImageFilterGroup alloc] init];
    [picGpu addTarget:filterGroup];
    
    //获取滤镜的序号
    NSUInteger filterStyle = [self.toolView filterStyleByImageIndex:self.showIndexPath.row];
    if (filterStyle != 0) {
        [self addGPUImageFilter:[self.effectList objectAtIndex:filterStyle] filterGroup:filterGroup];
    }
    SRPhotoEidtDto *eidtDto = [self.beautificationDatalist objectAtIndex:self.showIndexPath.row];
    if (type == 0) {
        eidtDto.brightness = value;
    }else if (type == 1){
        eidtDto.contrast = value;
    }else if (type == 2){
        eidtDto.sharpen = value;
    }else if (type == 3){
        eidtDto.saturat = value;
    }else if (type == 4){
        eidtDto.whiteBalance = value;
    }
    if (eidtDto.brightness != 0.0) {
        GPUImageBrightnessFilter *brightnessFilter = [self.beautificationList objectAtIndex:0];
        brightnessFilter.brightness = eidtDto.brightness;
        [self addGPUImageFilter:[self.beautificationList objectAtIndex:0] filterGroup:filterGroup];
    }
    if (eidtDto.contrast != 1.0) {
        GPUImageContrastFilter *contrastFilter = [self.beautificationList objectAtIndex:1];
        contrastFilter.contrast = eidtDto.contrast;
        [self addGPUImageFilter:[self.beautificationList objectAtIndex:1] filterGroup:filterGroup];
    }
    if (eidtDto.sharpen != 0) {
        GPUImageSharpenFilter *sharpenFilter = [self.beautificationList objectAtIndex:2];
        sharpenFilter.sharpness = eidtDto.sharpen;
        [self addGPUImageFilter:[self.beautificationList objectAtIndex:2] filterGroup:filterGroup];
    }
    if (eidtDto.saturat != 1.0) {
        GPUImageSaturationFilter *saturationFilter = [self.beautificationList objectAtIndex:3];
        saturationFilter.saturation = eidtDto.saturat;
        [self addGPUImageFilter:[self.beautificationList objectAtIndex:3] filterGroup:filterGroup];
    }
    if (eidtDto.whiteBalance != 0.0) {
        GPUImageWhiteBalanceFilter * whiteBalanceFilter = [self.beautificationList objectAtIndex:4];
        whiteBalanceFilter.tint = eidtDto.whiteBalance;
        [self addGPUImageFilter:[self.beautificationList objectAtIndex:4] filterGroup:filterGroup];
    }
    [picGpu processImage];
    [filterGroup useNextFrameForImageCapture];
    UIImage *tempImage = [filterGroup imageFromCurrentFramebuffer];
    if(tempImage){
        [self.imageList replaceObjectAtIndex:self.showIndexPath.row withObject:tempImage];
        [self.collectionView reloadItemsAtIndexPaths:@[self.showIndexPath]];
    }
    [filterGroup removeAllTargets];
    [picGpu removeAllTargets];
}


/**
 TODO:添加滤镜到组

 @param filter 滤镜
 @param filterGroup 滤镜组
 */
- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter filterGroup:(GPUImageFilterGroup *)filterGroup{
    [filterGroup addFilter:filter];
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    NSInteger count = filterGroup.filterCount;
    if (count == 1){
        filterGroup.initialFilters = @[newTerminalFilter];
        filterGroup.terminalFilter = newTerminalFilter;
        
    } else {
        GPUImageOutput<GPUImageInput> *terminalFilter    = filterGroup.terminalFilter;
        NSArray *initialFilters                          = filterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        filterGroup.initialFilters = @[initialFilters[0]];
        filterGroup.terminalFilter = newTerminalFilter;
    }
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
