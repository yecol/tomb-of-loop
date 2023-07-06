//
//  PlusController.swift
//  loop
//
//  Created by Yecol Hsu on 26/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

protocol PostControllerDelegate : class{
    func dismissSilently();
}

class PlusController: UIViewController, PostControllerDelegate {

    private lazy var postTitle: UILabel = {
        let label = UILabel();
        label.textColor = CL_GREEN_DEFAULT;
        label.font = fontMontserrat18;
        label.text = "kTitle_Plus".localized
        label.textAlignment = .center;

//        label.layer.shadowOpacity = 0.4;
//        label.layer.shadowRadius = 3.0;
//        label.layer.shadowColor = UIColor.black.cgColor
//        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0);
        return label;
    }()

    private lazy var postBtn: UIButton = {
        let btn = UIButton();
        btn.setBackgroundImage(UIImage(named: "plus-post"), for: UIControlState());
        btn.addTarget(self, action: #selector(self.postStatusBtnPressed), for: .touchUpInside);
        return btn;
    }()

    private lazy var checkInBtn: UIButton = {
        let btn = UIButton();
        btn.setBackgroundImage(UIImage(named: "plus-checkin"), for: UIControlState());
        btn.addTarget(self, action: #selector(self.checkInBtnPressed), for: .touchUpInside);
        return btn;
    }()

    private lazy var clockInBtn: UIButton = {
        let btn = UIButton();
        btn.setBackgroundImage(UIImage(named: "plus-clockin"), for: UIControlState());
        btn.addTarget(self, action: #selector(self.clockInBtnPressed), for: .touchUpInside);
        return btn;
    }()

    private lazy var cancelBtn: UIButton = {
        let btn = UIButton();
        btn.setBackgroundImage(UIImage(named: "share-cancel"), for: UIControlState());
        btn.addTarget(self, action: #selector(self.cancelBtnPressed), for: .touchUpInside);
        return btn;
    }()

    private lazy var postLabel: UILabel = {
        let label = UILabel();
        label.text = "kButton_Plus_NewPost_Normal".localized;
        label.font = fontSystem14;
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()

    private lazy var checkInLabel: UILabel = {
        let label = UILabel();
        label.text = "kButton_Plus_CheckIn_Normal".localized;
        label.font = fontSystem14;
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()

    private lazy var clockInLabel: UILabel = {
        let label = UILabel();
        label.text = "kButton_Plus_ClockIn_Normal".localized;
        label.font = fontSystem14;
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()

    private lazy var cancelLabel: UILabel = {
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
            self.view.backgroundColor = UIColor.white.withAlphaComponent(0.5);
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.view.backgroundColor = CL_GREY_BG_EC;
        }

        self.view.addSubview(postTitle);
        self.view.addSubview(postBtn);
        self.view.addSubview(checkInBtn);
        self.view.addSubview(clockInBtn);
        self.view.addSubview(cancelBtn)

        self.view.addSubview(postLabel);
        self.view.addSubview(checkInLabel);
        self.view.addSubview(clockInLabel);
        self.view.addSubview(cancelLabel);

        // Do any additional setup after loading the view.
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
        self.postTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(kShareTitleTopMargin);
            make.centerX.equalToSuperview();
            make.width.equalToSuperview()
            make.height.equalTo(40);
        }

        self.checkInBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.postTitle.snp.bottom).offset(50);
            make.centerX.equalToSuperview();
            make.size.equalTo(kShareBtnSize);
        }

        self.postBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.checkInBtn)
            make.right.equalTo(self.checkInBtn.snp.left).offset(-kShareBtnSpacing);
            make.size.equalTo(kShareBtnSize)
        }

        self.clockInBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.checkInBtn)
            make.left.equalTo(self.checkInBtn.snp.right).offset(kShareBtnSpacing);
            make.size.equalTo(kShareBtnSize)
        }

        self.postLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.postBtn.snp.bottom).offset(kShareWordingTop);
            make.centerX.equalTo(self.postBtn);
        }

        self.checkInLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.checkInBtn.snp.bottom).offset(kShareWordingTop);
            make.centerX.equalTo(self.checkInBtn);
        }

        self.clockInLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.clockInBtn.snp.bottom).offset(kShareWordingTop);
            make.centerX.equalTo(self.clockInBtn);
        }

        self.cancelBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.checkInLabel.snp.bottom).offset(50);
            make.centerX.equalToSuperview();
            make.width.equalTo(kShareBtnSize.width / 2);
            make.height.equalTo(kShareBtnSize.height / 2);
        }

        self.cancelLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.cancelBtn.snp.bottom).offset(kShareWordingTop);
            make.centerX.equalTo(self.cancelBtn);
        }

    }


    func cancelBtnPressed() {
        UIApplication.shared.statusBarStyle = .lightContent;
        self.dismiss(animated: true, completion: nil);
    }
    
    func postStatusBtnPressed() {
        let postStatusController = PostNewController()
        postStatusController.delegate = self;
        let postStatusControllerNav = UINavigationController.init(rootViewController: postStatusController)
        self.present(postStatusControllerNav, animated: true, completion: nil);
    }

    func checkInBtnPressed() {
        
        let checkInController = CheckInController(style: .grouped);
        checkInController.delegate = self;
        let checkInControllerNav = UINavigationController.init(rootViewController: checkInController)
        self.present(checkInControllerNav, animated: true, completion: nil);
    }

    func clockInBtnPressed() {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        if(hour < 5 || hour > 7){
            self.displayAlertView("kAlert_ClockInNotValid".localized);
        }
        else{
            self.dismiss(animated: true, completion: {
                DataModelManager.sharedInstance.cloudClockIn({ success, error in
                })
            });
        }
    }
    
    func dismissSilently(){
        self.dismiss(animated: false, completion: nil);
    }

}
