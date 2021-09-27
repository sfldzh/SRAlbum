//
//  SRHelper.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/20.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import MBProgressHUD
import AVFoundation

class SRHelper {
    
    /// 时间转换
    /// - Parameter timeSecond: 时间
    static func convertTimeSecond(timeSecond : TimeInterval) -> String {
        var string:String = "";
        let sec:Int = Int(timeSecond);
        if sec <= 0 {
            string = "00:00"
        } else if sec < 60 {
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
                if windowScene.activationState == .foregroundActive || windowScene.activationState == .foregroundInactive {
                    for temp in windowScene.windows {
                        if !temp.isHidden && NSStringFromClass(temp.classForCoder) == "UIWindow" {
                            window = temp
                            break
                        }
                    }
                    if (window != nil) {
                        break
                    }
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
    
    static func cleanMov(url:URL){
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    
    /// TODO:图片压缩
    /// - Parameters:
    ///   - sourceImage: 源图片
    ///   - imageData: 源图片数据
    ///   - maxSize: 最大M数
    static func imageZip(sourceImage:UIImage, maxSize:Int)->UIImage{
        let data = self.resetSizeOfImageData(source_image: sourceImage, maxSize: maxSize / 1024)
        return UIImage.init(data: data as Data)!
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
    
    
    /// 压缩视频
    /// - Parameters:
    ///   - sourceUrl: 视频原地址
    ///   - tagerUrl: 视频目标地址
    ///   - result: 完成的回调
    static func videoZip(sourceUrl:URL, tagerUrl:URL?, result:((URL)->Void)?){
        let avAsset = AVAsset.init(url: sourceUrl)
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
        if compatiblePresets.contains(AVAssetExportPresetHighestQuality) {
            if let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPresetMediumQuality) {
                let pathUrl = (tagerUrl==nil) ? URL.init(fileURLWithPath: videoTemporaryZipDirectory(fileName: sourceUrl.lastPathComponent)) : tagerUrl
                exportSession.outputURL = pathUrl
                exportSession.outputFileType = .mp4
                exportSession.shouldOptimizeForNetworkUse = true
                exportSession.exportAsynchronously {
                    cleanMov(url: sourceUrl)
                    if result != nil {
                        result!(pathUrl!)
                    }
                }
            }
        }
    }
    
    
    static func resetSizeOfImageData(source_image: UIImage!, maxSize: Int) -> Data {
        //先判断当前质量是否满足要求，不满足再进行压缩
        var finallImageData = source_image.jpegData(compressionQuality: 1.0)
        let sizeOrigin  = finallImageData?.count
        let sizeOriginKB = sizeOrigin! / 1024
        if sizeOriginKB <= maxSize {
            return finallImageData!
        }
        //先调整分辨率
        var defaultSize = CGSize(width: 1024, height: 1024)
        let newImage = self.newSizeImage(size: defaultSize, source_image: source_image)
        finallImageData = newImage.jpegData(compressionQuality: 1.0);
        //保存压缩系数
        let compressionQualityArr = NSMutableArray()
        let avg = CGFloat(1.0/250)
        var value = avg
        var i = 250
        repeat {
            i -= 1
            value = CGFloat(i)*avg
            compressionQualityArr.add(value)
        } while i >= 1
        /*
         调整大小
         说明：压缩系数数组compressionQualityArr是从大到小存储。
         */
        //思路：使用二分法搜索
        finallImageData = self.halfFuntion(arr: compressionQualityArr.copy() as! [CGFloat], image: newImage, sourceData: finallImageData!, maxSize: maxSize)
        //如果还是未能压缩到指定大小，则进行降分辨率
        while finallImageData?.count == 0 {
            //每次降100分辨率
            if defaultSize.width-100 <= 0 || defaultSize.height-100 <= 0 {
                break
            }
            defaultSize = CGSize(width: defaultSize.width-100, height: defaultSize.height-100)
            let image = self.newSizeImage(size: defaultSize, source_image: UIImage.init(data: newImage.jpegData(compressionQuality: compressionQualityArr.lastObject as! CGFloat)!)!)
            finallImageData = self.halfFuntion(arr: compressionQualityArr.copy() as! [CGFloat], image: image, sourceData: image.jpegData(compressionQuality: 1.0)!, maxSize: maxSize)
        }
        return finallImageData!
    }
    
    // MARK: - 调整图片分辨率/尺寸（等比例缩放）
    static func newSizeImage(size: CGSize, source_image: UIImage) -> UIImage {
        var newSize = CGSize(width: source_image.size.width, height: source_image.size.height)
        let tempHeight = newSize.height / size.height
        let tempWidth = newSize.width / size.width
        if tempWidth > 1.0 && tempWidth > tempHeight {
            newSize = CGSize(width: source_image.size.width / tempWidth, height: source_image.size.height / tempWidth)
        } else if tempHeight > 1.0 && tempWidth < tempHeight {
            newSize = CGSize(width: source_image.size.width / tempHeight, height: source_image.size.height / tempHeight)
        }
        UIGraphicsBeginImageContext(newSize)
        source_image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    // MARK: - 二分法
    static func halfFuntion(arr: [CGFloat], image: UIImage, sourceData finallImageData: Data, maxSize: Int) -> Data? {
        var tempFinallImageData = finallImageData
        var tempData = Data.init()
        var start = 0
        var end = arr.count - 1
        var index = 0
        var difference = Int.max
        while start <= end {
            index = start + (end - start)/2
            tempFinallImageData = image.jpegData(compressionQuality: arr[index])!
            let sizeOrigin = tempFinallImageData.count
            let sizeOriginKB = sizeOrigin / 1024
//            print("当前降到的质量：\(sizeOriginKB)\n\(index)----\(arr[index])")
            if sizeOriginKB > maxSize {
                start = index + 1
            } else if sizeOriginKB < maxSize {
                if maxSize-sizeOriginKB < difference {
                    difference = maxSize-sizeOriginKB
                    tempData = tempFinallImageData
                }
                end = index - 1
            } else {
                break
            }
        }
        return tempData
    }
}
