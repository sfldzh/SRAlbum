//
//  ImageCollectionViewCell.m
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import "SRHelper.h"

@interface ImageCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *flagImage;
@property (weak, nonatomic) IBOutlet UIImageView *selectImage;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setPhotoData:(PHAsset *)photoData{
    _photoData = photoData;
    if (!photoData.thumbnail){
        [SRHelper requestImageForAsset:photoData size:CGSizeMake(200, 200) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage * image, NSDictionary * info, BOOL isDegraded) {
            self.imageView.image = image;
            photoData.thumbnail = image;
        }];
    }else{
        self.imageView.image = photoData.thumbnail;
    }
    self.flagImage.image = [photoData badgeImage];
    self.timeLabel.hidden = [photoData ctassetsPickerIsPhoto];
    if (!self.timeLabel.hidden) {
        NSTimeInterval duration = photoData.duration;
        self.timeLabel.text = [NSString stringWithFormat:@"%02.0f:%02td", duration/60.f, (NSInteger)duration%60];
    }
}


- (void)setSelectType:(SRSelectType)selectType{
    _selectType = selectType;
    self.selectImage.hidden = selectType == SRSelectTypeNone || selectType == SRSelectTypeSelection;
    self.numberLabel.hidden = selectType != SRSelectTypeSelection;
}

- (void)setSelectIndex:(NSUInteger)selectIndex{
    if (selectIndex != 0 && !self.numberLabel.hidden) {
        self.numberLabel.text = [NSString stringWithFormat:@"%@",@(selectIndex)];
    }
}


- (IBAction)didClickAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didOperationAction:)]) {
        [self.delegate didOperationAction:self.photoData];
    }
}

@end
