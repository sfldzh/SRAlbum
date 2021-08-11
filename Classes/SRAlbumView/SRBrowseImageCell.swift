//
//  SRBrowseImageCell.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/22.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import Photos

class SRBrowseImageCell: UICollectionViewCell, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var playButton: UIButton!
    private let playerLayer:AVPlayerLayer = {
        let playerLayer:AVPlayerLayer = AVPlayerLayer.init()
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
    
    private let imageView:UIImageView = {
        let imageView:UIImageView = UIImageView.init()
        imageView.backgroundColor = UIColor.clear
        return imageView
    }();
    private var imgId:PHImageRequestID?
    
    var data:PHAsset?{
        didSet{
            self.playButton.isHidden = self.data?.isPhoto() ?? true
            if self.data?.editedPic == nil {
                if self.imgId != nil {
                    self.data?.cancelImageRequest(self.imgId!)
                }
                self.imgId = self.data?.requestOriginalImage(resultHandler: { [weak self](imageData, info) in
                    if imageData != nil {
                        self?.imgId = nil
                        let maxSize = UIScreen.main.bounds.size
                        let image = UIImage.init(data: imageData!)
                        let size = image?.tagerSize(maxSize: maxSize) ?? CGSize.zero
                        self?.imageView.frame = CGRect.init(x: (maxSize.width - size.width)/2.0, y: (maxSize.height - size.height)/2.0, width: size.width, height: size.height)
                        self?.imageView.image = image
                        self?.playerLayer.frame = self?.imageView.bounds ?? CGRect.zero;
                    }
                })
            }else{
                let maxSize = UIScreen.main.bounds.size
                let size = data?.editedPic?.tagerSize(maxSize: maxSize) ?? CGSize.zero
                self.imageView.frame = CGRect.init(x: (maxSize.width - size.width)/2.0, y: (maxSize.height - size.height)/2.0, width: size.width, height: size.height)
                self.imageView.image = data?.editedPic
                self.playerLayer.frame = self.imageView.bounds;
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addViews()
        self.configerView()
        self.addGesture()
    }
    
 
    //MARK: - 操作
    private func addViews() -> Void {
        self.scrollView.addSubview(self.imageView)
        self.imageView.layer.insertSublayer(self.playerLayer, at: 0)
    }
    
    private func addGesture() -> Void {
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(showOrHiddenBarTap(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        self.scrollView.addGestureRecognizer(tapGesture)
        tapGesture.require(toFail: doubleTap)
        
    }
    
    private func configerView() -> Void {
        self.scrollView.delegate = self
        self.scrollView.bounces = true
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.isMultipleTouchEnabled = true
        self.scrollView.maximumZoomScale = 5.0
        self.scrollView.minimumZoomScale = 0.5
        self.scrollView.zoomScale = 1.0
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    @IBAction func palyAction(_ sender: UIButton) {
        sender.isHidden = true
        paly()
    }
    
    func paly() -> Void {
        let options = PHVideoRequestOptions.init()
        options.isNetworkAccessAllowed = true;
        PHImageManager.default().requestAVAsset(forVideo: self.data!, options: options) { (asset, audioMix, info) in
            DispatchQueue.main.async {
                if asset != nil {
                    let playerItem = AVPlayerItem.init(asset: asset!)
                    let player:AVPlayer = AVPlayer.init(playerItem: playerItem)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.playDidEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                    self.playerLayer.player = player;
                    player.play()
                }else{
                    self.playButton.isHidden = self.data?.isPhoto() ?? true
                    SRAlbumTip.sharedInstance.show(content: "视频读取出错！")
                }
            }
        }
    }
    
    func stop() -> Void {
        if self.playerLayer.player?.currentItem != nil {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
        self.playerLayer.player?.pause()
        self.playButton.isHidden = self.data?.isPhoto() ?? true
        self.playerLayer.player = nil
    }
    
    @objc func playDidEnd(notification:Notification) -> Void {
        stop()
    }
    
    func resetCell() -> Void {
        if self.scrollView.zoomScale != 1.0 {
            self.scrollView.zoomScale = 1.0
        }
        stop()
    }
    
    private func zoomRect(scale:CGFloat, center:CGPoint) -> CGRect {
        let width = self.scrollView.frame.size.width  / scale
        let height = self.scrollView.frame.size.height  / scale
        let x = center.x - (width  / 2.0)
        let y = center.y - (height  / 2.0)
        return CGRect.init(x: x, y: y, width: width, height: height)
    }
    
    //MARK: - 手势事件
    @objc func handleDoubleTap(gesture:UITapGestureRecognizer) -> Void {
        if self.scrollView.zoomScale == 1.0 {
            let zoomRect = self.zoomRect(scale: self.scrollView.zoomScale * 3.0, center: gesture.location(in: gesture.view));
            self.scrollView.zoom(to: zoomRect, animated: true)
        }else{
            self.scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    
    @objc func showOrHiddenBarTap(gesture:UITapGestureRecognizer) -> Void {
        
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0
        self.imageView.center = CGPoint.init(x: ((scrollView.contentSize.width / 2.0) + offsetX), y: ((scrollView.contentSize.height / 2.0) + offsetY))
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

}
