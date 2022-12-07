//
//  SRAlbum.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/17.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import Photos


@objc public enum SRResultType:Int{
    case Image
    case Data
    case GifData
    case FileUrl
}

var isMain:Bool = true;
//var bundle:Bundle?{
//    get{
//        let podBundle = Bundle.init(for: SRAlbumController.self)
//        let bundleURL = podBundle.url(forResource: "SRAlbum", withExtension: "bundle")
//        if bundleURL != nil {
//            let bundle = Bundle.init(url: bundleURL!)
//            isMain = false;
//            return bundle
//        }else{
//            isMain = true;
//            return Bundle.main
//        }
//    }
//}

let bundle:Bundle = {
    let containnerBundle = Bundle.init(for: SRAlbumController.self);
    if let path = containnerBundle.path(forResource: "SRAlbum", ofType: "bundle"){
        if let toastBundle = Bundle.init(path: path) {
            return toastBundle
        }else{
            return Bundle.main
        }
    }else{
        return Bundle.main
    }
}()


func videoTemporaryDirectory(fileName:String?) -> String{
    let folderPath = NSTemporaryDirectory() + "SRVedioCapture/"
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: folderPath) == false {
        try? fileManager.createDirectory(at: URL.init(fileURLWithPath: folderPath), withIntermediateDirectories: true, attributes: nil)
    }
    var name = ""
    if fileName != nil {
        name = fileName!
    }else{
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyyMMddHHmmssfff"
        name = formatter.string(from: Date.init(timeIntervalSinceNow: 0))
    }
    return folderPath + name + ".mp4"
}

func videoTemporaryZipDirectory(fileName:String?) -> String{
    let folderPath = NSTemporaryDirectory() + "SRVedioCaptureZip/"
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: folderPath) == false {
        try? fileManager.createDirectory(at: URL.init(fileURLWithPath: folderPath), withIntermediateDirectories: true, attributes: nil)
    }
    var name = ""
    if fileName != nil {
        name = fileName!
    }else{
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyyMMddHHmmssfff"
        name = formatter.string(from: Date.init(timeIntervalSinceNow: 0)) + ".mp4"
    }
    return folderPath + name
}


func Appsize() -> CGSize {
    return UIScreen.main.bounds.size;
}

var asset_type:SRAssetType = .None//.None：任意列席，.Photo：图片类型，.Video：视频类型；默认为.None
var camera_type:SRCameraType = .Photo//
var max_count = 0;//取图片或者视频的数量；默认为1
var max_size = 0;//限制图片的M数，；默认为2*1024*1024，也就是2M
var is_eidt = false;//是否要编辑；默认为false
var is_sort = false;//是否要排序输出图片；默认为false
var is_rectangle_detection = false;//开启矩形检测


public class SRAlbumWrapper:NSObject{
    
    @available(iOS 10, *)
    @objc public class func openAlbum(tager:UIViewController, assetType:SRAssetType = .None, maxCount:Int = 1, isEidt:Bool = false, isSort:Bool = false, maxSize:Int = 2*1024*1024, completeHandle:((_ files:[SRFileInfoData])->Void)?)->Void{
        tager.openAlbum(assetType: assetType, maxCount: maxCount, isEidt: isEidt, isSort: isSort, maxSize: maxSize, completeHandle: completeHandle)
    }
    @available(iOS 10, *)
    @objc public class func openCamera(tager:UIViewController,cameraType:SRCameraType = .Photo, isRectangleDetection:Bool = false, isEidt:Bool = false, maxSize:Int = 2*1024*1024, completeHandle:((_ file:SRFileInfoData)->Void)?)->Void{
        tager.openCamera(cameraType: cameraType, isRectangleDetection: isRectangleDetection, isEidt: isEidt, maxSize: maxSize, completeHandle: completeHandle)
    }
    
