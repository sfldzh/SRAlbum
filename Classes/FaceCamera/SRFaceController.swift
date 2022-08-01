//
//  SRFaceController.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2022/6/11.
//  Copyright © 2022 施峰磊. All rights reserved.
//

import UIKit

class SRFaceController:UIViewController ,SRFaceViewDelegate {
    @IBOutlet weak var faceView: SRFaceView!
    var faceTaskCount:Int = 2
    deinit {
        SRAlbumData.free();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.faceView.faceTaskCount = self.faceTaskCount
        self.faceView.install(delegate: self) {[weak self] in
            self?.faceView.startRunning()
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    // MARK: - FaceViewDelegate
    func faceTrackFinish(image: UIImage) {
        if SRAlbumData.sharedInstance.isZip{
            let hub = self.view.showHub(value: "处理中")
            DispatchQueue.global().async {//图片压缩
                let imgData:Data = SRHelper.imageZip(sourceImage:image, maxSize: max_size)
                DispatchQueue.main.async {
                    hub.remove()
                    let infoData = SRFileInfoData.init(fileType: .Data, nil, imgData, nil)
                    SRAlbumData.sharedInstance.completeHandle?(infoData)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            let infoData = SRFileInfoData.init(fileType: .Image, image, nil, nil)
            SRAlbumData.sharedInstance.completeHandle?(infoData)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
