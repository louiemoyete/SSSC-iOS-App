//
//  ResourcesViewController.swift
//  ScienceStudentSuccessCentre
//
//  Created by Gina Bak on 2018-11-26.
//  Copyright © 2018 Avery Vine. All rights reserved.
//

import UIKit
import WebKit

class ResourcesViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    private var statusBar: UIView!
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = view.center
        activityIndicator.style = .gray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)

        let url = URL(string: "http://sssc.carleton.ca/resources")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true

        statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusBar.backgroundColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        statusBar.backgroundColor = .clear
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }

}