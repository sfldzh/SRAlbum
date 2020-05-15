//
//  SRAlbumSelect.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/22.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

@IBDesignable class SRAlbumSelect: UIControl {
    //TODO: 普通状态图片
    @IBInspectable open var image:UIImage?{
        didSet{
            self.imageView.image = image;
        }
    }
    
    //TODO: 文字
    @IBInspectable open var title:String?{
        didSet{
            self.titleLabel.text = title;
        }
    }
    
    //TODO: 文字字号
    @IBInspectable open var font:UIFont?{
        didSet{
            self.titleLabel.font = font;
        }
    }
    
    //TODO: 文字颜色
    @IBInspectable open var textColor:UIColor?{
        didSet{
            self.titleLabel.textColor = textColor;
        }
    }
    
    @IBInspectable open var textBackgroundColor:UIColor?{
        didSet{
            self.titleLabel.backgroundColor = textBackgroundColor;
        }
    }
    
    private let imageView:UIImageView = {
        let imageView:UIImageView = UIImageView.init(frame: CGRect.zero);
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let titleLabel:UILabel = {
        let titleLabel:UILabel = UILabel.init(frame: CGRect.zero);
        titleLabel.textColor = UIColor.white;
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = .center;
        titleLabel.clipsToBounds = true;
        return titleLabel
    }()
    

    override var isSelected: Bool{
        didSet{
            self.imageView.isHidden = !self.isSelected;
            self.titleLabel.isHidden = self.isSelected;
        }
    }
    
    
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
        let interval:CGFloat = 10
        self.imageView.frame = CGRect.init(x: interval, y: interval, width: self.bounds.width - (interval*2.0), height: self.bounds.height - (interval*2.0))
        self.titleLabel.frame = self.imageView.frame
        self.titleLabel.layer.cornerRadius = self.titleLabel.frame.size.width/2.0
    }

}