    @available(iOS 10, *)
    @objc public class func openAlbum(tager:UIViewController, assetType:SRAssetType = .None, maxCount:Int = 1, isEidt:Bool = false, eidtSize:CGSize = .zero, isSort:Bool = false, maxSize:Int = 2*1024*1024, completeHandle:((_ files:[SRFileInfoData])->Void)?)->Void{
        tager.openAlbum(assetType: assetType, maxCount: maxCount, isEidt: isEidt, eidtSize: eidtSize, isSort: isSort, maxSize: maxSize, completeHandle: completeHandle)
    }
    @available(iOS 10, *)
    @objc public class func openCamera(tager:UIViewController,cameraType:SRCameraType = .Photo, isRectangleDetection:Bool = false, isEidt:Bool = false, eidtSize:CGSize = .zero, maxSize:Int = 2*1024*1024, completeHandle:((_ file:SRFileInfoData)->Void)?)->Void{
        tager.openCamera(cameraType: cameraType, isRectangleDetection: isRectangleDetection, isEidt: isEidt, eidtSize: eidtSize, maxSize: maxSize, completeHandle: completeHandle)
    }
    
    @available(iOS 10, *)
    @objc public class  func openFaceTrack(faceTaskCount:Int = 2, tager:UIViewController,maxSize:Int = 2*1024*1024,completeHandle:((_ file:SRFileInfoData)->Void)?)->Void{
        tager.openFaceTrack(faceTaskCount:faceTaskCount, maxSize: maxSize, completeHandle: completeHandle)
    }
}

extension UIViewController{
    
    /// 打开相册
    /// - Parameters:
    ///   - assetType: .None：任意列席，.Photo：图片类型，.Video：视频类型；默认为.None
    ///   - maxCount: 取图片或者视频的数量；默认为1
    ///   - isEidt: 是否要编辑；默认为false
    ///   - isSort: 是否要排序输出图片；默认为false
    ///   - maxSize: 限制图片的M数，；默认为2*1024*1024，也就是2M
    ///   - completeHandle: 回调结果
    @available(iOS 10, *)
    @objc public func openAlbum(assetType:SRAssetType = .None, maxCount:Int = 1, isEidt:Bool = false, isSort:Bool = false, maxSize:Int = 2*1024*1024, completeHandle:((_ files:[SRFileInfoData])->Void)?)->Void{
        self.openAlbum(assetType: assetType, maxCount: maxCount,isEidt:isEidt, eidtSize: .zero, isSort:isSort,maxSize:maxSize, completeHandle: completeHandle)
    }
    
