//
//  ToolView.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/17.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "ToolView.h"
#import "FilterCollectionViewCell.h"

@interface ToolView()<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView                        *lineView;
@property (nonatomic, strong) UIView                        *filterView;     //滤镜View
@property (nonatomic, strong) UICollectionView              *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout    *layout;

@property (nonatomic, strong) UIView                        *beautifyView;   //美化View
@property (nonatomic, strong) UIButton                      *brightnessButton;//亮度按钮
@property (nonatomic, strong) UIButton                      *contrastButton;//对比度按钮
@property (nonatomic, strong) UIButton                      *sharpnessButton;//锐度按钮
@property (nonatomic, strong) UIButton                      *saturationButton;//饱和度按钮
@property (nonatomic, strong) UIButton                      *whiteBalanceButton;//色温按钮
@property (nonatomic, strong) UISlider                      *slider;//滑竿

@property (nonatomic, strong) NSMutableDictionary           *selectDic;//保存已经美化的内容
@property (nonatomic, assign) NSUInteger                    typeIndex;
@property (nonatomic, assign) long long                     lastTime;
@end

@implementation ToolView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initData];
        [self addViews];
        [self addGesture];
    }
    return self;
}

- (void)initData{
    self.selectIndex = 0;
    self.selectDic = [NSMutableDictionary dictionaryWithCapacity:0];
}

- (void)setSelectIndex:(NSUInteger)selectIndex{
    if (_selectIndex == selectIndex) {
        if (selectIndex == 0 && !self.filterView.superview) {
            [self addSubview:self.filterView];
        }
    }else{
        _selectIndex = selectIndex;
        [self delegateSwipeAnimation:selectIndex==1?NO:YES];
    }
}

- (void)addViews{
    [self addSubview:self.lineView];
    [self.filterView addSubview:self.collectionView];
    [self.beautifyView addSubview:self.brightnessButton];
    [self.beautifyView addSubview:self.contrastButton];
    [self.beautifyView addSubview:self.sharpnessButton];
    [self.beautifyView addSubview:self.saturationButton];
    [self.beautifyView addSubview:self.whiteBalanceButton];
    [self.beautifyView addSubview:self.slider];
}

- (void)addGesture{
    UISwipeGestureRecognizer *recognizerRight;
    recognizerRight.delegate=self;
    recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:recognizerRight];
}

- (UIView *)filterView{
    if (!_filterView) {
        _filterView = [[UIView alloc] init];
        _filterView.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];

    }
    return _filterView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        [self layoutSize];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.exclusiveTouch = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[FilterCollectionViewCell class] forCellWithReuseIdentifier:@"FilterCollectionViewCell"];
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumInteritemSpacing = 10;
        _layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    return _layout;
}

- (UIView *)beautifyView{
    if (!_beautifyView) {
        _beautifyView = [[UIView alloc] init];
        _beautifyView.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
    }
    return _beautifyView;
}

- (void)setButtonStyeWithButton:(UIButton *)button{
    // the space between the image and text
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    // increase the content height to avoid clipping
    CGFloat edgeOffset = fabs(titleSize.height - imageSize.height) / 2.0;
    button.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0);
}

