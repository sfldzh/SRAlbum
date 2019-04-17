//
//  ShowTableViewCell.m
//  T
//
//  Created by 施峰磊 on 2019/3/18.
//  Copyright © 2019 施峰磊. All rights reserved.
//

#import "ShowTableViewCell.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface ShowTableViewCell()
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *image_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;

@end

@implementation ShowTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setImage:(UIImage *)image{
    CGSize imageSize;
    if ([image isKindOfClass:[NSData class]]) {
        FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:(NSData *)image];
        self.image_view.animatedImage = animatedImage;
        imageSize = animatedImage.size;
    }else{
        self.image_view.image = image;
        imageSize = image.size;
    }
    self.height.constant = imageSize.height*[UIScreen mainScreen].bounds.size.width/imageSize.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
