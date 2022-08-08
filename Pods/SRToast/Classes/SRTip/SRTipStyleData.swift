//
//  SRTipStyleData.swift
//  SRToast
//
//  Created by 施峰磊 on 2022/6/15.
//

import Foundation
import UIKit

@objc public enum SRTipType:Int{
    case bottom
    case center
}

@objc public class SRTipStyleData: SRStyleData {
    @objc open var dismissTransform:CGAffineTransform = CGAffineTransform.init(translationX: 0, y: -15)
    @objc open var showInitialTransform:CGAffineTransform = CGAffineTransform.init(translationX: 0, y: -15)
    @objc open var showFinalTransform:CGAffineTransform = .identity
    @objc open var springDamping:CGFloat = 0.7//阻尼率
    @objc open var springVelocity:CGFloat = 0.7//加速率
    @objc open var showInitialAlpha:CGFloat = 0.0
    @objc open var dismissFinalAlpha:CGFloat = 0.0
    @objc open var showDuration:TimeInterval = 0.5
    @objc open var dismissDuration:TimeInterval = 1
    @objc open var edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 15, bottom: 15, right: 60)
    @objc open var showType:SRTipType = .bottom
    @objc open var insets:UIEdgeInsets = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
    @objc open var spacing:CGFloat = 15
    @objc open var titleFont:UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    @objc open var tipFont:UIFont = UIFont.systemFont(ofSize: 17, weight: .medium)
}
