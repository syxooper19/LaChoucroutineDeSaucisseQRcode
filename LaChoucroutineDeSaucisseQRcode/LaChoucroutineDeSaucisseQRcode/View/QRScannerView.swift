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
    func qrScanningSucceededWithCode(_ str: String?, andPhoto photo: UIImage?)
    func qrScanningDidStop()
}

class QRScannerView: UIView {
    
    weak var delegate: QRScannerViewDelegate?
    var codeFound: String?
    var captureSession: AVCaptureSession?
    var alreadyScannedOnce: Bool = false
    let capturePhotoOutput = AVCapturePhotoOutput()
    let metaDataOutput = AVCaptureMetadataOutput()
    
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
        
        if (captureSession?.canAddOutput(metaDataOutput) ?? false) {
            captureSession?.addOutput(metaDataOutput)
            
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [.qr, .ean13]
        } else {
            scanningDidFail()
            return
        }
        
        

        //--------------------
              
        if (captureSession?.canAddOutput(capturePhotoOutput) ?? false){
              captureSession?.addOutput(capturePhotoOutput)
            //added capture photo output
        }
        //--------------------
        
        
        self.layer.session = captureSession
        self.layer.videoGravity = .resizeAspectFill
        
        captureSession?.startRunning()
    }
    
    
    func scanningDidFail() {
        delegate?.qrScanningDidFail()
        captureSession = nil
    }
    
    func found(code: String) {
        codeFound = code
        
        //Et la on sauvegarde la photo
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        //stopScan()
        if (!alreadyScannedOnce) {
            alreadyScannedOnce = true
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                

                
                found(code: stringValue)
            }
        }
        
    }
    
}



extension QRScannerView: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        print("func photoOutput")
        //screenshotEnCours = false
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        let qrImage = UIImage(data: imageData)
        
        //testImageView.image = qrImage
        //UIImageWriteToSavedPhotosAlbum(qrImage!, self, #selector(image), nil)

        //Et on prévient qu'on a scanné
        delegate?.qrScanningSucceededWithCode(codeFound, andPhoto: qrImage)
        
        stopScan()
     }
    
    
    
   @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print("erreur func image")
            print(error)
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            print("Ca marche batard")
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        }
    }
    
    
 
}


