//
//  AlbumGroupTableViewCell.m
//  T
//
//  Created by 施峰磊 on 2019/3/5.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "AlbumGroupTableViewCell.h"
#import "PHAssetCollection+Info.h"
#import "PHAsset+Info.h"
#import "SRHelper.h"

@interface AlbumGroupTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation AlbumGroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setData:(PHAssetCollection *)data{
    _data = data;
    self.titleLabel.text = [NSString stringWithFormat:@"%@",data.localizedTitle];
    self.numberLabel.text = [NSString stringWithFormat:@"(%@)",@(data.assets.count)];
    PHAsset *photoData = data.assets.lastObject;
    if (photoData) {
        if (!photoData.thumbnail){
            [SRHelper requestImageForAsset:photoData size:CGSizeMake(200, 200) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage * image, NSDictionary * info, BOOL isDegraded) {
                self.iconView.image = image;
                photoData.thumbnail = image;
            }];
        }else{
            self.iconView.image = photoData.thumbnail;
        }
    }else{
        self.iconView.image = [UIImage imageNamed:@"sr_no_pic_icon"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
