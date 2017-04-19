//
//  PiecewiseView.h
//  SRAlbum
//
//  Created by 施峰磊 on 2017/4/17.
//  Copyright © 2017年 sfl. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PiecewiseViewDelegate<NSObject>

/**
 TODO:已经选择序号

 @param index 序号
 */
- (void)didselectindex:(NSInteger)index;

@end

@interface PiecewiseView : UIView
@property (nonatomic, strong) NSArray               *buttons;
@property (nonatomic, strong) UIColor               *ordinaryColor;//未选中颜色
@property (nonatomic, strong) UIColor               *selectedColor;//选中颜色
@property (nonatomic, assign) NSUInteger            selectIndex;
@property (nonatomic, weak) id<PiecewiseViewDelegate>delegate;
@end
