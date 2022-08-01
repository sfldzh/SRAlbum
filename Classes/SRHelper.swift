//
//  SRHelper.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/20.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import SRToast
import AVFoundation

public class SRHelper:NSObject {
    
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
    
    static func cleanMov(url:URL){
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    
    /// TODO:图片压缩
    /// - Parameters:
    ///   - sourceImage: 源图片
    ///   - maxSize: 最大M数
    @objc public static func imageZip(sourceImage:UIImage, maxSize:Int)->Data{
        let data = self.resetSizeOfImageData(source_image: sourceImage, maxSize: maxSize / 1024)
//        if !data.isEmpty{
//            return UIImage.init(data: data as Data)!
//        }else{
//            return UIImage.init()
//        }
        return data
    }
    
    /// 压缩视频
    /// - Parameters:
    ///   - sourceUrl: 视频原地址
    ///   - tagerUrl: 视频目标地址
    ///   - result: 完成的回调
    @objc public static func videoZip(sourceUrl:URL, tagerUrl:URL?, result:((URL)->Void)?){
        let avAsset = AVAsset.init(url: sourceUrl)
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
        if compatiblePresets.contains(AVAssetExportPresetHighestQuality) {
            if let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPresetMediumQuality) {
                let pathUrl = (tagerUrl==nil) ? URL.init(fileURLWithPath: videoTemporaryZipDirectory(fileName: sourceUrl.lastPathComponent.replacingOccurrences(of: sourceUrl.pathExtension, with: "mp4"))) : tagerUrl
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
    
    /// 图片质量压缩
    /// - Parameters:
    ///   - image: 原来的图片
    ///   - maxLength: 最大内存
    /// - Returns: 压缩好的图片
    static func compressImageQuality(_ image: UIImage, toByte maxLength: Int) -> UIImage {
        var compression: CGFloat = 1
        guard var data = image.jpegData(compressionQuality: compression),
            data.count > maxLength else { return image }
//        print("Before compressing quality, image size =", data.count / 1024, "KB")
        
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = image.jpegData(compressionQuality: compression)!
//            print("Compression =", compression)
//            print("In compressing quality loop, image size =", data.count / 1024, "KB")
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
//        print("After compressing quality, image size =", data.count / 1024, "KB")
        return UIImage(data: data)!
    }
    
    /// 图片尺寸压缩
    /// - Parameters:
    ///   - image: 原来的图片
    ///   - maxLength: 最大内存
    /// - Returns: 压缩好的图片
    static func compressImageSize(_ image: UIImage, toByte maxLength: Int) -> UIImage {
        guard var data = image.jpegData(compressionQuality: 1) else { return image }
//        print("Before compressing size, image size =", data.count / 1024, "KB")
        
        var resultImage: UIImage = image
        var lastDataLength: Int = 0
        while data.count > maxLength, data.count != lastDataLength {
            lastDataLength = data.count
            let ratio: CGFloat = CGFloat(maxLength) / CGFloat(data.count)
//            print("Ratio =", ratio)
            let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)),
                                      height: Int(resultImage.size.height * sqrt(ratio)))
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            data = resultImage.jpegData(compressionQuality: 1)!
//            print("In compressing size loop, image size =", data.count / 1024, "KB")
        }
//        print("After compressing size loop, image size =", data.count / 1024, "KB")
        return resultImage
    }
    
    /// 图片尺寸和质量压缩
    /// - Parameters:
    ///   - source_image: 原来的图片
    ///   - maxLength: 最大内存
    /// - Returns: 压缩好的图片
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
//        print("After compressing size loop, image size =", finallImageData!.count / 1024, "KB")
        return finallImageData!
    }
    
    
    /// 图片尺寸和质量压缩
    /// - Parameters:
    ///   - source_image: 原来的图片
    ///   - maxLength: 最大内存
    /// - Returns: 压缩好的图片
    static func compressImage(_ image: UIImage, toByte maxLength: Int) -> UIImage {
        var compression: CGFloat = 1
        guard var data = image.jpegData(compressionQuality: compression),
            data.count > maxLength else { return image }
//        print("Before compressing quality, image size =", data.count / 1024, "KB")
        
        // Compress by size
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = image.jpegData(compressionQuality: compression)!
//            print("Compression =", compression)
//            print("In compressing quality loop, image size =", data.count / 1024, "KB")
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
//        print("After compressing quality, image size =", data.count / 1024, "KB")
        var resultImage: UIImage = UIImage(data: data)!
        if data.count < maxLength { return resultImage }
        
        // Compress by size
        var lastDataLength: Int = 0
        while data.count > maxLength, data.count != lastDataLength {
            lastDataLength = data.count
            let ratio: CGFloat = CGFloat(maxLength) / CGFloat(data.count)
//            print("Ratio =", ratio)
            let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)),
                                      height: Int(resultImage.size.height * sqrt(ratio)))
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            data = resultImage.jpegData(compressionQuality: compression)!
//            print("In compressing size loop, image size =", data.count / 1024, "KB")
        }
//        print("After compressing size loop, image size =", data.count / 1024, "KB")
        return resultImage
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
            tempData = tempFinallImageData
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
