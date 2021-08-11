//
//  CIFeatureRect.swift
//  SRAlbum
//
//  Created by Danica on 2021/8/2.
//  Copyright © 2021 施峰磊. All rights reserved.
//

//import Foundation
import UIKit

struct CIFeatureRect {
    var topLeft:CGPoint
    var topRight:CGPoint
    var bottomRight:CGPoint
    var bottomLeft:CGPoint
}
func transFullfromRealRect(previewRect:CGRect,imageRect:CGRect,isUICoordinate:Bool, topLeft:CGPoint,topRight:CGPoint,bottomLeft:CGPoint,bottomRight:CGPoint) -> CIFeatureRect {
    let xValue = previewRect.size.width/imageRect.size.width
    let yValue = previewRect.size.height/imageRect.size.height
    let p1 = CGPoint.init(x: topLeft.x*xValue, y: topLeft.y*yValue)
    let p2 = CGPoint.init(x: topRight.x*xValue, y: topRight.y*yValue)
    let p3 = CGPoint.init(x: bottomRight.x*xValue, y: bottomRight.y*yValue)
    let p4 = CGPoint.init(x: bottomLeft.x*xValue, y: bottomLeft.y*yValue)
    
    return CIFeatureRect(topLeft: p2, topRight: p3, bottomRight: p4, bottomLeft: p1)
}


func transfromRealRect(previewRect:CGRect,imageRect:CGRect,isUICoordinate:Bool, topLeft:CGPoint,topRight:CGPoint,bottomLeft:CGPoint,bottomRight:CGPoint) -> CIFeatureRect {
    let deltaX = previewRect.size.width/imageRect.size.width
    let deltaY = previewRect.size.height/imageRect.size.height
    var transform = CGAffineTransform.init(translationX: 0.0, y: previewRect.size.height)
    if isUICoordinate {
        transform = transform.scaledBy(x: 1, y: -1)
    }
    transform = transform.scaledBy(x: deltaX, y: deltaY)

    return CIFeatureRect(topLeft: __CGPointApplyAffineTransform(topLeft, transform), topRight: __CGPointApplyAffineTransform(topRight, transform), bottomRight: __CGPointApplyAffineTransform(bottomRight, transform), bottomLeft: __CGPointApplyAffineTransform(bottomLeft, transform))
    
}
