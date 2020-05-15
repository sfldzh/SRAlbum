//
//  SRAlbum.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/17.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import Photos

var isMain:Bool = true;
var bundle:Bundle?{
    get{
        let podBundle = Bundle.init(for: SRAlbumController.self)
        let bundleURL = podBundle.url(forResource: "SRAlbum", withExtension: "bundle")
        if bundleURL != nil {
            let bundle = Bundle.init(url: bundleURL!)
            isMain = false;
            return bundle
        }else{
            isMain = true;
            return Bundle.main
        }
    }
}

func Appsize() -> CGSize {
    return UIScreen.main.bounds.size;
}

var asset_type:SRAssetType = .None//.None：任意列席，.Photo：图片类型，.Video：视频类型；默认为.None
var max_count = 0;//取图片或者视频的数量；默认为1
var max_size = 0;//限制图片的M数，；默认为2*1024*1024，也就是2M
var is_eidt = false;//是否要编辑；默认为false
var is_sort = false;//是否要排序输出图片；默认为false

public class SRAlbumWrapper:NSObject{
    
    @objc public class func openAlbum(tager:UIViewController, assetType:SRAssetType = .None, maxCount:Int = 1, isEidt:Bool = false, isSort:Bool = false, maxSize:Int = 2*1024*1024, completeHandle:((Array<Any>)->Void)?)->Void{
        if tager.isCanOpenAlbums() {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    switch status{
                    case .authorized:
                        max_count = maxCount
                        asset_type = assetType
                        is_eidt = isEidt
                        max_size = maxSize
                        is_sort = isSort
                        SRAlbumData.sharedInstance.completeHandle = completeHandle
                        SRAlbumData.sharedInstance.isZip = maxSize>0;
                        let vc:SRAlbumController = SRAlbumController.init(nibName: "SRAlbumController", bundle:bundle)
                        let nv:UINavigationController = UINavigationController.init(rootViewController: vc)
                        nv.navigationBar.barTintColor = UIColor.init(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1.0)
                        nv.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                        nv.navigationBar.tintColor = UIColor.white
                        nv.navigationBar.barStyle = .black
                        nv.modalPresentationStyle = .fullScreen
                        tager.present(nv, animated: true, completion: nil)
                    default:
                        break;
                    }
                }
            }
        }else{
            let alertController = UIAlertController.init(title: "提示", message: "想要访问相册，需要你的允许。去设置？", preferredStyle: .alert);
            let cancelAction:UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(cancelAction);
            let sureAction:UIAlertAction = UIAlertAction.init(title: "设置", style: .destructive) { (action) in
                //去c设置中修改权限
                let setUrl = URL.init(string: UIApplication.openSettingsURLString)!;
                if UIApplication.shared.canOpenURL(setUrl) {
                    UIApplication.shared.openURL(setUrl)
                }
            }
            alertController.addAction(sureAction);
            tager.present(alertController, animated: true, completion: nil)
        }
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
    @objc public func openAlbum(assetType:SRAssetType = .None, maxCount:Int = 1, isEidt:Bool = false, isSort:Bool = false, maxSize:Int = 2*1024*1024, completeHandle:((Array<Any>)->Void)?)->Void{
        if self.isCanOpenAlbums() {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    switch status{
                    case .authorized:
                        max_count = maxCount
                        asset_type = assetType
                        is_eidt = isEidt
                        max_size = maxSize
                        is_sort = isSort
                        SRAlbumData.sharedInstance.completeHandle = completeHandle
                        SRAlbumData.sharedInstance.isZip = maxSize>0;
                        let vc:SRAlbumController = SRAlbumController.init(nibName: "SRAlbumController", bundle:bundle)
                        let nv:UINavigationController = UINavigationController.init(rootViewController: vc)
                        nv.navigationBar.barTintColor = UIColor.init(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1.0)
                        nv.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                        nv.navigationBar.tintColor = UIColor.white
                        nv.navigationBar.barStyle = .black
                        nv.modalPresentationStyle = .fullScreen
                        self.present(nv, animated: true, completion: nil)
                    default:
                        break;
                    }
                }
            }
        }else{
            let alertController = UIAlertController.init(title: "提示", message: "想要访问相册，需要你的允许。去设置？", preferredStyle: .alert);
            let cancelAction:UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(cancelAction);
            let sureAction:UIAlertAction = UIAlertAction.init(title: "设置", style: .destructive) { (action) in
                //去c设置中修改权限
                let setUrl = URL.init(string: UIApplication.openSettingsURLString)!;
                if UIApplication.shared.canOpenURL(setUrl) {
                    UIApplication.shared.openURL(setUrl)
                }
            }
            alertController.addAction(sureAction);
            self.present(alertController, animated: true, completion: nil)
        }
    }

    public func openCamera(assetType:SRAssetType = .None, isEidt:Bool = false, maxSize:Int = 2*1024*1024, completeHandle:((Array<Any>)->Void)?)->Void{
        
    }
    
    /// TODO: 判断是否有相册权限
    func isCanOpenAlbums() -> Bool {
        let authorStatus = PHPhotoLibrary.authorizationStatus()
        if authorStatus == .restricted || authorStatus == .denied {
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
    
    var completeHandle:((Array<Any>)->Void)?
    
    static let sharedInstance = SRAlbumData()
    
    static func free() -> Void {
        sharedInstance.isZip = false
        sharedInstance.sList.removeAll()
    }
}

