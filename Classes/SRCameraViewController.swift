//
//  SRCameraViewController.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2021/8/2.
//  Copyright © 2021 施峰磊. All rights reserved.
//

import UIKit
@objc public enum SRCameraType:Int{
    case Photo//普通拍照
    case Video//视频
}

class SRCameraViewController: UIViewController{
    @IBOutlet weak var cameraView: SRCameraView!
    @IBOutlet weak var qhBtn: UIButton!
    @IBOutlet weak var flashBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraView.install(isRectangleDetection: is_rectangle_detection)
        self.cameraView.startRunning()
        self.configerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func configerView(){
        self.qhBtn.isHidden = is_rectangle_detection
        if self.cameraView.flashMode == .auto {
            self.flashBtn.setImage(UIImage.init(named: "sr_camera_flash_auto_icon", in: bundle, compatibleWith: nil), for: .normal)
        }else if self.cameraView.flashMode == .on {
            self.flashBtn.setImage(UIImage.init(named: "sr_camera_flash_on_icon", in: bundle, compatibleWith: nil), for: .normal)
        }else if self.cameraView.flashMode == .off {
            self.flashBtn.setImage(UIImage.init(named: "sr_camera_flash_off_icon", in: bundle, compatibleWith: nil), for: .normal)
        }
        self.cameraView.result = {[weak self](image:UIImage?, _error:Error?) in
            if image != nil {
                if is_eidt {
                    self?.cameraView.stopRunning()
                    SRAlbumEidtView.createEidtView()?.show(data: image!, complete: { cutImage, eideView in
                        let hub = SRHelper.showHud(message: "处理中", addto: SRHelper.getWindow()!)
                        DispatchQueue.global().async {//图片压缩
                            let img:UIImage = SRHelper.imageZip(sourceImage:cutImage!, maxSize: max_size)
                            DispatchQueue.main.async {
                                SRHelper.hideHud(hud: hub)
                                eideView.dismiss()
                                SRAlbumData.sharedInstance.completeHandle?([img])
                                self?.dismiss(animated: true, completion: nil)
                            }
                        }
                    }, {
                        self?.cameraView.startRunning()
                    })
                }else{
                    let hub = SRHelper.showHud(message: "处理中", addto: SRHelper.getWindow()!)
                    DispatchQueue.global().async {//图片压缩
                        let img:UIImage = SRHelper.imageZip(sourceImage:image!, maxSize: max_size)
                        DispatchQueue.main.async {
                            SRHelper.hideHud(hud: hub)
                            SRAlbumData.sharedInstance.completeHandle?([img])
                        }
                    }
                }
            }else{
                SRAlbumData.sharedInstance.completeHandle?([])
            }
            if is_eidt == false {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func pzAction(_ sender: UIButton) {
        self.cameraView.photographOperation()
    }
    
    @IBAction func swithCameraAction(_ sender: UIButton) {
        self.cameraView.swithCamera()
    }

    @IBAction func flashAction(_ sender: UIButton) {
        if self.cameraView.flashMode == .off {
            self.cameraView.flashMode = .on
            self.flashBtn.setImage(UIImage.init(named: "sr_camera_flash_on_icon", in: bundle, compatibleWith: nil), for: .normal)
        }else if self.cameraView.flashMode == .on {
            self.cameraView.flashMode = .auto
            self.flashBtn.setImage(UIImage.init(named: "sr_camera_flash_auto_icon", in: bundle, compatibleWith: nil), for: .normal)
        }else if self.cameraView.flashMode == .auto {
            self.cameraView.flashMode = .off
            self.flashBtn.setImage(UIImage.init(named: "sr_camera_flash_off_icon", in: bundle, compatibleWith: nil), for: .normal)
        }
    }
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
