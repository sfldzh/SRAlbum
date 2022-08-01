//
//  SRToastTool.swift
//  SRToast
//
//  Created by 施峰磊 on 2022/6/15.
//

import Foundation
import UIKit

class SRToastTool{
    /// TODO:计算文字文本的尺寸
    /// - Parameters:
    ///   - text: 文字文本
    ///   - font: 字号
    ///   - maxSize: 最大尺寸
    ///   - compensationSize: 补偿尺寸
    static func textSize(text:String, font:UIFont, maxSize:CGSize, compensationSize:CGSize)->CGSize{
        let attributes = [NSAttributedString.Key.font:font];
        var textSize = text.boundingRect(with: CGSize.init(width: (maxSize.width-compensationSize.height), height: maxSize.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:attributes, context: nil).size;
        textSize.width = CGFloat(ceilf(Float(textSize.width + compensationSize.width)));
        textSize.height = CGFloat(ceilf(Float(textSize.height + compensationSize.height)));
        return textSize;
    }
}
