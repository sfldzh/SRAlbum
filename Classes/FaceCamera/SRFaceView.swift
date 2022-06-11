//
//  FaceView.swift
//  FaceTrack
//
//  Created by 施峰磊 on 2022/6/9.
//

import UIKit
import AVFoundation

class SRFaceView: UIView,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate {
    private let tipLabel:UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.white
        label.text = "请把脸移入检测框内"
        return label
    }()
    private lazy var videoLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init()
    private lazy var captureSession = AVCaptureSession.init()
    private lazy var frontDevice:AVCaptureDevice? = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.front)
    private var inputDevice:AVCaptureDeviceInput?
    private var captureQueue:DispatchQueue?
    private let faceDetector = CIDetector.init(ofType: CIDetectorTypeFace, context: nil)
    private let opt:[String : Any] = [CIDetectorAccuracy:CIDetectorAccuracyHigh,CIDetectorSmile: true,CIDetectorEyeBlink:true]
    private var effectView:UIVisualEffectView!
    
    private let faceSize = UIScreen.main.bounds.size.width - 100
    //请把脸移检测框
    private let moveFaceTask = SRFaceTaskData.init()
    //笑一笑
    private let smileFaceTask:SRFaceTaskData = {
        let faceTask = SRFaceTaskData.init()
        faceTask.faceType = 1
        return faceTask
    }()
    //眨眨眼
    private let blinkFaceTask:SRFaceTaskData = {
        let faceTask = SRFaceTaskData.init()
        faceTask.faceType = 2
        return faceTask
    }()
    private let is_smile_first = arc4random_uniform(2) == 0

    private weak var delegate:SRFaceViewDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configerGLView()
    }
    
    open func install(delegate:SRFaceViewDelegate,finish:@escaping(() -> Void)){
        self.delegate = delegate
        self.captureQueue = DispatchQueue(label: "Agora-Custom-Video-Capture-Queue")
        self.configerCamera(finish: finish)
    }
    
    private func rectOfInterest() -> CGRect{
        let screenSize = self.frame.size
        let showRect = self.showRect()
        let x = screenSize.width - showRect.origin.x - showRect.size.width
        let y = showRect.origin.y
        let h = showRect.size.height
        let w = showRect.size.width
        let rectY = y / screenSize.height
        let rectX = x / screenSize.width
        let rectH = h / screenSize.height
        let rectW = w / screenSize.width
        return CGRect.init(x: rectY, y: rectX, width: rectH, height: rectW)
    }
    
    private func showRect()->CGRect{
        let screenSize = self.frame.size
        let showSize = CGSize.init(width: faceSize, height: faceSize)
        return CGRect.init(x: (screenSize.width-showSize.width)/2.0, y: (screenSize.height-showSize.height)/2.0 - 40, width: showSize.width, height: showSize.height)
    }
    
    private func maskLayer()->CAShapeLayer{
        let layer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: self.effectView.bounds, cornerRadius: 0)
        let rpath = UIBezierPath(roundedRect: self.showRect(), cornerRadius: faceSize/2.0).reversing()
        path.append(rpath)
        layer.path = path.cgPath
        return layer
    }
    
    private func configerCamera(finish:@escaping(()->Void)){
        if self.frontDevice != nil {
            DispatchQueue.global().async {
                self.captureSession.beginConfiguration()
                if let input = try? AVCaptureDeviceInput.init(device: self.frontDevice!) {
                    self.inputDevice = input;
                    self.captureSession.addInput(input)
                    
                    let dataOutput:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput.init()
                    dataOutput.alwaysDiscardsLateVideoFrames = true
                    let key = String(kCVPixelBufferPixelFormatTypeKey)
                    dataOutput.videoSettings = [key:kCVPixelFormatType_32BGRA]
                    dataOutput.setSampleBufferDelegate(self, queue: self.captureQueue)
                    self.captureSession.addOutput(dataOutput)
                    
                
                    let faceOutput:AVCaptureMetadataOutput = AVCaptureMetadataOutput.init()
                    faceOutput.rectOfInterest = self.rectOfInterest()
                    faceOutput.setMetadataObjectsDelegate(self, queue: .main)
                    self.captureSession.addOutput(faceOutput)
                    faceOutput.metadataObjectTypes = [.face]
                    
                    
                    try? self.frontDevice!.lockForConfiguration()
                    if self.frontDevice!.isExposureModeSupported(AVCaptureDevice.ExposureMode.continuousAutoExposure) {
                        self.frontDevice!.exposureMode = .continuousAutoExposure
                    }
                    self.frontDevice!.unlockForConfiguration()
                    self.captureSession.commitConfiguration()
                    
                    DispatchQueue.main.async {
                        self.effectView.layer.mask = self.maskLayer()
                        finish()
                    }
                }
            }
        }
    }
    
    private func configerGLView(){
        self.backgroundColor = UIColor.black
        self.captureSession.sessionPreset = .hd1280x720
        self.videoLayer.videoGravity = .resizeAspect
        self.videoLayer.session = self.captureSession;
        self.layer.insertSublayer(self.videoLayer, at: 0)
        
        let effect:UIBlurEffect = UIBlurEffect.init(style: .dark)
        effectView = UIVisualEffectView.init(effect: effect)
        self.addSubview(effectView)
        self.addSubview(self.tipLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoLayer.frame = self.bounds
        self.effectView.frame = self.bounds
        self.tipLabel.frame = CGRect.init(x: 0, y: self.showRect().minY - 50, width: self.bounds.width, height: 30)
    }
    
    private func checkTask() -> Bool{
        if !self.moveFaceTask.isFinish {
            DispatchQueue.main.async {
                self.tipLabel.text = "请把脸移入检测框内"
            }
            return false
        }
        if self.is_smile_first{
            if !self.smileFaceTask.isFinish{
                DispatchQueue.main.async {
                    self.tipLabel.text = "请笑一笑"
                }
                return false
            }
            if !self.blinkFaceTask.isFinish{
                DispatchQueue.main.async {
                    self.tipLabel.text = "请眨眨眼"
                }
                return false
            }
        }else{
            if !self.blinkFaceTask.isFinish{
                DispatchQueue.main.async {
                    self.tipLabel.text = "请眨眨眼"
                }
                return false
            }
            if !self.smileFaceTask.isFinish{
                DispatchQueue.main.async {
                    self.tipLabel.text = "请笑一笑"
                }
                return false
            }
        }
        DispatchQueue.main.async {
            self.tipLabel.text = "已完成"
        }
        return true
    }
    
    // MARK: - 操作
    
    /// 开始运行
    open func startRunning(){
        self.captureSession.startRunning()
        
    }
    
    /// 停止运行
    open func stopRunning(){
        self.captureSession.stopRunning()
    }
    
    //MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        if self.moveFaceTask.isFinish{
            if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer){
                let image = CIImage.init(cvPixelBuffer: pixelBuffer)
                if let features = self.faceDetector?.features(in: image, options:self.opt) as? [CIFaceFeature]{
                    if features.count == 1{
                        if self.checkTask() {
                            self.stopRunning()
                            UIGraphicsBeginImageContext(CGSize.init(width: image.extent.size.height, height: image.extent.size.width))
                            UIImage.init(ciImage: image, scale: 1, orientation: .right).draw(in: CGRect.init(x: 0, y: 0, width: image.extent.size.height, height: image.extent.size.width))
                            guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return }
                            UIGraphicsEndImageContext()
                            DispatchQueue.main.async {
                                self.delegate?.faceTrackFinish(image: img)
                            }
                        }else{
                            let faceFeature = features.first!
                            if faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition && faceFeature.hasMouthPosition{
                                if faceFeature.hasSmile{
                                    self.smileFaceTask.isFinish = true
                                }else if faceFeature.leftEyeClosed && faceFeature.rightEyeClosed{
                                    self.blinkFaceTask.isFinish = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        if metadataObjects.count == 0{
            self.moveFaceTask.isFinish = false
            DispatchQueue.main.async {
                self.tipLabel.text = "请把脸移入检测框内"
            }
        }else if metadataObjects.count == 1{
            self.moveFaceTask.isFinish = true
        }else{
            self.moveFaceTask.isFinish = false
            DispatchQueue.main.async {
                self.tipLabel.text = "检测到多张脸"
            }
        }
    }
}

protocol SRFaceViewDelegate:NSObjectProtocol{
    func faceTrackFinish(image:UIImage)
}
