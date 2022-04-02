//
//  SRAlbumEidtView.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/2/16.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import Photos
//import JPImageresizerView

class SRAlbumEidtView: UIView {
    
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var horizontalButton: UIButton!
    @IBOutlet weak var verticallyButton: UIButton!
    @IBOutlet weak var tailoringButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var top: NSLayoutConstraint!
    
    
    weak var imageView:JPImageresizerView?
    private var completeBlock:(([UIImage],SRAlbumEidtView)->Void)?
    private var cancelBlock:(()->Void)?
    deinit {
//        print("编辑kill")
    }
    
    static func createEidtView() -> SRAlbumEidtView?{
        let datas = bundle!.loadNibNamed("SRAlbumEidtView", owner: nil, options: nil)!;
        var eidtView:SRAlbumEidtView?
        for data in datas {
            let temp = data as! NSObject
            if temp.isKind(of: SRAlbumEidtView.classForCoder()){
                eidtView = temp as? SRAlbumEidtView;
                eidtView?.frame = CGRect.init(x: 0, y: 0, width: Appsize().width, height: Appsize().height)
                eidtView?.clipsToBounds = true;
                break
            }
        }
        return eidtView;
    }
    
    override func awakeFromNib() {
        if #available(iOS 11.0, *) {
        }else{
            self.top.constant = 20
        }
    }
    
    func show<T>(data:T, complete:(([UIImage], SRAlbumEidtView)->Void)?, _ cancelBlock:(()->Void)?) -> Void {
        var canAdd = false
        if T.self == PHAsset.self {
            self.completeBlock = complete
            self.cancelBlock = cancelBlock
            _=(data as! PHAsset).requestOriginalImage { [weak self](imageData, info) in
                let image = UIImage.init(data: imageData!)
                self?.addImageConfiger(image: image)
            }
            canAdd = true
        }else if T.self == UIImage.self {
            self.completeBlock = complete
            self.cancelBlock = cancelBlock
            self.addImageConfiger(image: data as? UIImage)
            canAdd = true
        }
        if canAdd {
            SRHelper.getWindow()?.addSubview(self);
        }
        
    }
    
    private func addImageConfiger(image:UIImage?) -> Void {
        if image != nil {
            var configure:JPImageresizerConfigure!
            if SRAlbumData.sharedInstance.eidtConfigure.type == .Circular{
                configure = JPImageresizerConfigure.darkBlurMaskTypeConfigure(with: image!) { config in
                    _ = config.jp_strokeColor(UIColor.white)
                        .jp_frameType(.classicFrameType)
                        .jp_isClockwiseRotation(true)
                        .jp_animationCurve(.easeOut)
                        .jp_isRoundResize(true)
                        .jp_isArbitrarily(false)
                }
            }else{
                configure = JPImageresizerConfigure.defaultConfigure(with: image!) { config in
                    var top:CGFloat = 20;
                    if #available(iOS 11.0, *) {
                        top = SRHelper.getWindow()?.safeAreaInsets.top ?? 20
                    }
                    
                    var bottom:CGFloat = 0;
                    if #available(iOS 11.0, *) {
                        bottom = SRHelper.getWindow()?.safeAreaInsets.bottom ?? 0
                    }
                    config.contentInsets = UIEdgeInsets.init(top: top+46, left: 0, bottom: bottom+55, right: 0)
                }
            }
            let imageresizerView = JPImageresizerView(configure:configure){ [weak self] isCanRecovery in
                self?.resetButton.isHidden = !isCanRecovery
            } imageresizerIsPrepareToScale: { [weak self] isPrepareToScale in
                self?.rotateButton.isEnabled = !isPrepareToScale
                self?.horizontalButton.isEnabled = !isPrepareToScale
                self?.verticallyButton.isEnabled = !isPrepareToScale
                self?.tailoringButton.isEnabled = !isPrepareToScale
                self?.resetButton.isEnabled = !isPrepareToScale
            }
            self.insertSubview(imageresizerView, at: 0)
            self.imageView = imageresizerView
            
            if SRAlbumData.sharedInstance.eidtConfigure.type == .Square{
                imageresizerView.resizeWHScale = 1
            }else if SRAlbumData.sharedInstance.eidtConfigure.type == .Gird{
                if SRAlbumData.sharedInstance.eidtConfigure.girdIndex.item == SRAlbumData.sharedInstance.eidtConfigure.girdIndex.section{
                    imageresizerView.maskImage = nil
                    imageresizerView.borderImage = nil
                    imageresizerView.frameType = .classicFrameType
                    imageresizerView.resizeWHScale = 1
                    imageresizerView.gridCount = UInt(SRAlbumData.sharedInstance.eidtConfigure.girdIndex.item)
                    imageresizerView.isShowGridlinesWhenIdle = true
                    imageresizerView.isShowGridlinesWhenDragging = true
                }else{
                    imageresizerView.frameType = .conciseFrameType;
                }
            }else{
                imageresizerView.frameType = .conciseFrameType;
            }
        }
    }
    
    func dismiss() -> Void {
        self.removeFromSuperview();
        self.cancelBlock?()
    }
    
    @IBAction func dissmissAction(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func rotateAction(_ sender: UIButton) {
        self.imageView?.rotation()
    }
    
    @IBAction func verticallyAction(_ sender: UIButton) {
        self.imageView?.setVerticalityMirror(!(self.imageView?.verticalityMirror ?? false), animated: true)
    }
    
    @IBAction func horizontalAction(_ sender: UIButton) {
        self.imageView?.setHorizontalMirror(!(self.imageView?.horizontalMirror ?? false), animated: true)
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        self.imageView?.recoveryByCurrentResizeWHScale()
    }
    
    @IBAction func tailoringAction(_ sender: UIButton) {
        if SRAlbumData.sharedInstance.eidtConfigure.type == .Gird{
            let index = SRAlbumData.sharedInstance.eidtConfigure.girdIndex;
            self.imageView?.cropGirdPictures(withColumnCount: index.section, rowCount: index.item, compressScale: 1, bgColor: UIColor.white, cacheURL: nil, errorBlock: { url, error in
                
            }, complete: { [weak self] result, results, columnCount, rowCount in
                var list:[UIImage] = []
                if results?.isEmpty ?? true {
                    if let img = result?.image{
                        list.append(img)
                    }
                }else{
                    if results != nil{
                        for data in results! {
                            if data.image != nil{
                                list.append(data.image!)
                            }
                        }
                    }
                }
                self?.completeBlock?(list, self!)
            })
        }else{
            self.imageView?.cropPicture(withCompressScale: 1, cacheURL: nil, errorBlock: { url, error in
                
            }, complete: { [weak self] result in
                if result?.image != nil{
                    self?.completeBlock?([result!.image!], self!)
                }
            })
        }
    }
}
