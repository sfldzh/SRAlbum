//
//  SRAlbumTip.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/2/16.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit



public class SRTip: UIView {
    @IBOutlet weak var centerLayout: NSLayoutConstraint!
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    @IBOutlet weak var right: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var showView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var showIng = false
    private var afterWorkItem:DispatchWorkItem?
    
    private var tipStyle:SRTipStyleData!{
        didSet{
            self.showView.backgroundColor = tipStyle.backgroundColor
            self.titleLabel.textColor = tipStyle.titleColor
            self.descLabel.textColor = tipStyle.tipColor
            self.bottomLayout.isActive = tipStyle.showType == .bottom
            self.centerLayout.isActive = tipStyle.showType == .center
            self.top.constant = tipStyle.insets.top
            self.left.constant = tipStyle.insets.left
            self.bottom.constant = tipStyle.insets.bottom
            self.right.constant = tipStyle.insets.right
            self.stackView.spacing = tipStyle.spacing
            self.titleLabel.font = tipStyle.titleFont
            self.descLabel.font = tipStyle.tipFont
        }
    }
    open var completeHandle:((_ tap:Bool)->Void)?
    var showSec:Double = 2
    
    static func createView() -> SRTip?{
        let datas = sr_toast_bundle.loadNibNamed("SRTip", owner:nil, options:nil)!
        var view:SRTip?
        for data in datas {
            if let temp = data as? SRTip{
                view = temp
                break
            }
        }
        return view;
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
          return nil
        }
        return view
    }
    
    @objc private func tapDismiss(tap:UITapGestureRecognizer){
        self.tipDismiss(isTap: true)
    }
    
    private func tipDismiss(isTap:Bool) -> Void {
        UIView.animate(withDuration: self.tipStyle.dismissDuration, delay: 0, usingSpringWithDamping: self.tipStyle.springDamping, initialSpringVelocity: self.tipStyle.springVelocity, options: .curveEaseInOut, animations: {
            self.showView.transform = self.tipStyle.dismissTransform;
            self.showView.alpha = self.tipStyle.dismissFinalAlpha;
        }) { (finished) in
            self.showView.transform = .identity;
            self.showIng = false;
            self.removeFromSuperview()
            self.completeHandle?(isTap)
        }
    }
    
    func show(title:String? = nil, content:String, stype:SRTipStyleData) -> Void {
        self.tipStyle = stype
        self.setTipContent(title: title, value: content)
        self.showView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapDismiss(tap:))))
    }
    
    @objc open func setTipContent(title:String? = nil,value:String) -> Void {
        self.titleLabel.isHidden = title?.isEmpty ?? true
        self.titleLabel.text = title
        self.descLabel.text = value;
        if !self.showIng {
            self.showView.transform = CGAffineTransform.init(translationX: 0, y: -15)
            self.showView.alpha = 0.0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
                self.showView.transform = .identity
                self.showView.alpha = 1.0;
            }, completion: nil)
        }
        self.showIng = true
        if self.afterWorkItem != nil {
            self.afterWorkItem?.cancel()
            self.afterWorkItem = nil
        }
        self.afterWorkItem = DispatchWorkItem.init {[weak self] in
            self?.tipDismiss(isTap:false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+self.showSec, execute: self.afterWorkItem!)
    }
    
    open func dismiss(){
        self.tipDismiss(isTap:false)
    }
    
}
