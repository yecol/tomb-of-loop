//
//  ShareController.swift
//  loop
//
//  Created by Yecol Hsu on 07/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

import FacebookShare
import Fabric
import TwitterKit

let kShareBtnSize: CGSize = CGSize.init(width: 75, height: 75);
let kShareTitleTopMargin: CGFloat = 120;
let kShareBtnSpacing: CGFloat = 35;
let kShareWordingTop: CGFloat = 10;

class ShareController: UIViewController {

    var shareSheet: UIImage?;

    private lazy var shareTitle: UILabel = {
        let label = UILabel();
        label.textColor = CL_GREEN_DEFAULT;
        label.font = fontMontserrat18;
        label.text = "kTitle_ShareBadge".localized
        label.textAlignment = .center;

//        label.layer.shadowOpacity = 0.4;
//        label.layer.shadowRadius = 3.0;
//        label.layer.shadowColor = UIColor.black.cgColor
//        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0);
        return label;
    }()

//    private lazy var share2Feed: UIButton = {
//        let btn = UIButton();
//        btn.setBackgroundImage(UIImage(named: "share-feed"), for: UIControlState());
//        btn.addTarget(self, action: #selector(self.share2NewsBtnPressed), for: .touchUpInside);
//        return btn;
//    }()

    private lazy var share2Facebook: UIButton = {
        let btn = UIButton();
        btn.setBackgroundImage(UIImage(named: "share-facebook"), for: UIControlState());
        btn.addTarget(self, action: #selector(self.share2FacebookBtnPressed), for: .touchUpInside);
        return btn;
    }()

    private lazy var share2Twitter: UIButton = {
        let btn = UIButton();
        btn.setBackgroundImage(UIImage(named: "share-twitter"), for: UIControlState());
        btn.addTarget(self, action: #selector(self.share2TwitterPressed), for: .touchUpInside);
        return btn;
    }()

    private lazy var cancelBtn: UIButton = {
        let btn = UIButton();
        btn.setBackgroundImage(UIImage(named: "share-cancel"), for: UIControlState());
        btn.addTarget(self, action: #selector(self.cancelBtnPressed), for: .touchUpInside);
        return btn;
    }()

//    private lazy var share2FeedLabel: UILabel = {
//        let label = UILabel();
//        label.text = "News";
//        label.font = fontSystem14;
//        label.textColor = CL_BLACK_GRACE;
//        return label;
//    }()

    private lazy var share2FacebookLabel: UILabel = {
        let label = UILabel();
        label.text = "Facebook";
        label.font = fontSystem14;
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()

    private lazy var share2TwitterLabel: UILabel = {
        let label = UILabel();
        label.text = "Twitter";
        label.font = fontSystem14;
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()

    private lazy var cancelBtnLabel: UILabel = {
        let label = UILabel();
        label.text = "kCancel".localized;
        label.font = fontSystem14;
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clear
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            print("not available blur effect")
            self.view.backgroundColor = CL_GREY_BG_EC;
        }

        self.view.addSubview(shareTitle);

//        self.view.addSubview(share2Feed);
        self.view.addSubview(share2Facebook);
        self.view.addSubview(share2Twitter);

//        self.view.addSubview(share2FeedLabel);
        self.view.addSubview(share2FacebookLabel);
        self.view.addSubview(share2TwitterLabel);

        self.view.addSubview(cancelBtn);
        self.view.addSubview(cancelBtnLabel);

        self.addLayoutConstraints();
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func addLayoutConstraints() {
        self.shareTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(kShareTitleTopMargin);
            make.centerX.equalToSuperview();
            make.width.equalToSuperview()
            make.height.equalTo(40);
        }

        self.share2Facebook.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.shareTitle.snp.bottom).offset(50);
            make.centerX.equalToSuperview().offset(-kShareBtnSpacing - kShareBtnSize.width / 2);
            make.size.equalTo(kShareBtnSize);
        }

//        self.share2Feed.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo(self.share2Facebook)
//            make.right.equalTo(self.share2Facebook.snp.left).offset(-kShareBtnSpacing);
//            make.size.equalTo(kShareBtnSize)
//        }

        self.share2Twitter.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.share2Facebook)
            make.centerX.equalToSuperview().offset(kShareBtnSpacing + kShareBtnSize.width / 2)
//            make.left.equalTo(self.share2Facebook.snp.right).offset(kShareBtnSpacing);
            make.size.equalTo(kShareBtnSize)
        }

//        self.share2FeedLabel.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo(self.share2Feed.snp.bottom).offset(kShareWordingTop);
//            make.centerX.equalTo(self.share2Feed);
//        }

        self.share2FacebookLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.share2Facebook.snp.bottom).offset(kShareWordingTop);
            make.centerX.equalTo(self.share2Facebook);
        }

        self.share2TwitterLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.share2Twitter.snp.bottom).offset(kShareWordingTop);
            make.centerX.equalTo(self.share2Twitter);
        }

        self.cancelBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.share2FacebookLabel.snp.bottom).offset(50);
            make.centerX.equalToSuperview();
            make.width.equalTo(kShareBtnSize.width / 2);
            make.height.equalTo(kShareBtnSize.height / 2);
        }

        self.cancelBtnLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.cancelBtn.snp.bottom).offset(kShareWordingTop);
            make.centerX.equalTo(self.cancelBtn);
        }

    }

    func cancelBtnPressed() {
        self.dismiss(animated: true, completion: nil);
    }

    func share2NewsBtnPressed() {
    }

    func share2FacebookBtnPressed() {
        guard let image = shareSheet else {
            return // No image selected.
        }

        let photo = Photo(image: image, userGenerated: true)
        let content = PhotoShareContent(photos: [photo])
        do {
            try ShareDialog.show(from: self, content: content)
        } catch _ {
            displayAlertView("kAlert_NoFacebookInstalled".localized)
        }
    }

    func share2TwitterPressed() {
        let composer = TWTRComposer()

        composer.setText("kTwitterSharingHint".localized)
        composer.setImage(self.shareSheet!)

        composer.show(from: self) { result in
            if (result == TWTRComposerResult.cancelled) {
                print("Tweet composition cancelled")
            } else {
                self.showToast(with: "kToastTwitterSharedSuccess".localized);
//                println("Sending tweet!")
            }
        }
    }

    func share2WechatBtnPressed() {
    }

    func share2WeiboBtnPressed() {
    }

    func share2GplusBtnPressed() {
    }
}
