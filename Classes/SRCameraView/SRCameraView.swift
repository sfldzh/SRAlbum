//
//  SRCameraView.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2021/8/2.
//  Copyright © 2021 施峰磊. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import CoreImage
import ImageIO
import GLKit
import MBProgressHUD

public enum SRFlashMode:Int{
    case off//关闭
    case on//开启
    case auto//自动
}

enum CameraModeType {
    case Photo//普通拍照
    case Video//视频
}

@available(iOS 10.0, *)
class SRCameraView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    open var imageResult:((_ image:UIImage?, _ error:Error?)->Void)?
    open var recordingResult:((_ timeValue:Int, _ fileUrl:URL?)->Void)?
    open var flashMode: SRFlashMode = .off
    open var cameraModeType:CameraModeType = .Photo
    open var isRecording:Bool{
        get{
            return self.movieFileOutput.isRecording
        }
    }
    
    private lazy var videoLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init()
    private lazy var captureSession = AVCaptureSession.init()
    private lazy var backDevice:AVCaptureDevice? = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.back)
    private lazy var frontDevice:AVCaptureDevice? = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.front)
    private lazy var stillImageOutput:AVCapturePhotoOutput = AVCapturePhotoOutput.init()
    private lazy var highDetector:CIDetector? = CIDetector.init(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
    private lazy var movieFileOutput:AVCaptureMovieFileOutput = {
        let out:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput.init()
        if let videoConnection = out.connection(with: AVMediaType.video){
            if videoConnection.isVideoStabilizationSupported {
                videoConnection.preferredVideoStabilizationMode = .auto
                videoConnection.videoOrientation = .portrait;
            }
        }
        return out
    }()
    private var inputDevice:AVCaptureDeviceInput?
    
    
    private var timer:Timer?;
    private var rectOverlay:CAShapeLayer?
    private var borderDetectFrame:Bool = true;
    private let pathLineWidth:CGFloat = 1
    private var isRectangleDetection:Bool = false//开启矩形检测
    private var captureQueue:DispatchQueue?
    private var timeValue:Int = -1{
        didSet{
            
        }
    }
    
    deinit {
        self.timer?.invalidate()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configerGLView()
    }
    
    open func install(isRectangleDetection:Bool = false){
        self.isRectangleDetection = isRectangleDetection
        self.captureQueue = DispatchQueue(label: "Agora-Custom-Video-Capture-Queue")
        self.configerCamera()
        self.addOpearetionAction()
    }
    
    private func configerGLView(){
        self.backgroundColor = UIColor.black
//        self.captureSession.sessionPreset = .hd1280x720
        self.videoLayer.videoGravity = .resizeAspectFill
        self.videoLayer.session = self.captureSession;
        self.layer.insertSublayer(self.videoLayer, at: 0)
    }
    
    private func configerCamera(){
        if self.backDevice != nil {
            DispatchQueue.global().async {
                self.captureSession.beginConfiguration()
                if let input = try? AVCaptureDeviceInput.init(device: self.backDevice!) {
                    self.inputDevice = input;
                    self.captureSession.addInput(input)
                    
                    if self.isRectangleDetection {//开启矩形检测
                        let dataOutput:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput.init()
                        dataOutput.alwaysDiscardsLateVideoFrames = true
                        let key = String(kCVPixelBufferPixelFormatTypeKey)
                        dataOutput.videoSettings = [key:kCVPixelFormatType_32BGRA]
                        dataOutput.setSampleBufferDelegate(self, queue: self.captureQueue)
                        self.captureSession.addOutput(dataOutput)
                    }
                    
                    if self.cameraModeType == .Video {
                        self.captureSession.addOutput(self.movieFileOutput)
                    }else{
                        self.captureSession.addOutput(self.stillImageOutput)
                    }
                    
                    try? self.backDevice!.lockForConfiguration()
                    if self.backDevice!.isExposureModeSupported(AVCaptureDevice.ExposureMode.continuousAutoExposure) {
                        self.backDevice!.exposureMode = .continuousAutoExposure
                    }
                    self.backDevice!.unlockForConfiguration()
                    self.captureSession.commitConfiguration()
                }
            }
        }
    }
    
    private func addOpearetionAction(){
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoLayer.frame = self.bounds
    }
    
    private func queryBiggestRectangle(rectangles:[CIFeature]) -> CIRectangleFeature?{
        var halfPerimiterValue:Float = 0
        var rectangle:CIRectangleFeature?
        for rect:CIFeature in rectangles {
            if rect.type == CIFeatureTypeRectangle{
                let feature:CIRectangleFeature = rect as! CIRectangleFeature
                let width = hypotf(Float(feature.topLeft.x - feature.topRight.x), Float(feature.topLeft.y - feature.topRight.y))
                let height = hypotf(Float(feature.topLeft.x - feature.bottomLeft.x), Float(feature.topLeft.y - feature.bottomLeft.y))
                let currentHalfPerimiterValue = height + width
                if halfPerimiterValue < currentHalfPerimiterValue {
                    halfPerimiterValue = currentHalfPerimiterValue
                    rectangle = feature;
                }
            }
        }
        return rectangle
    }
    
    
    private func transformationRectangles(rectangles:[CIFeature]) -> [CIRectangleFeature]?{
        if rectangles.count == 0 {
//            print("没有检测到矩形")
            return nil
        }else{
//            print("检测到矩形")
            var list:[CIRectangleFeature] = Array.init();
            for rect:CIFeature in rectangles {
                if rect.type == CIFeatureTypeRectangle{
                    let feature:CIRectangleFeature = rect as! CIRectangleFeature
                    list.append(feature)
                }
            }
            return list
        }
    }
    
    private func drawBorder(imageRect:CGRect,topLeft:CGPoint,topRight:CGPoint,bottomLeft:CGPoint,bottomRight:CGPoint){
        let sHeight = self.bounds.height
        //获取Y轴比率
        let ts = sHeight/imageRect.height
        //获取按比例计算的框的总宽度
        let rWidth = ((imageRect.width*sHeight)/imageRect.height)
        let startX = (rWidth-self.bounds.width)/2
        
        //计算比率
        let tl_x = topLeft.x/imageRect.width
        let tr_x = topRight.x/imageRect.width
        let bl_x = bottomLeft.x/imageRect.width
        let br_x = bottomRight.x/imageRect.width
        
        if self.rectOverlay == nil {
            self.rectOverlay = CAShapeLayer.init()
            self.rectOverlay?.frame = CGRect.init(x: -startX, y: 0, width: rWidth, height: sHeight)
            self.rectOverlay?.fillRule = .evenOdd
            self.rectOverlay?.fillColor = UIColor.init(red: 73/255.0, green: 130/255.0, blue: 180/255.0, alpha: 0.3).cgColor
            self.rectOverlay?.strokeColor = UIColor.green.cgColor
            self.rectOverlay?.lineWidth = pathLineWidth
        }
        if self.rectOverlay?.superlayer == nil {
            self.layer.masksToBounds = true;
            self.layer.addSublayer(self.rectOverlay!)
        }
        
        let path:UIBezierPath = UIBezierPath.init()
        path.move(to: CGPoint.init(x: rWidth*tl_x, y: sHeight - topLeft.y*ts))
        path.addLine(to: CGPoint.init(x: rWidth*tr_x, y: sHeight - topRight.y*ts))
        path.addLine(to: CGPoint.init(x: rWidth*br_x, y: sHeight - bottomRight.y*ts))
        path.addLine(to: CGPoint.init(x: rWidth*bl_x, y: sHeight - bottomLeft.y*ts))
        path.close()
        
        let rectPath:UIBezierPath = UIBezierPath.init(rect: CGRect.init(x: -pathLineWidth-startX, y: -pathLineWidth, width: rWidth + (2 * pathLineWidth), height: sHeight + (2 * pathLineWidth)))
        rectPath.usesEvenOddFillRule = true
        rectPath.append(path)
        self.rectOverlay?.path = rectPath.cgPath
    }
    
    private func correctPerspective(image:CIImage, rectangleFeature:CIRectangleFeature) -> CIImage{
        var parameters:[String:Any] = Dictionary.init()
        parameters["inputTopLeft"] = CIVector.init(cgPoint:rectangleFeature.topLeft)
        parameters["inputTopRight"] = CIVector.init(cgPoint:rectangleFeature.topRight)
        parameters["inputBottomLeft"] = CIVector.init(cgPoint:rectangleFeature.bottomLeft)
        parameters["inputBottomRight"] = CIVector.init(cgPoint:rectangleFeature.bottomRight)
        return image.applyingFilter("CIPerspectiveCorrection", parameters: parameters)
    }
    
    private func turnTorch(on:Bool){
        if self.inputDevice?.device == self.backDevice {
            if self.backDevice!.hasTorch && self.backDevice!.hasFlash {
                try? self.backDevice!.lockForConfiguration()
                if on {
                    self.backDevice?.torchMode = .on
                }
            }
        }
    }
    
    // MARK: - 操作
    
    /// 开始运行
    open func startRunning(){
        self.captureSession.startRunning()
        if self.isRectangleDetection {//开启矩形检测
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.22, repeats: true) {[weak self] time in
                self?.borderDetectFrame = true;
            }
            self.timer?.fire()
        }
    }
    
    /// 停止运行
    open func stopRunning(){
        self.captureSession.stopRunning()
        self.timer?.invalidate()
    }
    
    
    /// 拍照操作
    open func photographOperation(){
        let settings = AVCapturePhotoSettings.init()
        if self.flashMode == .on {
            settings.flashMode = .on
        }else if self.flashMode == .off{
            settings.flashMode = .off
        }else if self.flashMode == .auto{
            settings.flashMode = .auto
        }else{
            settings.flashMode = .off
        }
        self.stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /// 开始录制视频
    /// - Parameter fileURL: 存放地址地址
    open func startRecording(fileURL:URL){
        if !self.movieFileOutput.isRecording {
            self.movieFileOutput.startRecording(to: fileURL, recordingDelegate: self)
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] time in
                self?.timeValue += 1;
                self?.recordingResult?(self!.timeValue, nil)
            }
            self.timer?.fire()
        }
    }
    
    /// 停止录制视频
    open func stopRecording(){
        self.timeValue = -1
        self.timer?.invalidate()
        self.timer = nil
        self.movieFileOutput.stopRecording()
        if self.isRectangleDetection {
            self.rectOverlay?.path = nil
        }
    }
    
    /// TODO:切换摄像头
    open func swithCamera(){
        if self.inputDevice != nil {
            self.captureSession.stopRunning()
            self.captureSession.beginConfiguration()
            self.captureSession.removeInput(self.inputDevice!)
            if self.inputDevice!.device == self.backDevice {
                self.inputDevice = try? AVCaptureDeviceInput.init(device: self.frontDevice!)
            }else{
                self.inputDevice = try? AVCaptureDeviceInput.init(device: self.backDevice!)
            }
            self.captureSession.addInput(self.inputDevice!)
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !self.borderDetectFrame || !CMSampleBufferIsValid(sampleBuffer) {
            return
        }
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            var image = CIImage.init(cvPixelBuffer: pixelBuffer)
            let transform:CIFilter =  CIFilter.init(name: "CIAffineTransform")!
            transform.setValue(image, forKey: String(kCIInputImageKey))
            let rotation = NSValue.init(cgAffineTransform: CGAffineTransform.init(rotationAngle: -90*(CGFloat(Float.pi)/180.0)))
            transform.setValue(rotation, forKey: "inputTransform")
            image = transform.outputImage!
            let features = self.highDetector?.features(in: image)
            self.borderDetectFrame = false
            
            if let list = self.transformationRectangles(rectangles: features!){
                if let rc:CIRectangleFeature = self.queryBiggestRectangle(rectangles: list) {
                    DispatchQueue.main.async {
                        self.drawBorder(imageRect: image.extent, topLeft: rc.topLeft, topRight: rc.topRight, bottomLeft: rc.bottomLeft, bottomRight: rc.bottomRight)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.rectOverlay?.path = nil
                }
            }
        }
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if error != nil {
            self.imageResult?(nil,error)
        }else{
            let hub:MBProgressHUD = SRHelper.showHud(message: "处理中...", addto: self)
            DispatchQueue.global().async {
                if let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                    if self.isRectangleDetection {//开启矩形检测
                        var enhancedImage = CIImage.init(data: imageData)
                        let features = self.highDetector?.features(in: enhancedImage!)
                        if let rectangle = self.queryBiggestRectangle(rectangles: features as! [CIRectangleFeature]) {
                            enhancedImage = self.correctPerspective(image: enhancedImage!, rectangleFeature: rectangle)
                        }
                        UIGraphicsBeginImageContext(CGSize.init(width: enhancedImage!.extent.size.height, height: enhancedImage!.extent.size.width))
                        UIImage.init(ciImage: enhancedImage!, scale: 1, orientation: .right).draw(in: CGRect.init(x: 0, y: 0, width: enhancedImage!.extent.size.height, height: enhancedImage!.extent.size.width))
                        let image = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        DispatchQueue.main.async {
                            SRHelper.hideHud(hud: hub)
                            self.imageResult?(image,nil)
                        }
                    }else{
                        DispatchQueue.main.async {
                            SRHelper.hideHud(hud: hub)
                            self.imageResult?(UIImage.init(data: imageData),nil)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        SRHelper.hideHud(hud: hub)
                        let err:NSError = NSError.init(domain: "图片无数据，无法合成图片", code: -1, userInfo: nil)
                        self.imageResult?(nil,err as Error)
                    }
                }
            }
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let hub:MBProgressHUD = SRHelper.showHud(message: "压缩视频中...", addto: self)
        SRHelper.videoZip(sourceUrl: outputFileURL, tagerUrl: nil) { [weak self] (url) in
            DispatchQueue.main.async {
                SRHelper.hideHud(hud: hub)
                self?.recordingResult?(self?.timeValue ?? -1, url)
            }
        }
//        self.recordingResult?(self.timeValue, outputFileURL)
    }
}
