//
//  SREidtConfigeure.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2021/11/16.
//  Copyright © 2021 施峰磊. All rights reserved.
//

import UIKit

@objc public enum SRCutType:Int{
    case None//默认
    case Circular//圆形
    case Square//正方形
    case Gird//九宫格
}

@objc public class SREidtConfigure: NSObject {
    @objc open var type:SRCutType = .None
    @objc open var girdIndex:IndexPath = IndexPath.init(item: 1, section: 1)
}
