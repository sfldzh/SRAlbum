//
//  FilterCollectionViewCell.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/17.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCollectionViewCell : UICollectionViewCell
@property (nonatomic, assign) BOOL          isSelected;
@property (nonatomic, strong) NSString      *titleStr;
@property (nonatomic, strong) UIImageView   *imageView;
@end
