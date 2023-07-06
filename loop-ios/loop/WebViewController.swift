//
//  TextViewController.swift
//  loop
//
//  Created by Yecol Hsu on 15/04/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    let termURL = "http://loopus.com/terms.html";
    let privacyURL = "http://loopus.com/privacy.html";
    let aboutURL = "http://loopus.com/about-ios.html";
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setAsTerm(){
        let webView = UIWebView.init(frame: self.view.bounds);
        webView.loadRequest(URLRequest.init(url: URL.init(string: termURL)!));
        self.title = "kTermsLink".localized;
        self.view.addSubview(webView);
    }
    
    func setAsPrivacy(){
        let webView = UIWebView.init(frame: self.view.bounds);
        webView.loadRequest(URLRequest.init(url: URL.init(string: privacyURL)!));
        self.title = "kPrivacyLink".localized;
        self.view.addSubview(webView);
    }
    
    func setAsAbout(){
        let webView = UIWebView.init(frame: self.view.bounds);
        webView.loadRequest(URLRequest.init(url: URL.init(string: aboutURL)!));
        self.title = "kSettingItemAbout";
        self.view.addSubview(webView);
    }
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
}