    /// 打开相册
    /// - Parameters:
    ///   - assetType: .None：任意列席，.Photo：图片类型，.Video：视频类型；默认为.None
    ///   - maxCount: 取图片或者视频的数量；默认为1
    ///   - isEidt: 是否要编辑；默认为false
    ///   - eidtSize: 编辑尺寸
    ///   - isSort: 是否要排序输出图片；默认为false
    ///   - maxSize: 限制图片的M数，；默认为2*1024*1024，也就是2M
    ///   - completeHandle: 回调结果
    @available(iOS 10, *)
    @objc public func openAlbum(assetType:SRAssetType = .None, maxCount:Int = 1, isEidt:Bool = false, eidtSize:CGSize = .zero,  isSort:Bool = false, maxSize:Int = 2*1024*1024, completeHandle:((_ files:[SRFileInfoData])->Void)?)->Void{
        self.checkCanOpenAlbums(callback: {[weak self] status in
            DispatchQueue.main.async {
                if #available(iOS 14, *) {
                    if status == .authorized || status == .limited{
                        max_count = maxCount
                        asset_type = assetType
                        is_eidt = isEidt
                        max_size = maxSize
                        is_sort = isSort
                        if !eidtSize.equalTo(.zero){
                            SRAlbumData.sharedInstance.eidtSize = eidtSize
                        }
                        SRAlbumData.sharedInstance.completeFilesHandle = completeHandle
                        SRAlbumData.sharedInstance.isZip = maxSize>0;
                        let vc:SRAlbumController = SRAlbumController.init(nibName: "SRAlbumController", bundle:bundle)
                        let nv:SRNavigationController = SRNavigationController.init(rootViewController: vc)
                        nv.navigationBar.barTintColor = UIColor.init(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1.0)
                        nv.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                        nv.navigationBar.tintColor = UIColor.white
                        nv.navigationBar.barStyle = .black
                        nv.modalPresentationStyle = .fullScreen
                        self?.present(nv, animated: true, completion: nil)
                    }
                } else {
                    if status == .authorized{
                        max_count = maxCount
                        asset_type = assetType
                        is_eidt = isEidt
                        max_size = maxSize
                        is_sort = isSort
                        if !eidtSize.equalTo(.zero){
                            SRAlbumData.sharedInstance.eidtSize = eidtSize
                        }
                        SRAlbumData.sharedInstance.completeFilesHandle = completeHandle
                        SRAlbumData.sharedInstance.isZip = maxSize>0;
                        let vc:SRAlbumController = SRAlbumController.init(nibName: "SRAlbumController", bundle:bundle)
                        let nv:SRNavigationController = SRNavigationController.init(rootViewController: vc)
                        nv.navigationBar.barTintColor = UIColor.init(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1.0)
                        nv.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                        nv.navigationBar.tintColor = UIColor.white
                        nv.navigationBar.barStyle = .black
                        nv.modalPresentationStyle = .fullScreen
                        self?.present(nv, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    /// 打开相机
    /// - Parameters:
    ///   - cameraType: .Photo 拍照，.Video 录像
    ///   - isRectangleDetection: 是否矩形检测
    ///   - isEidt: 是否编辑
    ///   - maxSize: 限制图片的M数，；默认为2*1024*1024，也就是2M
    ///   - completeHandle: 回调结果
    /// - Returns: 空
    @available(iOS 10, *)
    @objc public func openCamera(cameraType:SRCameraType = .Photo, isRectangleDetection:Bool = false, isEidt:Bool = false, maxSize:Int = 2*1024*1024, completeHandle:((_ file:SRFileInfoData)->Void)?)->Void{
        self.openCamera(cameraType:cameraType, isRectangleDetection:isRectangleDetection, isEidt:isEidt, eidtSize: .zero, maxSize:maxSize,completeHandle: completeHandle)
    }
    
    /// 打开相机
    /// - Parameters:
    ///   - cameraType: .Photo 拍照，.Video 录像
    ///   - isRectangleDetection: 是否矩形检测
    ///   - isEidt: 是否编辑
    ///   - eidtSize: 编辑尺寸
    ///   - maxSize: 限制图片的M数，；默认为2*1024*1024，也就是2M
    ///   - completeHandle: 回调结果
    /// - Returns: 空
    @available(iOS 10, *)
    @objc public func openCamera(cameraType:SRCameraType = .Photo, isRectangleDetection:Bool = false, isEidt:Bool = false, eidtSize:CGSize = .zero, maxSize:Int = 2*1024*1024, completeHandle:((_ file:SRFileInfoData)->Void)?)->Void{
        self.checkCamera(cameraType: cameraType) {[weak self] authorization in
            if authorization {
                camera_type = cameraType
                is_eidt = isEidt
                max_size = maxSize
                is_rectangle_detection = isRectangleDetection
                if !eidtSize.equalTo(.zero){
                    SRAlbumData.sharedInstance.eidtSize = eidtSize
                }
                SRAlbumData.sharedInstance.completeHandle = completeHandle
                SRAlbumData.sharedInstance.isZip = maxSize>0;
                let vc:SRCameraViewController = SRCameraViewController.init(nibName: "SRCameraViewController", bundle:bundle)
                let nv:SRNavigationController = SRNavigationController.init(rootViewController: vc)
                nv.navigationBar.barTintColor = UIColor.init(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1.0)
                nv.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                nv.navigationBar.tintColor = UIColor.white
                nv.navigationBar.barStyle = .black
                nv.modalPresentationStyle = .fullScreen
                nv.isNavigationBarHidden = true
                self?.present(nv, animated: true, completion: nil)
            }
        }
    }
    
    @available(iOS 10, *)
    @objc public func openFaceTrack(faceTaskCount:Int = 2, maxSize:Int = 2*1024*1024,completeHandle:((_ file:SRFileInfoData)->Void)?)->Void{
        self.checkCamera(cameraType: .Photo) {[weak self] authorization in
            if authorization {
                max_size = maxSize
                SRAlbumData.sharedInstance.isZip = maxSize>0;
                SRAlbumData.sharedInstance.completeHandle = completeHandle
                let vc:SRFaceController = SRFaceController.init(nibName: "SRFaceController", bundle:bundle)
                vc.faceTaskCount = faceTaskCount
                self?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func checkCamera(cameraType:SRCameraType, result:@escaping((_ authorization:Bool)->Void)){
        if self.isCanAccessVideoCapture() {
            if cameraType == .Video {
                if self.isCanOpenMic() {
                    AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
                        DispatchQueue.main.async {
                            result(granted)
                        }
                    }
                }else{
                    result(false)
                    var message:String = "想要访问麦克风，需要你的允许。去设置？"
                    if Bundle.main.infoDictionary != nil {
                        message = Bundle.main.infoDictionary!["NSMicrophoneUsageDescription"] as! String
                    }
                    let alertController = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert);
                    let cancelAction:UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction);
                    let sureAction:UIAlertAction = UIAlertAction.init(title: "设置", style: .destructive) { (action) in
                        //去c设置中修改权限
                        let setUrl = URL.init(string: UIApplication.openSettingsURLString)!;
                        if UIApplication.shared.canOpenURL(setUrl) {
                            UIApplication.shared.open(setUrl, options: [:], completionHandler: nil)
                        }
                    }
                    alertController.addAction(sureAction);
                    self.present(alertController, animated: true, completion: nil)
                }
            }else{
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                    DispatchQueue.main.async {
                        result(granted)
                    }
                }
            }
        }else{
            result(false)
            var message:String = "想要访问相机，需要你的允许。去设置？"
            if Bundle.main.infoDictionary != nil {
                message = Bundle.main.infoDictionary!["NSCameraUsageDescription"] as! String
            }
            let alertController = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert);
            let cancelAction:UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(cancelAction);
            let sureAction:UIAlertAction = UIAlertAction.init(title: "设置", style: .destructive) { (action) in
                //去c设置中修改权限
                let setUrl = URL.init(string: UIApplication.openSettingsURLString)!;
                if UIApplication.shared.canOpenURL(setUrl) {
                    UIApplication.shared.open(setUrl, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(sureAction);
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func checkCanOpenAlbums(callback:@escaping ((PHAuthorizationStatus)->Void)){
        var authorStatus:PHAuthorizationStatus?
        if #available(iOS 14.0, *) {
            authorStatus = PHPhotoLibrary.authorizationStatus(for: PHAccessLevel.readWrite)
        } else {
            authorStatus = PHPhotoLibrary.authorizationStatus()
        }
        switch authorStatus {
        case .notDetermined:
            if #available(iOS 14.0, *){
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: callback)
            }else{
                PHPhotoLibrary.requestAuthorization(callback)
            }
            break
        case .authorized:
            callback(.authorized)
            break
        case .restricted:
            self.openAlunmsSet()
            break
        case .denied:
            self.openAlunmsSet()
            break
        case .limited:
            if #available(iOS 14, *) {
                callback(.limited)
            }
            break
        default:
            break
        }
    }
    
    
    private func openAlunmsSet(){
        var message:String = "想要访问相册，需要你的允许。去设置？"
        if Bundle.main.infoDictionary != nil {
            message = Bundle.main.infoDictionary!["NSPhotoLibraryUsageDescription"] as! String
        }
        let alertController = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert);
        let cancelAction:UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction);
        let sureAction:UIAlertAction = UIAlertAction.init(title: "设置", style: .destructive) { (action) in
            //去c设置中修改权限
            let setUrl = URL.init(string: UIApplication.openSettingsURLString)!;
            if UIApplication.shared.canOpenURL(setUrl) {
                UIApplication.shared.open(setUrl, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(sureAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// TODO: 判断是否有麦克风权限
    func isCanOpenMic() -> Bool {
        let micStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        if micStatus == .restricted || micStatus == .denied {
            return false;
        }else{
            return true;
        }
    }
    /// TODO: 判断是否有拍摄权限
    func isCanAccessVideoCapture() -> Bool {
        let micStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if micStatus == .restricted || micStatus == .denied {
            return false;
        }else{
            return true;
        }
    }
}

class SRAlbumData: NSObject {
    //TODO: 选择的资源保存列表
    var sList:Array<PHAsset> = Array<PHAsset>.init()
    //TODO: 是否压缩
    var isZip = false
    //
    var eidtSize:CGSize?
    //多个文件返回
    var completeFilesHandle:((_ files:[SRFileInfoData])->Void)?
    //单个文件返回
    var completeHandle:((_ file:SRFileInfoData)->Void)?
    
    static var sharedInstance = SRAlbumData()
    
    static func free() -> Void {
        sharedInstance.isZip = false
        sharedInstance.sList.removeAll()
    }
}

