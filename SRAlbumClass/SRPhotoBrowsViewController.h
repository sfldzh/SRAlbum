//
//  SRPhotoBrowsViewController.h
//  SRAlbum
//
//  Created by danica on 2017/4/8.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+Type.h"
#import "ALAsset+Type.h"

@protocol SRPhotoBrowsViewControllerDelegate <NSObject>


/**
  TODO:选择的已经改变

 @param indexpath 位置
 */
- (void)selectDidChangeIndexpath:(NSIndexPath *)indexpath;


/**
 TODO:已经点击了完成
 */
- (void)didClickFinishAction;

@end

@interface SRPhotoBrowsViewController : UIViewController
@property (nonatomic, weak) id<SRPhotoBrowsViewControllerDelegate>delegate;
@property (nonatomic, strong) PHFetchResult                 *fetchResult;
@property (nonatomic, strong) NSMutableArray                *fetchAlResult;
@property (nonatomic, strong) NSMutableArray                *selectPics;//选择的图片
@property (nonatomic, strong) NSIndexPath                   *showIndexPath;
@end
