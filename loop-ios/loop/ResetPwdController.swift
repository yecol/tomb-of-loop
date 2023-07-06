//
//  ResetPwdController.swift
//  loop
//
//  Created by Yecol Hsu on 01/04/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import SwiftValidator

fileprivate let kButtonPadding: CGFloat = 12;

class ResetPwdController: UIViewController {

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.image = UIImage(named: "logo-frame");
        return imageView;
    }()

    private lazy var bgImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.image = UIImage(named: "login-bg");
        return imageView;
    }()

    private lazy var emailIndicator: UIImageView = {
        let imageView = UIImageView();
        imageView.image = UIImage(named: "login-email");
        imageView.contentMode = .center
        return imageView;
    }()

    private lazy var inputBgView: UIView = {
        let view = UIView();
        view.backgroundColor = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 0.36)
        view.layer.cornerRadius = 6.0;
        view.clipsToBounds = true;
        return view;
    }()

    private lazy var cancelBtn: UIButton = {
        let button = UIButton(type: .custom);
        button.setTitle("kCancel".localized, for: .normal);
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.8), for: .normal);
        button.titleLabel!.font = fontSystem12;
        button.titleLabel!.textAlignment = .left;
        button.addTarget(self, action: #selector(self.cancelBtnPressed), for: .touchUpInside);
        return button
    }()

    private lazy var resetBtn: UIButton = {
        let button = UIButton(type: .custom);
        button.backgroundColor = UIColor.white;
        button.setTitle("kReset".localized, for: .normal)
        button.setTitleColor(CL_GREEN_DEFAULT, for: .normal);
        button.titleLabel!.font = fontMontserrat21
        button.layer.cornerRadius = 6.0;
        button.clipsToBounds = true;
        button.addTarget(self, action: #selector(self.resetBtnPressed), for: .touchUpInside);
        return button
    }()


    private lazy var emailField: UITextField = {
        let field = UITextField();
        field.autocapitalizationType = .none;
        let emailPh = NSAttributedString(string: "kEmail".localized, attributes:
        [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.8)])
        field.attributedPlaceholder = emailPh;
        field.textColor = UIColor.white;
        return field
    }()

    let validator = Validator();

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(bgImageView);
        self.view.addSubview(logoImageView);
        self.view.addSubview(inputBgView);
        self.view.addSubview(emailIndicator);
        self.view.addSubview(emailField);
        self.view.addSubview(cancelBtn)
        self.view.addSubview(resetBtn);
        self.addLayoutConstraints();
        validator.registerField(emailField, rules: [RequiredRule(message: "kRuleEmailRequired".localized),EmailRule(message: "kRuleEmailFormat".localized)]);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true);
    }

    func resetBtnPressed() {

        self.validator.validate({ errors in
            if (errors.count == 0) {
                self.showProgress()
                AVUser.requestPasswordResetForEmail(inBackground: emailField.text!, block: { (success, error) in
                    self.hideProgress();
                    if (self.filterError(error)) {
                        if (success == true) {
                            self.showComplete(with: "kToastResetEmailSent".localized);
                        }
                    }
                });
            } else {
                for (field, error) in errors {
                    self.displayAlertView(error.errorMessage);
                    return;
                }
            }
        });

    }

    func cancelBtnPressed() {
        self.navigationController?.popViewController(animated: true);
    }


    private func addLayoutConstraints() {
        self.bgImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview();
            make.height.equalToSuperview();
            make.center.equalToSuperview();
        }
        self.logoImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(70);
            make.height.equalTo(90);
            make.centerX.equalToSuperview();
            make.top.equalToSuperview().offset(120);
        }

        self.inputBgView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kScreenW * 0.8);
            make.height.equalTo(50);
            make.centerX.equalToSuperview();
            make.top.equalTo(self.logoImageView.snp.bottom).offset(40);
        }

        self.emailField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.inputBgView).offset(-60);
            make.height.equalTo(50);
            make.left.equalTo(self.inputBgView).offset(60);
            make.top.equalTo(self.inputBgView);
        }

        self.emailIndicator.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(50);
            make.height.equalTo(50);
            make.top.equalTo(self.emailField);
            make.left.equalTo(self.inputBgView);
        }

        self.resetBtn.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kScreenW * 0.8);
            make.height.equalTo(50);
            make.left.equalTo(self.inputBgView);
            make.top.equalTo(self.inputBgView.snp.bottom).offset(kButtonPadding);
        }

        self.cancelBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(15);
            make.width.equalTo(resetBtn);
            make.top.equalTo(self.resetBtn.snp.bottom).offset(kButtonPadding)
            make.left.equalTo(self.inputBgView);
        }

    }

}
