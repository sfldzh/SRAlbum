//
//  SRAldumGroupTableViewCell.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/20.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import Photos

class SRAldumGroupTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var data:PHAssetCollection?{
        didSet{
            self.icon.image = UIImage.named(name: "sr_default_image")
            if let asset = self.data?.assets.firstObject {
                asset.requestImage(size: CGSize.init(width: 60, height: 60), resizeMode: .fast) { [weak self](image, info) in
                    self?.icon.image = image;
                }
            }
            self.titleLabel.text = data?.localizedTitle;
            self.countLabel.text = "（\(self.data?.assets.count ?? 0)）"
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