- (UIButton *)brightnessButton{
    if (!_brightnessButton) {
        _brightnessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _brightnessButton.tag = 0;
        [_brightnessButton setImage:[UIImage imageNamed:@"SRBrightness_Ordinary"] forState:UIControlStateNormal];
        [_brightnessButton setImage:[UIImage imageNamed:@"SRBrightness_Select"] forState:UIControlStateSelected];
        [_brightnessButton setTitle:@"亮度" forState:UIControlStateNormal];
        [_brightnessButton setTitleColor:[UIColor colorWithRed:137.0/255.0 green:127.0/255.0 blue:129.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        _brightnessButton.selected = YES;
        [_brightnessButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:112.0/255.0 blue:124.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [_brightnessButton addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self setButtonStyeWithButton:_brightnessButton];
    }
    return _brightnessButton;
}

- (UIButton *)contrastButton{
    if (!_contrastButton) {
        _contrastButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _contrastButton.tag = 1;
        [_contrastButton setImage:[UIImage imageNamed:@"SRContrast_Ordinary"] forState:UIControlStateNormal];
        [_contrastButton setImage:[UIImage imageNamed:@"SRContrast_Select"] forState:UIControlStateSelected];
        [_contrastButton setTitle:@"对比度" forState:UIControlStateNormal];
        [_contrastButton setTitleColor:[UIColor colorWithRed:137.0/255.0 green:127.0/255.0 blue:129.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_contrastButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:112.0/255.0 blue:124.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [_contrastButton addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self setButtonStyeWithButton:_contrastButton];
    }
    return _contrastButton;
}

- (UIButton *)sharpnessButton{
    if (!_sharpnessButton) {
        _sharpnessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sharpnessButton.tag = 2;
        [_sharpnessButton setImage:[UIImage imageNamed:@"SRSharp_Ordinary"] forState:UIControlStateNormal];
        [_sharpnessButton setImage:[UIImage imageNamed:@"SRSharp_Select"] forState:UIControlStateSelected];
        [_sharpnessButton setTitle:@"锐度" forState:UIControlStateNormal];
        [_sharpnessButton setTitleColor:[UIColor colorWithRed:137.0/255.0 green:127.0/255.0 blue:129.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_sharpnessButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:112.0/255.0 blue:124.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [_sharpnessButton addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self setButtonStyeWithButton:_sharpnessButton];
    }
    return _sharpnessButton;
}

- (UIButton *)saturationButton{
    if (!_saturationButton) {
        _saturationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saturationButton.tag = 3;
        [_saturationButton setImage:[UIImage imageNamed:@"SRSaturation_Ordinary"] forState:UIControlStateNormal];
        [_saturationButton setImage:[UIImage imageNamed:@"SRSaturation_Select"] forState:UIControlStateSelected];
        [_saturationButton setTitle:@"饱和度" forState:UIControlStateNormal];
        [_saturationButton setTitleColor:[UIColor colorWithRed:137.0/255.0 green:127.0/255.0 blue:129.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_saturationButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:112.0/255.0 blue:124.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [_saturationButton addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self setButtonStyeWithButton:_saturationButton];
    }
    return _saturationButton;
}

- (UIButton *)whiteBalanceButton{
    if (!_whiteBalanceButton) {
        _whiteBalanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _whiteBalanceButton.tag = 4;
        [_whiteBalanceButton setImage:[UIImage imageNamed:@"SRWhiteBalance_Ordinary"] forState:UIControlStateNormal];
        [_whiteBalanceButton setImage:[UIImage imageNamed:@"SRWhiteBalance_Select"] forState:UIControlStateSelected];
        [_whiteBalanceButton setTitle:@"色温" forState:UIControlStateNormal];
        [_whiteBalanceButton setTitleColor:[UIColor colorWithRed:137.0/255.0 green:127.0/255.0 blue:129.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_whiteBalanceButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:112.0/255.0 blue:124.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [_whiteBalanceButton addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self setButtonStyeWithButton:_whiteBalanceButton];
    }
    return _whiteBalanceButton;
}

- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.minimumTrackTintColor = [UIColor colorWithRed:255.0/255.0 green:112.0/255.0 blue:124.0/255.0 alpha:1.0];
        _slider.maximumTrackTintColor = [UIColor colorWithRed:137.0/255.0 green:127.0/255.0 blue:129.0/255.0 alpha:1.0];
        _slider.maximumValue = 0.3;
        _slider.minimumValue = -0.3;
        _slider.value = 0;
        [_slider addTarget:self action:@selector(setImageValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    }
    return _lineView;
}

- (void)setTitleList:(NSArray *)titleList{
    _titleList = titleList;
    for (int i = 0; i < titleList.count; i++) {
        [self.selectDic setObject:@(0) forKey:@(i)];
    }
}

- (void)setImageIndex:(int)imageIndex{
    _imageIndex = imageIndex;
    if (self.filterView.superview) {
        [self.collectionView reloadData];
    }
}

-(void)swipeLeft: (UISwipeGestureRecognizer *)swipe{
    if (self.filterView.superview) {
        [self delegateSwipeAnimation: NO];
    }
}

-(void)swipeRight: (UISwipeGestureRecognizer *)swipe{
    if (self.beautifyView.superview) {
        [self delegateSwipeAnimation: YES];
    }
}


/**
 TODO:调整值得大小

 @param slider 滑块
 */
- (void)setImageValue:(UISlider*)slider{
    long long now = [[NSDate date] timeIntervalSince1970]*1000.0;
    if ((now - self.lastTime)>200) {//做限制
        if (self.delegate && [self.delegate respondsToSelector:@selector(didAdjustmentWithValue:type:)]) {
            [self.delegate didAdjustmentWithValue:slider.value type:self.typeIndex];
        }
        self.lastTime = now;
    }
}

- (void)setPhotoEidtDto:(SRPhotoEidtDto *)photoEidtDto{
    _photoEidtDto = photoEidtDto;
    if (self.typeIndex == 0) {
        self.slider.value = photoEidtDto.brightness;
    }else if (self.typeIndex == 1){
        self.slider.value = photoEidtDto.contrast;
    }else if (self.typeIndex == 2){
        self.slider.value = photoEidtDto.sharpen;
    }else if (self.typeIndex == 3){
        self.slider.value = photoEidtDto.saturat;
    }else if (self.typeIndex == 4){
        self.slider.value = photoEidtDto.whiteBalance;
    }
}

- (void)didClickButton:(UIButton *)button{
    self.typeIndex = button.tag;
    button.selected = YES;
    for (id contentView in self.beautifyView.subviews) {
        if ([contentView isKindOfClass:[UIButton class]]) {
            if (contentView != button) {
                ((UIButton *)contentView).selected = NO;
            }
        }
    }
    if (self.typeIndex == 0) {
        self.slider.maximumValue = 1.0;
        self.slider.minimumValue = -1.0;
        self.slider.value = self.photoEidtDto.brightness;
    }else if (self.typeIndex == 1){
        self.slider.maximumValue = 4.0;
        self.slider.minimumValue = 0.0;
        self.slider.value = self.photoEidtDto.contrast;
    }else if (self.typeIndex == 2){
        self.slider.maximumValue = 4.0;
        self.slider.minimumValue = -4.0;
        self.slider.value = self.photoEidtDto.sharpen;
    }else if (self.typeIndex == 3){
        self.slider.maximumValue = 2.0;
        self.slider.minimumValue = 0.0;
        self.slider.value = self.photoEidtDto.saturat;
    }else if (self.typeIndex == 4){
        self.slider.maximumValue = 200.0;
        self.slider.minimumValue = -200.0;
        self.slider.value = self.photoEidtDto.whiteBalance;
    }
}

-(void)delegateSwipeAnimation: (BOOL)blnSwipeRight{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:(blnSwipeRight)?kCATransitionFromLeft:kCATransitionFromRight];
    [animation setDuration:0.50];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.layer addAnimation:animation forKey:kCATransition];
    [self performSelector:@selector(renderSwipeDates) withObject:nil afterDelay:0.05f];
}

-(void)renderSwipeDates{
    if (self.filterView.superview) {
        [self.filterView removeFromSuperview];
        [self addSubview:self.beautifyView];
    }else{
        [self.beautifyView removeFromSuperview];
        [self addSubview:self.filterView];
        self.collectionView.bounces = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSeletToolIndex:)]) {
        _selectIndex = self.filterView.superview?0:1;
        [self.delegate didSeletToolIndex:self.selectIndex];
    }
}


- (void)layoutSize{
    self.layout.itemSize = CGSizeMake(CGRectGetHeight(self.frame)-50, CGRectGetHeight(self.frame)-20);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = self.frame.size;
    self.lineView.frame = CGRectMake(0, size.height-0.6, size.width, 0.6);
    self.filterView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-0.6);
    self.beautifyView.frame = self.filterView.frame;
    self.collectionView.frame = self.filterView.bounds;
    [self layoutSize];
    if (_collectionView) {
        _collectionView.collectionViewLayout = self.layout;
    }
    CGFloat buttonWidth = size.width/5;
    self.brightnessButton.frame = CGRectMake(0, size.height*1.0/3.0, buttonWidth, size.height*2.0/3.0);
    self.contrastButton.frame = CGRectMake(buttonWidth, size.height*1.0/3.0, buttonWidth, size.height*2.0/3.0);
    self.sharpnessButton.frame = CGRectMake(buttonWidth*2, size.height*1.0/3.0, buttonWidth, size.height*2.0/3.0);
    self.saturationButton.frame = CGRectMake(buttonWidth*3, size.height*1.0/3.0, buttonWidth, size.height*2.0/3.0);
    self.whiteBalanceButton.frame = CGRectMake(buttonWidth*4, size.height*1.0/3.0, buttonWidth, size.height*2.0/3.0);
    self.slider.frame = CGRectMake(50, ((size.height*1.0/3.0)-(size.height*1.0/6.0))/2.0, size.width-100, size.height*1.0/6.0);
}

- (UIImage *)imageWithName:(NSString *)name{
    NSString *imageName;
    if ([name isEqualToString:@"原图"]) {
        imageName = @"SRPhoto_Eidt_Original_Icon";
    }else if ([name isEqualToString:@"阳光"]){
        imageName = @"SRPhoto_Eidt_brighter_Icon";
    }else if ([name isEqualToString:@"幽暗"]){
        imageName = @"SRPhoto_Eidt_Darker_Icon";
    }else if ([name isEqualToString:@"灰白"]){
        imageName = @"SRPhoto_Eidt_Black_Icon";
    }else if ([name isEqualToString:@"怀旧"]){
        imageName = @"SRPhoto_Eidt_Sepia_Icon";
    }
    return [UIImage imageNamed:imageName];
}


/**
 TODO:获取滤镜的序号

 @param imageIndex 图片序号
 @return 滤镜的序号
 */
- (NSUInteger)filterStyleByImageIndex:(NSUInteger)imageIndex{
    return [[self.selectDic objectForKey:@(imageIndex)] intValue];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.effectList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCollectionViewCell" forIndexPath:indexPath];
    cell.imageView.image = [self imageWithName:[self.titleList objectAtIndex:indexPath.row]];
    cell.titleStr = [self.titleList objectAtIndex:indexPath.row];
    cell.isSelected = [[self.selectDic objectForKey:@(self.imageIndex)] intValue] == indexPath.row;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFilterIndex:)]) {
        [self.delegate didSelectFilterIndex:indexPath.row];
        [self.selectDic setObject:@(indexPath.row) forKey:@(self.imageIndex)];
        [collectionView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == self.collectionView){
        if ((scrollView.contentSize.width - (scrollView.contentOffset.x+scrollView.frame.size.width)) < -40) {
            if(self.selectIndex == 0){
                self.collectionView.bounces = NO;
                [self delegateSwipeAnimation: NO];
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
