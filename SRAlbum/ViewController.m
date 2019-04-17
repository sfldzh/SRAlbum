//
//  ViewController.m
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/6.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import "ViewController.h"
#import "SRAlbumViewController.h"
#import "ShowViewController.h"


@interface ViewController ()<SRAlbumViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *menuList;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self configerView];
}


- (void)initData{
    self.title = @"首页";
    self.menuList = @[@"相册任意资源类型不用编辑",
                      @"相册图片类型不用编辑",
                      @"相册视频类型不用编辑",
                      @"相册任意资源类型编辑",
                      @"相册图片类型编辑",
                      @"相册视频类型编辑",
                      @"相机任意资源类型不用编辑",
                      @"相机图片类型不用编辑",
                      @"相机视频类型",
                      @"相机任意资源类型编辑",
                      @"相机图片类型编辑"];
}

- (void)configerView{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AlbumTableViewCell"];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.menuList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.menuList objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumTableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = title;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < 11) {//相册操作
        SRDeviceType deviceType;
        SRAssetType assetType;
        BOOL isEidt = NO;
        if (indexPath.row == 0) {
            deviceType = SRDeviceTypeLibrary;
            assetType = SRAssetTypeNone;
            isEidt = NO;
        } else if (indexPath.row == 1) {
            deviceType = SRDeviceTypeLibrary;
            assetType = SRAssetTypePic;
            isEidt = NO;
        } else if (indexPath.row == 2) {
            deviceType = SRDeviceTypeLibrary;
            assetType = SRAssetTypeVideo;
            isEidt = NO;
        } else if (indexPath.row == 3) {
            deviceType = SRDeviceTypeLibrary;
            assetType = SRAssetTypeNone;
            isEidt = YES;
        } else if (indexPath.row == 4) {
            deviceType = SRDeviceTypeLibrary;
            assetType = SRAssetTypePic;
            isEidt = YES;
        } else if (indexPath.row == 5) {
            deviceType = SRDeviceTypeLibrary;
            assetType = SRAssetTypeVideo;
            isEidt = YES;
        } else if (indexPath.row == 6) {
            deviceType = SRDeviceTypeCamera;
            assetType = SRAssetTypeNone;
            isEidt = NO;
        } else if (indexPath.row == 7) {
            deviceType = SRDeviceTypeCamera;
            assetType = SRAssetTypePic;
            isEidt = NO;
        } else if (indexPath.row == 8) {
            deviceType = SRDeviceTypeCamera;
            assetType = SRAssetTypeVideo;
            isEidt = NO;
        } else if (indexPath.row == 9) {
            deviceType = SRDeviceTypeCamera;
            assetType = SRAssetTypeNone;
            isEidt = YES;
        } else {
            deviceType = SRDeviceTypeCamera;
            assetType = SRAssetTypePic;
            isEidt = YES;
        }
        
        SRAlbumViewController *vc = [[SRAlbumViewController alloc] initWithDeviceType:deviceType];
        vc.albumDelegate = self;
        vc.assetType = assetType;
        vc.maxItem = 9;
        vc.maxlength = 500*1024;
        vc.isEidt = isEidt;
        vc.isShowPicList = YES;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - SRAlbumViewControllerDelegate
/**
 TODO:相册照片获取
 
 @param picker 相册
 @param images 图片列表
 */
- (void)srAlbumPickerController:(SRAlbumViewController *)picker didFinishPickingImages:(NSArray *)images{
    ShowViewController *vc = [[ShowViewController alloc] initWithNibName:@"ShowViewController" bundle:nil];
    vc.datas = images;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 TODO:相册视频获取
 
 @param picker 相册
 @param vedios 视频列表
 */
- (void)srAlbumPickerController:(SRAlbumViewController *)picker didFinishPickingVedios:(NSArray *)vedios{
    NSLog(@"%@",vedios);
}

@end
