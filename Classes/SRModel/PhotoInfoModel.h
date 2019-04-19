//
//  PhotoInfoModel.h
//  SRSystemAlbum
//
//  Created by 惠龙e通1 on 2017/12/1.
//  Copyright © 2017年 Danica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface PhotoInfoModel : NSObject
@property (nonatomic, strong) PHAsset   *asset;//资源
@property (nonatomic, strong) UIImage   *thumbnail;//缩略图
@property (nonatomic, strong) UIImage   *showImage;//显示图
@property (nonatomic, strong) NSData    *showData;//GIF图片
@end
