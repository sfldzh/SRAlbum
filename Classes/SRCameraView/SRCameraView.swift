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

public enum SRFlashMode:Int{
    case off//关闭
    case on//开启
    case auto//自动
}

@available(iOS 10.0, *)
class SRCameraView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    open var result:((_ image:UIImage?, _ error:Error?)->Void)?
    open var flashMode: SRFlashMode = .off
    
    private lazy var videoLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init()
    private lazy var captureSession = AVCaptureSession.init()
    private lazy var backDevice:AVCaptureDevice? = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.back)
    private lazy var frontDevice:AVCaptureDevice? = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.front)
    private lazy var stillImageOutput:AVCapturePhotoOutput = AVCapturePhotoOutput.init()
    private lazy var highDetector:CIDetector? = CIDetector.init(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
    private var inputDevice:AVCaptureDeviceInput?
    
    
    private var timer:Timer?;
    private var imageDedectionConfidence:CGFloat = 0.0
    private var rectOverlay:CAShapeLayer?
    private var borderDetectFrame:Bool = true;
    private let pathLineWidth:CGFloat = 2
    private var isRectangleDetection:Bool = false//开启矩形检测
    private var captureQueue:DispatchQueue?
    
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
        self.captureSession.sessionPreset = .hd1280x720
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
                    
                    self.captureSession.addOutput(self.stillImageOutput)
                    
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
    
    private func angleFromPoint(value:NSValue,cen:CGPoint) -> NSNumber{
        let point = value.cgPointValue
        let theta = atan2f(Float(point.y - cen.y), Float(point.x - cen.x))
        let angle = fmodf(Float(Float.pi - Float.pi/4 + theta), 2 * Float.pi)
        return NSNumber.init(value: angle)
    }
    
    private func queryBiggestRectangle(rectangles:[CIRectangleFeature]) -> CIRectangleFeature?{
        var halfPerimiterValue:Float = 0
        var rectangle = rectangles.first
        for rect:CIRectangleFeature in rectangles {
            let width = hypotf(Float(rect.topLeft.x - rect.topRight.x), Float(rect.topLeft.y - rect.topRight.y))
            let height = hypotf(Float(rect.topLeft.x - rect.bottomLeft.x), Float(rect.topLeft.y - rect.bottomLeft.y))
            let currentHalfPerimiterValue = height + width
            if halfPerimiterValue < currentHalfPerimiterValue {
                halfPerimiterValue = currentHalfPerimiterValue
                rectangle = rect;
            }
        }
        return rectangle
    }
    
    private func biggestRectangle(rectangles:[CIRectangleFeature]) -> CIFeatureRect?{
        if rectangles.count == 0 {
            print("没有检测到矩形")
            return nil
        }else{
            print("检测到矩形")
            let rectangle = self.queryBiggestRectangle(rectangles: rectangles)
            let points = [NSValue.init(cgPoint: rectangle!.topLeft),
                          NSValue.init(cgPoint: rectangle!.topRight),
                          NSValue.init(cgPoint: rectangle!.bottomLeft),
                          NSValue.init(cgPoint: rectangle!.bottomRight)]
            var min = points.first!.cgPointValue
            var max = min
            for value in points {
                let point = value.cgPointValue
                min.x = CGFloat(fminf(Float(point.x), Float(min.x)))
                min.y = CGFloat(fminf(Float(point.y), Float(min.y)))
                max.x = CGFloat(fmaxf(Float(point.x), Float(max.x)))
                max.y = CGFloat(fmaxf(Float(point.y), Float(max.y)))
            }
            let cen = CGPoint.init(x: 0.5 * min.x + max.x, y: 0.5 * (min.y + max.y))
//            let sortedPoints = points.sorted { (a:NSValue, b:NSValue) -> Bool in
//                let result = angleFromPoint(value: a,cen: cen).compare(angleFromPoint(value: b,cen: cen))
//                return result == .orderedAscending
//            }
            let sortedPoints = CameraTool.sortedArray(usingComparator: points, center: cen)
            return CIFeatureRect.init(topLeft: (sortedPoints[3] as AnyObject).cgPointValue, topRight: (sortedPoints[2] as AnyObject).cgPointValue, bottomRight: (sortedPoints[1] as AnyObject).cgPointValue, bottomLeft: (sortedPoints[0] as AnyObject).cgPointValue)
        }
    }
    
    private func drawBorderDetectRect(imageRect:CGRect,topLeft:CGPoint,topRight:CGPoint,bottomLeft:CGPoint,bottomRight:CGPoint){
        if self.rectOverlay == nil {
            self.rectOverlay = CAShapeLayer.init()
            self.rectOverlay?.fillRule = .evenOdd
            self.rectOverlay?.fillColor = UIColor.init(red: 73/255.0, green: 130/255.0, blue: 180/255.0, alpha: 0.3).cgColor
            self.rectOverlay?.strokeColor = UIColor.green.cgColor
            self.rectOverlay?.lineWidth = pathLineWidth
        }
        if self.rectOverlay?.superlayer == nil {
            self.layer.masksToBounds = true;
            self.layer.addSublayer(self.rectOverlay!)
        }
        let featureRect:CIFeatureRect = transfromRealRect(previewRect: self.bounds, imageRect: imageRect, isUICoordinate: true, topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        let path:UIBezierPath = UIBezierPath.init()
        path.move(to: featureRect.topLeft)
        path.addLine(to: featureRect.topRight)
        path.addLine(to: featureRect.bottomRight)
        path.addLine(to: featureRect.bottomLeft)
        path.close()
        let rectPath:UIBezierPath = UIBezierPath.init(rect: CGRect.init(x: -pathLineWidth, y: -pathLineWidth, width: self.bounds.size.width + (2 * pathLineWidth), height: self.bounds.size.height + (2 * pathLineWidth)))
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
    
    /// TODO:开始运行
    open func startRunning(){
        self.captureSession.startRunning()
        if self.isRectangleDetection {//开启矩形检测
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.22, repeats: true) {[weak self] time in
                self?.borderDetectFrame = true;
            }
            self.timer?.fire()
        }
    }
    
    open func stopRunning(){
        self.captureSession.stopRunning()
        self.timer?.invalidate()
    }
    
    /// TODO:拍照操作
    open func photographOperation(){
        let settings = AVCapturePhotoSettings.init()
        if !self.isRectangleDetection {
            if self.flashMode == .on {
                settings.flashMode = .on
            }else if self.flashMode == .off{
                settings.flashMode = .off
            }else if self.flashMode == .auto{
                settings.flashMode = .auto
            }else{
                settings.flashMode = .off
            }
        }
        self.stillImageOutput.capturePhoto(with: settings, delegate: self)
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
            
            if let borderDetectLastRectangleFeature = self.biggestRectangle(rectangles: features as! [CIRectangleFeature]) {
                self.imageDedectionConfidence += 0.5
                if self.imageDedectionConfidence > 1.0 {
                    DispatchQueue.main.async {
                        self.drawBorderDetectRect(imageRect: image.extent, topLeft: borderDetectLastRectangleFeature.topLeft, topRight: borderDetectLastRectangleFeature.topRight, bottomLeft: borderDetectLastRectangleFeature.bottomLeft, bottomRight: borderDetectLastRectangleFeature.bottomRight)
                    }
                }
                
            }else{
                DispatchQueue.main.async {
                    self.imageDedectionConfidence = 0
                    self.rectOverlay?.path = nil
                }
            }
        }
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if error != nil {
            self.result?(nil,error)
        }else{
            if let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                if self.isRectangleDetection {//开启矩形检测
                    var enhancedImage = CIImage.init(data: imageData)
                    if self.imageDedectionConfidence > 1.0 {
                        let features = self.highDetector?.features(in: enhancedImage!)
                        if let rectangle = self.queryBiggestRectangle(rectangles: features as! [CIRectangleFeature]) {
                            enhancedImage = self.correctPerspective(image: enhancedImage!, rectangleFeature: rectangle)
                        }
                    }
                    UIGraphicsBeginImageContext(CGSize.init(width: enhancedImage!.extent.size.height, height: enhancedImage!.extent.size.width))
                    UIImage.init(ciImage: enhancedImage!, scale: 1, orientation: .right).draw(in: CGRect.init(x: 0, y: 0, width: enhancedImage!.extent.size.height, height: enhancedImage!.extent.size.width))
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    self.result?(image,nil)
                }else{
                    self.result?(UIImage.init(data: imageData),nil)
                }
            }else{
                let err:NSError = NSError.init(domain: "图片无数据，无法合成图片", code: -1, userInfo: nil)
                self.result?(nil,err as Error)
            }
        }
    }
}
