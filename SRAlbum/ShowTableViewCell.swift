//
//  ShowTableViewCell.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/2/21.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

class ShowTableViewCell: UITableViewCell {
    @IBOutlet weak var showImageView: UIImageView!
    
    
    var showImage:UIImage?{
        didSet{
            self.showImageView.image = self.showImage;
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
