//
//  AlbumGroupTableViewCell.h
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlbumGroupTableViewCell : UITableViewCell
@property (nonatomic, strong) PHAssetCollection *data;
@end

NS_ASSUME_NONNULL_END
