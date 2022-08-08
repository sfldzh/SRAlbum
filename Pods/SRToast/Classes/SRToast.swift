//
//  SRToast.swift
//  SRToast
//
//  Created by 施峰磊 on 2022/6/15.
//

import Foundation
import UIKit

//#if COCOAPODS
//let sr_toast_bundle:Bundle! = Bundle.init(for: SRDummy.self)
//  .path(forResource: "SRToast", ofType: "bundle")
//  .map {
//    Bundle.init(path: $0)
//}!
//#else
//let sr_toast_bundle:Bundle! = Bundle.init(for: SRDummy.self)
//#endif

let sr_toast_bundle:Bundle = {
    let containnerBundle = Bundle.init(for: SRDummy.self);
    if let path = containnerBundle.path(forResource: "SRToast", ofType: "bundle"){
        if let toastBundle = Bundle.init(path: path) {
            return toastBundle
        }else{
            return Bundle.main
        }
    }else{
        return Bundle.main
    }
}()

fileprivate final class SRDummy {}

@objc open class SRToastManage:NSObject {
    @objc open var hubStyleData:SRHubStyleData = {
        let hubData = SRHubStyleData.init()
        hubData.isTranslucent = true
        return hubData
    }()
    
    @objc open var tipStyleData:SRTipStyleData = {
        let hubData = SRTipStyleData.init()
        return hubData
    }()
    /// TODO:单利
    @objc public static let shared: SRToastManage = {
        let instance = SRToastManage()
        return instance
    }()
    
    
}

public extension UIView{
    
    @discardableResult
    @objc func showHub(value:String? = nil, style:SRHubStyleData? = nil, filters:[CGRect]? = nil) -> SRHub {
        let hub = SRHub.createView()!
        hub.style = style
        hub.filters = filters ?? []
        hub.frame = self.bounds
        self.addSubview(hub)
//        hub.translatesAutoresizingMaskIntoConstraints = false
//        hub.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true  //顶部约束
//        hub.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true  //左端约束
//        hub.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true  //右端约束
//        hub.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true  //底部约束
        hub.setHubContent(value: value ?? "")
        return hub
    }
    
    @discardableResult
    @objc func showTip(title:String? = nil,value:String,style:SRTipStyleData? = nil,sec:Double = 2,completeHandle:((_ tap:Bool)->Void)? = nil) -> SRTip {
        if let tip:SRTip = self.subviews.first(where: { subView in
            return subView.isKind(of: SRTip.self)
        }) as? SRTip {
            tip.completeHandle = completeHandle
            tip.showSec = sec
            tip.frame = self.bounds
            tip.show(title:title, content: value, stype: style ?? SRToastManage.shared.tipStyleData)
            return tip
        }else{
            let tip = SRTip.createView()!
            tip.completeHandle = completeHandle
            tip.showSec = sec
            tip.frame = self.bounds
            self.addSubview(tip)
            tip.show(title:title, content: value, stype: style ?? SRToastManage.shared.tipStyleData)
            return tip
        }
    }
}
