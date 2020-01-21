//
//  DetailViewController.swift
//  LaChoucroutineDeQRcode
//
//  Created by Bastien on 21/01/2020.
//  Copyright © 2020 Bastien. All rights reserved.
//
import UIKit
import WebKit


class DetailViewController: UIViewController, WKUIDelegate {

    @IBOutlet weak var detailLabel: CopyLabel!
    
    var qrData: QRcode?
    //var webView: WKWebView!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailLabel.text = qrData?.code
        UIPasteboard.general.string = detailLabel.text
        showToast(message : "Texte copié dans le presse papier")

        let myURL = URL(string: qrData?.code ?? "")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    @IBAction func openInWebAction(_ sender: Any) {
        if let url = URL(string: qrData?.code ?? ""), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            showToast(message : "Invalide URL")
        }
    }
    
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    


}
