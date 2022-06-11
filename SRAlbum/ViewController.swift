//
//  ViewController.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/17.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func didClick(_ sender: UIButton) {
        self.openalbumOrCamera(type: 4)
    }
    
    private func openalbumOrCamera(type:Int){
        let config:SREidtConfigure = SREidtConfigure.init()
        config.type = .Gird
        config.girdIndex = IndexPath.init(item: 4, section: 4)
        switch type {
        case 0:
            self.openCamera(cameraType: .Photo, isRectangleDetection: false, isEidt: true, maxSize: 200*1024, eidtConfigure: config) {[weak self] files in
                self?.fileshandel(files: files)
            }
            break
        case 1:
            self.openAlbum(assetType: .None, maxCount: 2, isEidt: true, isSort: false, maxSize: 200*1024, eidtConfigure: config) {[weak self] files in
                self?.fileshandel(files: files)
            }
            break
        case 2:
            SRAlbumWrapper.openCamera(tager: self, cameraType: .Photo, isRectangleDetection: false, isEidt: true, maxSize: 200*1024, eidtConfigure: config) { files in
                self.fileshandel(files: files)
            }
            break
        case 3:
            SRAlbumWrapper.openAlbum(tager: self, assetType: .Photo, maxCount: 2, isEidt: true, isSort: false, maxSize: 200*1024, eidtConfigure: config) { files in
                self.fileshandel(files: files)
            }
            break
        case 4:
            self.openFaceTrack(maxSize: 200*1024) {[weak self] files in
                self?.fileshandel(files: files)
            }
            break
        default:
            SRAlbumWrapper.openFaceTrack(tager: self) { files in
                self.fileshandel(files: files)
            }
            break
        }
    }
    
    private func fileshandel(files:[Any]) -> Void {
        for file in files{
            let type = type(of: file)
            if type == Data.self{
                print("照片压缩数据")
            }else if type == UIImage.self{
                print("照片")
            }else if type == URL.self{
                print("视频URL")
            }else{
                print("未知类型")
            }
        }
    }
}

