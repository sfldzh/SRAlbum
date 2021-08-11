//
//  SRAlbumEidtView.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/2/16.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import Photos
import JPImageresizerView

class SRAlbumEidtView: UIView {
    
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var horizontalButton: UIButton!
    @IBOutlet weak var verticallyButton: UIButton!
    @IBOutlet weak var tailoringButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var top: NSLayoutConstraint!
    
    
    weak var imageView:JPImageresizerView?
    private var completeBlock:((UIImage?,SRAlbumEidtView)->Void)?
    private var cancelBlock:(()->Void)?
    deinit {
        print("编辑kill")
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
    
    func show<T>(data:T, complete:((UIImage?, SRAlbumEidtView)->Void)?, _ cancelBlock:(()->Void)?) -> Void {
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
            let configure = JPImageresizerConfigure.defaultConfigure(withResize: image!) { (configure) in
                var top:CGFloat = 20;
                if #available(iOS 11.0, *) {
                    top = SRHelper.getWindow()?.safeAreaInsets.top ?? 20
                }
                
                var bottom:CGFloat = 0;
                if #available(iOS 11.0, *) {
                    bottom = SRHelper.getWindow()?.safeAreaInsets.bottom ?? 0
                }
                
                configure?.contentInsets = UIEdgeInsets.init(top: top+46, left: 0, bottom: bottom+55, right: 0)
            }
            if let imageresizerView = JPImageresizerView.init(configure: configure, imageresizerIsCanRecovery: { [weak self](isCanRecovery) in
                self?.resetButton.isHidden = !isCanRecovery
            }, imageresizerIsPrepareToScale: { [weak self](isPrepareToScale) in
                self?.rotateButton.isEnabled = !isPrepareToScale
                self?.horizontalButton.isEnabled = !isPrepareToScale
                self?.verticallyButton.isEnabled = !isPrepareToScale
                self?.tailoringButton.isEnabled = !isPrepareToScale
                self?.resetButton.isEnabled = !isPrepareToScale
            }) {
                imageresizerView.frameType = .conciseFrameType;
                self.insertSubview(imageresizerView, at: 0)
                self.imageView = imageresizerView
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
        self.imageView?.imageresizer(complete: { [weak self](resizeImage) in
            self?.completeBlock?(resizeImage, self!)
        }, compressScale: 1)
    }
}
