//
//  ViewController.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/17.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var input: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func didClick(_ sender: UIButton) {
        self.input.resignFirstResponder()
        self.openalbumOrCamera(type: Int(self.input.text ?? "") ?? 0)
    }
    
    private func openalbumOrCamera(type:Int){
        switch type {
        case 0:
            self.openCamera(cameraType: .Photo, isRectangleDetection: true, isEidt: true, maxSize: 200*1024) {[weak self] file in
                self?.fileshandel(file: file)
            }
            break
        case 1:
            self.openAlbum(assetType: .None, maxCount: 3, isEidt: true, isSort: false, maxSize: 200*1024) {[weak self] files in
                self?.fileshandel(files: files)
            }
            break
        case 2:
            SRAlbumWrapper.openCamera(tager: self, cameraType: .Photo, isRectangleDetection: false, isEidt: true, maxSize: 200*1024) { file in
                self.fileshandel(file: file)
            }
            break
        case 3:
            SRAlbumWrapper.openAlbum(tager: self, assetType: .Photo, maxCount: 2, isEidt: true, isSort: false, maxSize: 200*1024) { files in
                self.fileshandel(files: files)
            }
            break
        case 4:
            self.openFaceTrack(faceTaskCount: 3, maxSize: 200*1024) {[weak self] file in
                self?.fileshandel(file: file)
            }
            break
        default:
            SRAlbumWrapper.openFaceTrack(faceTaskCount: 3, tager: self, maxSize: 200*1024) { file in
                self.fileshandel(file: file)
            }
            break
        }
    }
    
    private func fileshandel(file:SRFileInfoData? = nil,files:[SRFileInfoData]? = nil) -> Void {
        if file != nil{
            switch file!.fileType {
            case .Image:
                print("照片")
                let vc = ResultViewController.init(nibName: "ResultViewController", bundle: Bundle.main)
                vc.images = [file!.image!]
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .Data:
                print("照片压缩数据")
                if let img = UIImage.init(data: file!.imageData!){
                    let vc = ResultViewController.init(nibName: "ResultViewController", bundle: Bundle.main)
                    vc.images = [img]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                break
            case .FileUrl:
                print("视频URL")
                break
            default:
                print("未知类型")
                break
            }
        }else if files != nil{
            var list:[UIImage] = []
            for file in files! {
                switch file.fileType {
                case .Image:
                    print("照片")
                    list.append(file.image!)
                    break
                case .Data:
                    print("照片压缩数据")
                    if let img = UIImage.init(data: file.imageData!){
                        list.append(img)
                    }
                    break
                case .FileUrl:
                    print("视频URL")
                    break
                default:
                    print("未知类型")
                    break
                }
            }
            let vc = ResultViewController.init(nibName: "ResultViewController", bundle: Bundle.main)
            vc.images = list
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
}

