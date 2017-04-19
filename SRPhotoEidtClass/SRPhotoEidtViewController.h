//
//  SRPhotoEidtViewController.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/17.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRPhotoEidtViewDelegate.h"

@interface SRPhotoEidtViewController : UIViewController
@property (nonatomic, strong) NSArray *imageSource;
@property (nonatomic, weak)id<SRPhotoEidtViewDelegate>delegate;

@end
