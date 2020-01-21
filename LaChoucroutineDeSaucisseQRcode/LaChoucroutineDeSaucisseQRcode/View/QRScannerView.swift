//
//  QRScannerView.swift
//  LaChoucroutineDeQRcode
//
//  Created by Bastien on 21/01/2020.
//  Copyright © 2020 Bastien. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol QRScannerViewDelegate: class {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ str: String?)
    func qrScanningDidStop()
}

class QRScannerView: UIView {
    
    weak var delegate: QRScannerViewDelegate?
    
    var captureSession: AVCaptureSession?
    
    let laPhoto = AVCapturePhotoOutput()
    var screenshotEnCours = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    
    override class var layerClass: AnyClass  {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
    
}



extension QRScannerView {
    
    
    
    var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }
    
    func debutScan() {
       captureSession?.startRunning()
    }
    
    func stopScan() {
        captureSession?.stopRunning()
        delegate?.qrScanningDidStop()
    }
    

    private func initialSetup() {
        clipsToBounds = true
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error)
            return
        }
        
        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            scanningDidFail()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13]
        } else {
            scanningDidFail()
            return
        }
        
        self.layer.session = captureSession
        self.layer.videoGravity = .resizeAspectFill
        
        captureSession?.startRunning()
    }
    
    
    func scanningDidFail() {
        delegate?.qrScanningDidFail()
        captureSession = nil
    }
    
    func found(code: String) {
        
        //Et la on sauvegarde la photo
        //captureSession?.addOutput(laPhoto)
        
        
        
        delegate?.qrScanningSucceededWithCode(code)
    }
    
}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        stopScan()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            /*
            let photoSettings = AVCapturePhotoSettings()
            if !screenshotEnCours {
                screenshotEnCours = true
                laPhoto.capturePhoto(with: photoSettings, delegate: self)
            }*/
            
            found(code: stringValue)
        }
    }
    
}


/*
extension QRScannerView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        screenshotEnCours = false
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error while generating image from photo capture data.");
            return
        }
        guard let qrImage = UIImage(data: imageData) else {
            print("Unable to generate UIImage from image data.");
            return
        }
        //testImageView.image = qrImage
        UIImageWriteToSavedPhotosAlbum(qrImage, self, #selector(savedImage(_:error:context:)), nil)

     }
    
    
    @objc func savedImage(_ im:UIImage, error:Error?, context:UnsafeMutableRawPointer?) {
        if let err = error {
            print(err)
            return
        }
        print("success")
    }
 
}
*/

