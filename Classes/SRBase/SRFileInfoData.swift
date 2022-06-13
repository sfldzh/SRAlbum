//
//  SRFileInfoData.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2022/6/13.
//  Copyright © 2022 施峰磊. All rights reserved.
//

import UIKit

@objc public class SRFileInfoData: NSObject {
    @objc open var fileType:SRResultType = .Image
    @objc open var  image:UIImage?
    @objc open var imageData:Data?
    @objc open var fileUrl:URL?
    
    init(fileType:SRResultType, _ image:UIImage?, _ imageData:Data?, _ fileUrl:URL?){
        self.fileType = fileType
        self.image = image
        self.imageData = imageData
        self.fileUrl = fileUrl
    }
}
