//
//  TopSwitchButton.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/20.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

class TopSwitchButton: UIControl {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    /// TODO:获取顶部选择按钮
    static func createTopSwitchButton() -> TopSwitchButton?{
        let datas = bundle.loadNibNamed("TopSwitchButton", owner: nil, options: nil)!;
        var switchButton:TopSwitchButton?
        for data in datas {
            let temp = data as! NSObject
            if temp.isKind(of: TopSwitchButton.classForCoder()){
                switchButton = temp as? TopSwitchButton;
                break
            }
        }
        return switchButton;
    }
    
    override var isSelected: Bool{
        didSet{
            if oldValue != isSelected{
                UIView.animate(withDuration: 0.3) {
                    if self.isSelected {
                        self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                    }else{
                        self.imageView.transform = CGAffineTransform(rotationAngle: 0)
                    }
                }
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
