//
//  VButton.swift
//  XibFrame
//
//  Created by 施峰磊 on 2020/1/14.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

@IBDesignable class VButton: UIControl {
    //TODO: 普通状态图片
    @IBInspectable open var image:UIImage?{
        didSet{
            if !self.isSelected {
                self.imageView.image = image;
            }
        }
    }
    
    //TODO: 选择状态图片
    @IBInspectable open var selectImage:UIImage?{
        didSet{
            if self.isSelected {
                self.imageView.image = selectImage;
            }
        }
    }
    
    //TODO: 文字
    @IBInspectable open var title:String?{
        didSet{
            self.titleLabel.text = title;
        }
    }
    
    //TODO: 文字颜色
    @IBInspectable open var textColor:UIColor?{
        didSet{
            self.titleLabel.textColor = textColor;
        }
    }
    
    //TODO: 文字字号
    @IBInspectable open var font:UIFont?{
        didSet{
            self.titleLabel.font = font;
        }
    }
    
    //TODO: 是否是选中状态
    @IBInspectable open var isSelect: Bool = false{
        didSet{
            self.isSelected = self.isSelect
            self.imageView.image = self.isSelected ? selectImage : image;
        }
    }
    
    private let imageView:UIImageView = {
        let imageView:UIImageView = UIImageView.init(frame: CGRect.zero);
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel:UILabel = {
        let titleLabel:UILabel = UILabel.init(frame: CGRect.zero);
        titleLabel.textColor = UIColor.black;
        titleLabel.textAlignment = .center;
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.addViews();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        self.addViews();
    }
    
    private func addViews() -> Void {
        self.addSubview(self.imageView);
        self.addSubview(self.titleLabel);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.titleLabel.frame = CGRect.init(x: 0, y: self.bounds.height-20, width: self.bounds.width, height: 20);
        self.imageView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-30);
    }
}
