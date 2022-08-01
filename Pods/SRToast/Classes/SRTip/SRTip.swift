//
//  SRAlbumTip.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/2/16.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

public class SRTip: UIView {
    var showIng = false
    private var afterWorkItem:DispatchWorkItem?
    let showLabel:UILabel = {
        let showLabel:UILabel = UILabel.init()
        showLabel.textAlignment = .center
        showLabel.backgroundColor = UIColor.black
        showLabel.textColor = UIColor.white
        showLabel.layer.cornerRadius = 5.0
        showLabel.clipsToBounds = true
        showLabel.numberOfLines = 0
        showLabel.font = UIFont.systemFont(ofSize: 14)
        showLabel.isUserInteractionEnabled = true
        return showLabel
    }()
    
    private var tipStyle:SRTipStyleData!{
        didSet{
            self.showLabel.backgroundColor = tipStyle.backgroundColor
            self.showLabel.textColor = tipStyle.tipColor
        }
    }
    open var completeHandle:((_ tap:Bool)->Void)?
    var showSec:Double = 2
    
    static func createView() -> SRTip?{
        let datas = sr_toast_bundle.loadNibNamed("SRTip", owner:nil, options:nil)!;
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
            self.showLabel.transform = self.tipStyle.dismissTransform;
            self.showLabel.alpha = self.tipStyle.dismissFinalAlpha;
        }) { (finished) in
            self.showLabel.removeFromSuperview()
            self.showLabel.transform = .identity;
            self.showIng = false;
            self.removeFromSuperview()
            self.completeHandle?(isTap)
        }
    }
    
    func show(content:String, stype:SRTipStyleData) -> Void {
        self.tipStyle = stype
        self.setTipContent(value: content)
        self.showLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapDismiss(tap:))))
    }
    
    @objc open func setTipContent(value:String) -> Void {
        let viewSize = self.frame.size
        if self.showLabel.superview == nil {
            self.addSubview(self.showLabel);
        }
        let contentSize = SRToastTool.textSize(text: value, font: self.showLabel.font, maxSize: CGSize.init(width: viewSize.width-self.tipStyle.edgeInsets.left-self.tipStyle.edgeInsets.right, height: 200), compensationSize: CGSize.init(width: 10, height: 15))
        self.showLabel.text = value;
        self.showLabel.frame = CGRect.init(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        self.showLabel.center = CGPoint.init(x: viewSize.width/2.0, y: viewSize.height-(self.tipStyle.edgeInsets.bottom+contentSize.height))
        if !self.showIng {
            self.showLabel.transform = self.tipStyle.showInitialTransform;
            self.showLabel.alpha = self.tipStyle.showInitialAlpha;
            UIView.animate(withDuration: self.tipStyle.showDuration, delay: 0, usingSpringWithDamping: self.tipStyle.springDamping, initialSpringVelocity: self.tipStyle.springVelocity, options: .curveEaseInOut, animations: {
                self.showLabel.transform = self.tipStyle.showFinalTransform
                self.showLabel.alpha = 1.0;
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+self.showSec, execute: self.afterWorkItem!)
    }
    
    open func dismiss(){
        self.tipDismiss(isTap:false)
    }
    
}
