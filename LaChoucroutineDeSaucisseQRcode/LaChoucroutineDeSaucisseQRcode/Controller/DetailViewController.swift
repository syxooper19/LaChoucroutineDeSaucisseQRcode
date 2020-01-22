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

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailLabel.text = qrData?.code
        
        //UIPasteboard.general.string = detailLabel.text
        //showToast(message : "Texte copié dans le presse papier")

        //Config
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: self.view.bounds, configuration: webConfiguration)
        webView.uiDelegate = self
        //webView.navigationDelegate = self
        //view = webView

        
        //Création de l'URL + chargement dans la WebView
        //let myURL = URL(string: qrData?.code ?? "")
        let myURL = URL(string: "https://fr.wikipedia.org")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    
    @IBAction func openInWebAction(_ sender: Any) {
        if let url = URL(string: qrData?.code ?? ""), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            showToast(message : "URL Invalide")
        }
    }
    
    
    


}
