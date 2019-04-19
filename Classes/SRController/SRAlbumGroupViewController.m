//
//  SRAlbumGroupViewController.m
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "SRAlbumGroupViewController.h"
#import "SRAlbumContentController.h"
#import "AlbumGroupTableViewCell.h"
#import "SRAlbumConfiger.h"
#import "SRHelper.h"
#import "SRAlbum.h"
#import "SRHub.h"

@interface SRAlbumGroupViewController ()<UITableViewDataSource, UITableViewDelegate,SRAlbumContentControllerDelegate,PHPhotoLibraryChangeObserver>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) SRAlbumContentController *albumContentController;
@property (nonatomic, strong) NSArray *groupList;
@property (nonatomic, assign) NSTimeInterval lastChangeTimeInterval;
@end

@implementation SRAlbumGroupViewController

- (void)dealloc{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configerView];
    [self addNotification];
    [self openShowPicList];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.groupList == nil) {
        [self getAssetCollections];
    }
}


- (void)addNotification{
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)configerView{
    self.title = @"照片";
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }else{
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    [self.tableView registerNib:[UINib nibWithNibName:@"AlbumGroupTableViewCell" bundle:nil] forCellReuseIdentifier:@"AlbumGroupTableViewCell"];
    
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getAssetCollections{
    SRHubView *hub;
    if (self.groupList == nil) {
        hub = [SRHub show];
    }
    [SRHelper fetchAlbumsCollectionBack:^(NSArray * _Nonnull collection) {
        if (hub) {
            [SRHub hidden:hub];
        }
        self.groupList = collection;
        [self changedAlbumContentController];
        [self.tableView reloadData];
    }];
}


- (void)openShowPicList{
    if ([SRAlbumConfiger singleton].isShowPicList) {
        PHAssetCollection *assetCollection = [self.groupList firstObject];
        SRAlbumContentController *vc = [[SRAlbumContentController alloc] initWithNibName:@"SRAlbumContentController" bundle:nil];
        vc.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        vc.delegate = self;
        vc.assetCollection = assetCollection;
        [self.navigationController pushViewController:vc animated:NO];
        self.albumContentController = vc;
    }
}

- (void)changedAlbumContentController{
    if (self.albumContentController) {
        PHAssetCollection *assetCollection = [self.groupList objectAtIndex:self.albumContentController.indexPath.row];
        self.albumContentController.assetCollection = assetCollection;
    }
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    if ((timeInterval - self.lastChangeTimeInterval) > 2) {
        self.lastChangeTimeInterval = timeInterval;
        [self getAssetCollections];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlbumGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumGroupTableViewCell" forIndexPath:indexPath];
    PHAssetCollection *assetCollection = [self.groupList objectAtIndex:indexPath.row];
    cell.data = assetCollection;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PHAssetCollection *assetCollection = [self.groupList objectAtIndex:indexPath.row];
    SRAlbumContentController *vc = [[SRAlbumContentController alloc] initWithNibName:@"SRAlbumContentController" bundle:nil];
    vc.indexPath = indexPath;
    vc.delegate = self;
    vc.assetCollection = assetCollection;
    [self.navigationController pushViewController:vc animated:YES];
    self.albumContentController = vc;
}


#pragma mark - SRAlbumContentControllerDelegate
/**
 TODO:相册照片获取
 
 @param images 图片列表
 */
- (void)didFinishAlbumContentPickingImages:(NSArray *)images{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishAlbumGroupPickingImages:)]) {
        [self.delegate didFinishAlbumGroupPickingImages:images];
    }
}

/**
 TODO:相册视频获取
 
 @param vedios 视频列表
 */
- (void)didFinishAlbumContentPickingVedios:(NSArray *)vedios{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishAlbumGroupPickingVedios:)]) {
        [self.delegate didFinishAlbumGroupPickingVedios:vedios];
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
