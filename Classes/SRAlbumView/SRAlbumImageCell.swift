//
//  SRAlbumImageCell.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/20.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import Photos

protocol SRAlbumImageCellDelegate :NSObjectProtocol {
    /// TODO: 点击选择了资源
    /// - Parameters:
    ///   - data: 资源
    ///   - indexPath: 索引
    ///   - cell: cell视图
    func didClickSeletcImage(data:PHAsset, indexPath:IndexPath, cell:SRAlbumImageCell) -> Void
}

class SRAlbumImageCell: UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    weak var delegate:SRAlbumImageCellDelegate?
    var indexPath:IndexPath?
    
    
    var data:PHAsset?{
        didSet{
            self.icon.image = UIImage.named(name: "sr_default_image")
            if self.data?.isVideo() ?? false {
                self.timeLabel.text = SRHelper.convertTimeSecond(timeSecond: self.data?.duration ?? 0.0);
            }else{
                self.timeLabel.text = ""
            }
            self.infoView.isHidden = self.data?.isPhoto() ?? true
            
            if self.data?.editedPic == nil {
                self.data?.requestImage(size: CGSize.init(width: 60, height: 60), resizeMode: .fast) { [weak self](image, info) in
                   self?.icon.image = image;
                }
            }else{
                self.icon.image = self.data?.editedPic;
            }
        }
    }
    
    func configer(index:Int) -> Void {
        self.indexLabel.isHidden = index == 0;
        if index != 0 {
            self.indexLabel.text = "\(index)"
        }
    }
    
    @IBAction func didClickImage(_ sender: UIButton) {
        self.delegate?.didClickSeletcImage(data: self.data!, indexPath: self.indexPath!, cell: self);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
