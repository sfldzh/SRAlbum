//
//  AssetImage.swift
//  SRAlbum
//A
//  Created by 施峰磊 on 2020/1/20.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import Photos
import UIKit

private var srAlbumEditedPic :Void?
extension PHAsset{
    var editedPic:UIImage? {
        set{
            objc_setAssociatedObject(self, &srAlbumEditedPic, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &srAlbumEditedPic) as? UIImage
        }
    }
    
    
    func requestImage(size:CGSize, resizeMode:PHImageRequestOptionsResizeMode, resultHandler:@escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> Void {
        let option:PHImageRequestOptions = PHImageRequestOptions.init()
        option.isNetworkAccessAllowed = true;
        option.resizeMode = resizeMode
        PHCachingImageManager.default().requestImage(for: self, targetSize: CGSize.init(width: (size.width * 2.0), height: (size.height * 2.0)), contentMode: .aspectFill, options: option) { (result, info) in
            resultHandler(result, info);
        }
    }
    
    
    func requestOriginalImage(resizeMode:PHImageRequestOptionsResizeMode = .fast, resultHandler:@escaping (Data?, [AnyHashable : Any]?) -> Void) -> Void {
        let option:PHImageRequestOptions = PHImageRequestOptions.init()
        option.isNetworkAccessAllowed = true;
        option.resizeMode = .fast
        option.isSynchronous = true;
        PHImageManager.default().requestImageData(for: self, options: option) { (imageData, dataUTI, orientation, info) in
            if imageData != nil{
                resultHandler(imageData, info)
            }else{
                resultHandler(nil, info);
            }
        }
    }
    
    func isPhoto() -> Bool {
        return self.mediaType == .image
    }
    
    func isGif() -> Bool {
        return (self.value(forKey: "filename") as! String).hasSuffix("GIF");
    }
    
    func isVideo() -> Bool {
        return self.mediaType == .video
    }
    
    func isHighVideo() -> Bool {
        return self.mediaType == .video && self.mediaSubtypes.contains(.videoHighFrameRate)
    }
    
    func isTimelapseVideo() -> Bool {
        return self.mediaType == .video && self.mediaSubtypes.contains(.videoTimelapse)
    }
}

extension UIImage{
    static func named(name:String)-> UIImage? {
        return UIImage.init(named: name, in: bundle, compatibleWith: nil)
    }
    
    func tagerSize(maxSize:CGSize) -> CGSize {
        let originalSize = self.size;
        let ratio = maxSize.width/originalSize.width;
        
        var heigt:CGFloat = 0;
        var width:CGFloat = 0;
        if (originalSize.width * ratio) > maxSize.height{
            heigt = maxSize.height
            width = (heigt/originalSize.height)*originalSize.width
        }else{
            width = maxSize.width
            heigt = originalSize.height * (width/originalSize.width);
        }
        return CGSize.init(width: width, height: heigt)
    }
}
