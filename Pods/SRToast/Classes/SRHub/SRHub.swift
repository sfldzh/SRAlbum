//
//  SRHub.swift
//  SRToast
//
//  Created by 施峰磊 on 2022/6/15.
//

import UIKit

open class SRHub: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    
    open var style:SRHubStyleData?{
        didSet{
            if style != nil{
                self.configerStyle(styleData: style!)
            }
        }
    }
    open var value:String = ""
    open var filters:[CGRect] = []
    
    static func createView() -> SRHub?{
        let datas = sr_toast_bundle.loadNibNamed("SRHub", owner:nil, options:nil)!;
        var view:SRHub?
        for data in datas {
            if let temp = data as? SRHub{
                view = temp
                break
            }
        }
        return view;
    }
    
    private func configer() -> Void {
        self.indicatorView.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            self.indicatorView.style = .large
        }else{
            self.indicatorView.style = .whiteLarge
        }
        self.backgroundColor = UIColor.clear
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.configer()
        self.configerStyle(styleData: self.style ?? SRToastManage.shared.hubStyleData)
        self.indicatorView.startAnimating()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.filters.contains(where: { rect in
            return rect.contains(point)
        }) {
            return nil
        }else{
            return super.hitTest(point, with: event)
        }
    }
    
    private func configerStyle(styleData:SRHubStyleData) -> Void {
        if styleData.isTranslucent{
            self.effectView.isHidden = false
            self.effectView.effect = UIBlurEffect.init(style: styleData.isDark ? .dark : .extraLight)
            if styleData.isDark{
                self.indicatorView.color = UIColor.white
                self.tipLabel.textColor = UIColor.white
            }else{
                self.indicatorView.color = UIColor.init(white: 0.0, alpha: 0.7)
                self.tipLabel.textColor = UIColor.init(white: 0.0, alpha: 0.7)
            }
        }else{
            self.effectView.isHidden = true
            self.contentView.backgroundColor = styleData.backgroundColor
            self.indicatorView.color = styleData.indicatorColor
            self.tipLabel.textColor = styleData.tipColor
        }
    }
    
    @objc open func setHubContent(value:String){
        self.tipLabel.isHidden = value.isEmpty ? true : false
        self.tipLabel.text = value
        self.layoutIfNeeded()
        DispatchQueue.main.async {
            self.contentWidth.constant = self.contentView.frame.height
            self.layoutIfNeeded()
        }
    }
    
    @objc open func remove(){
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { isFinish in
            self.removeFromSuperview()
        }
    }

}
