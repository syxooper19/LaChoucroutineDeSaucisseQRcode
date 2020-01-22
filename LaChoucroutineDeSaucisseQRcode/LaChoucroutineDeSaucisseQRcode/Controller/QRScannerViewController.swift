//
//  QRScannerViewController.swift
//  LaChoucroutineDeQRcode
//
//  Created by Bastien on 21/01/2020.
//  Copyright © 2020 Bastien. All rights reserved.
//

import UIKit

class QRScannerViewController: UIViewController {
    
    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }
    
    
    @IBOutlet weak var scanButton: UIButton! {
        didSet {
            scanButton.setTitle("STOP", for: .normal)
        }
    }
    
    var qrData: QRcode? = nil {
        didSet {
            if qrData != nil {
                self.performSegue(withIdentifier: "detailSeuge", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !scannerView.isRunning {
            scannerView.debutScan()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !scannerView.isRunning {
            scannerView.stopScan()
        }
    }

    @IBAction func scanButtonAction(_ sender: UIButton) {
        scannerView.isRunning ? scannerView.stopScan() : scannerView.debutScan()
        let buttonTitle = scannerView.isRunning ? "STOP" : "SCAN"
        sender.setTitle(buttonTitle, for: .normal)
    }
    
    func writeImage(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.finishWriteImage), nil)
    }

    @objc private func finishWriteImage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if (error != nil) {
            // Something wrong happened.
            print("error occurred: \(String(describing: error))")
        } else {
            // Everything is alright.
            print("saved success!")
        }
    }
}


extension QRScannerViewController: QRScannerViewDelegate {
    func qrScanningDidStop() {
        let buttonTitle = scannerView.isRunning ? "STOP" : "SCAN"
        scanButton.setTitle(buttonTitle, for: .normal)
    }
    
    func qrScanningDidFail() {
        presentAlert(withTitre: "Error", message: "Echec du scan. Place ta choucroute autrement et réessaye frérot !")
    }
    
    func qrScanningSucceededWithCode(_ str: String?, andPhoto photo: UIImage?) {
        self.qrData = QRcode(code: str)
        if let photo = photo {
            writeImage(image: photo)
        }
    }
}


extension QRScannerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSeuge", let viewController = segue.destination as? DetailViewController {
            viewController.qrData = self.qrData
        }
    }
}

