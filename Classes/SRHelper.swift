//
//  SRHelper.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/20.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import MBProgressHUD

class SRHelper {
    
    /// 时间转换
    /// - Parameter timeSecond: 时间
    static func convertTimeSecond(timeSecond : TimeInterval) -> String {
        var string:String = "";
        let sec:UInt64 = UInt64(timeSecond);
        if sec < 60 {
            string = String(format: "00:%02zd",sec)
        } else if sec >= 60 && sec < 3600 {
            string = String(format: "%02zd:%02zd",sec/60, sec%60)
        } else {
            string = String(format: "%02zd:%02zd:%02zd",sec/3600, (sec%3600)/60, sec%60)
        }
        return string;
    }
    
    
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
    
    
    static func getWindow() -> UIWindow? {
        var window:UIWindow? = nil
        if #available(iOS 13.0, *) {
            for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
                if windowScene.activationState == .foregroundActive {
                    window = windowScene.windows.first
                    break
                }
            }
        } else {
            window = UIApplication.shared.keyWindow
        }
        
        return window
    }
    
    static func showHud(message:String, addto view:UIView) -> MBProgressHUD{
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = message;
        return hud;
    }
    
    static func hideHud(hud:MBProgressHUD?){
        hud?.hide(animated: true);
    }
    
    
    /// TODO:图片压缩
    /// - Parameters:
    ///   - sourceImage: 源图片
    ///   - imageData: 源图片数据
    ///   - maxSize: 最大M数
    static func imageZip(sourceImage:UIImage, maxSize:Int)->UIImage{
        if maxSize > 0 {
            var compression:CGFloat = 1.0
            var data = sourceImage.jpegData(compressionQuality: compression)!
            print("初始 : \(data.count/1024) KB")
            if (data.count < maxSize){
                return sourceImage
            }
            
            var scale:CGFloat = 1;
            var lastLength:CGFloat = 0;
            
            for _ in 0...6 {
                compression = scale / 2;
                data = sourceImage.jpegData(compressionQuality: compression)!
                print("质量压缩中： \(data.count/1024) KB")
                if (data.count>Int(0.95*lastLength)) {
                    break;//当前压缩后大小和上一次进行对比，如果大小变化不大就退出循环
                }
                if (data.count < maxSize){
                    break;//当前压缩后大小和目标大小进行对比，小于则退出循环
                }
                scale = compression;
                lastLength = CGFloat(data.count);
            }
            print("压缩图片质量后: \(data.count/1024) KB")
            if (data.count < maxSize){
                print("压缩完成： \(data.count/1024) KB")
                return sourceImage
            }
            
            var resultImage = UIImage.init(data: data)!
            var lastDataLength = 0
            while (data.count > maxSize && data.count != lastDataLength) {
                lastDataLength = data.count;
                let ratio:Float = Float(maxSize/data.count)
                print("Ratio =  \(ratio)")
                let size = CGSize.init(width: resultImage.size.width * CGFloat(sqrtf(ratio)), height: resultImage.size.height * CGFloat(sqrtf(ratio)))
                UIGraphicsBeginImageContext(size);
                sourceImage.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height));
                resultImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext();
            }
            
            return resultImage;
        }else{
            return sourceImage;
        }
    }
    
    /// TODO:图片的尺寸压缩
    /// - Parameters:
    ///   - sourceImage: 源图片
    ///   - ratio: 比例
    static func imageSizeZip(sourceImage:UIImage, ratio:CGFloat)->UIImage{
        if sourceImage.size.width > sourceImage.size.height * 2 || sourceImage.size.height > sourceImage.size.width * 2{//长图
            return sourceImage
        }else{
            let tagerSize = CGSize.init(width: sourceImage.size.width * ratio, height: sourceImage.size.height * ratio)
            UIGraphicsBeginImageContext(tagerSize);
            sourceImage.draw(in: CGRect.init(x: 0, y: 0, width: tagerSize.width, height: tagerSize.height));
            let resultImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext();
            return resultImage
            
//            let maxSize = CGSize.init(width: 2448.0, height: 3264.0)
//            if sourceImage.size.width  > maxSize.width || sourceImage.size.height  > maxSize.height {
//                var tagerSize:CGSize = CGSize.zero
//                if sourceImage.size.width > sourceImage.size.height{//横图
//                    tagerSize.width = maxSize.width
//                    tagerSize.height = sourceImage.size.height * (maxSize.width/sourceImage.size.width)
//                }else{//竖图
//                    tagerSize.height = maxSize.height
//                    tagerSize.width = sourceImage.size.width * (maxSize.height/sourceImage.size.height)
//                }
//                UIGraphicsBeginImageContext(tagerSize);
//                sourceImage.draw(in: CGRect.init(x: 0, y: 0, width: tagerSize.width, height: tagerSize.height));
//                let resultImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//                UIGraphicsEndImageContext();
//                return resultImage
//            }else{
//                return sourceImage
//            }
        }
        
    }
}
