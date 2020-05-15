//
//  SRAlbumTip.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/2/16.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

class SRAlbumTipAnimating: NSObject {
    var dismissTransform:CGAffineTransform = CGAffineTransform.init(translationX: 0, y: -15)
    var showInitialTransform:CGAffineTransform = CGAffineTransform.init(translationX: 0, y: -15)
    var showFinalTransform:CGAffineTransform = .identity
    var springDamping:CGFloat = 0.7//阻尼率
    var springVelocity:CGFloat = 0.7//加速率
    var showInitialAlpha:CGFloat = 0.0
    var dismissFinalAlpha:CGFloat = 0.0
    var showDuration:TimeInterval = 0.5
    var dismissDuration:TimeInterval = 0.5
}

class SRAlbumTip: NSObject {
    var showIng = false
    private var afterWorkItem:DispatchWorkItem?
    let tipAnimating = SRAlbumTipAnimating()
    let showLabel:UILabel = {
        let showLabel:UILabel = UILabel.init()
        showLabel.textAlignment = .center
        showLabel.backgroundColor = UIColor.black
        showLabel.textColor = UIColor.white
        showLabel.layer.cornerRadius = 5.0
        showLabel.clipsToBounds = true
        showLabel.numberOfLines = 0
        showLabel.font = UIFont.systemFont(ofSize: 14)
        return showLabel
    }()
    
    static let sharedInstance = SRAlbumTip()
    
    func show(content:String) -> Void {
        if self.showLabel.superview == nil {
            SRHelper.getWindow()?.addSubview(self.showLabel);
        }
        let contentSize = SRHelper.textSize(text: content, font: self.showLabel.font, maxSize: CGSize.init(width: Appsize().width-30, height: 200), compensationSize: CGSize.init(width: 10, height: 15))
        self.showLabel.text = content;
        self.showLabel.frame = CGRect.init(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        self.showLabel.center = CGPoint.init(x: Appsize().width/2.0, y: Appsize().height-(80+contentSize.height))
        if !self.showIng {
            self.showLabel.transform = self.tipAnimating.showInitialTransform;
            self.showLabel.alpha = self.tipAnimating.showInitialAlpha;
            UIView.animate(withDuration: self.tipAnimating.showDuration, delay: 0, usingSpringWithDamping: self.tipAnimating.springDamping, initialSpringVelocity: self.tipAnimating.springVelocity, options: .curveEaseInOut, animations: {
                self.showLabel.transform = self.tipAnimating.showFinalTransform
                self.showLabel.alpha = 1.0;
            }, completion: nil)
        }
        self.showIng = true;
        if self.afterWorkItem != nil {
            self.afterWorkItem?.cancel();
            self.afterWorkItem = nil;
        }
        self.afterWorkItem = DispatchWorkItem.init {[weak self] in
            self?.dismiss();
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2, execute: self.afterWorkItem!);
    }
    
    func dismiss() -> Void {
        UIView.animate(withDuration: self.tipAnimating.dismissDuration, delay: 0, usingSpringWithDamping: self.tipAnimating.springDamping, initialSpringVelocity: self.tipAnimating.springVelocity, options: .curveEaseInOut, animations: {
            self.showLabel.transform = self.tipAnimating.dismissTransform;
            self.showLabel.alpha = self.tipAnimating.dismissFinalAlpha;
        }) { (finished) in
            self.showLabel.removeFromSuperview()
            self.showLabel.transform = .identity;
            self.showIng = false;
        }
    }
    
    
}
