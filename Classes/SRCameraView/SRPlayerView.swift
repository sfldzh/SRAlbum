//
//  SRPlayerView.swift
//  SRPlayerView
//
//  Created by 施峰磊 on 2021/8/13.
//  Copyright © 2021 施峰磊. All rights reserved.
//

import UIKit
import AVFoundation

class SRPlayerView: UIView {
    
    private var player:AVPlayer?
    private var playerLayer:AVPlayerLayer = {
        let layer = AVPlayerLayer.init();
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        return layer;
    }()
    private var playerItem:AVPlayerItem?
    private var urlAsset:AVURLAsset?
    private var isPlaying:Bool = false
    
    deinit {
        if self.urlAsset != nil {
            self.urlAsset = nil;
        }
        if self.playerItem != nil {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            self.playerItem = nil;
        }
        if self.player != nil {
            self.player = nil;
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configerView()
    }
    
    
    private func configerView(){
        self.layer.insertSublayer(self.playerLayer, at: 0);
    }
    
    //MARK: - 操作
    
    /// 播放视频
    /// - Parameter playUrl: 视频地址
    open func play(playUrl:URL){
        if self.urlAsset != nil {
            self.urlAsset = nil;
        }
        if self.playerItem != nil {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            self.playerItem = nil;
        }
        if self.player != nil {
            self.player = nil;
        }
        
        self.urlAsset = AVURLAsset.init(url: playUrl);
        self.playerItem = AVPlayerItem.init(asset: self.urlAsset!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(vedioDidEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        self.player = AVPlayer.init(playerItem: self.playerItem);
        self.playerLayer.player = self.player;
        self.player?.play()
        self.isPlaying = true
    }
    
    /// 暂停或者继续播放
    open func playORpause(){
        if self.isPlaying {
            self.player?.pause()
            self.isPlaying = false
        }else{
            self.player?.play()
            self.isPlaying = true
        }
    }
    
    
    @objc private func vedioDidEnd(notification:Notification){
        if self.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
            self.player?.pause()
            let dragedCMTime = CMTime.init(value: 0, timescale: 1);
            self.player?.seek(to: dragedCMTime, toleranceBefore: CMTime.init(value: 1, timescale: 1), toleranceAfter: CMTime.init(value: 1, timescale: 1))
//            self.playBtn.isSelected = false;
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = self.bounds
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
