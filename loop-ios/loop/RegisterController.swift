//
//  RegisterController.swift
//  loop
//
//  Created by Yecol Hsu on 07/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit
import SwiftValidator
import UserNotifications
import TTTAttributedLabel

fileprivate let kButtonPadding: CGFloat = 12;

class RegisterController: UIViewController, UNUserNotificationCenterDelegate, TTTAttributedLabelDelegate {

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

    private lazy var pwdIndicator: UIImageView = {
        let imageView = UIImageView();
        imageView.image = UIImage(named: "login-password");
        imageView.contentMode = .center
        return imageView;
    }()

    private lazy var pwdReIndicator: UIImageView = {
        let imageView = UIImageView();
        imageView.image = UIImage(named: "login-password");
        imageView.contentMode = .center
        return imageView;
    }()

    private lazy var separator1: UIView = {
        let view = UIView();
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        return view;
    }()

    private lazy var separator2: UIView = {
        let view = UIView();
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        return view;
    }()

    private lazy var inputBgView: UIView = {
        let view = UIView();
        view.backgroundColor = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 0.36)
        view.layer.cornerRadius = 6.0;
        view.clipsToBounds = true;
        return view;
    }()


    private lazy var registerBtn: UIButton = {
        let button = UIButton(type: .custom);
        button.backgroundColor = UIColor.white;
        button.setTitle("kButton_Register_Register_Normal".localized, for: .normal)
        button.setTitleColor(CL_GREEN_DEFAULT, for: .normal);
        button.titleLabel!.font = fontMontserrat21
        button.layer.cornerRadius = 6.0;
        button.clipsToBounds = true;
        button.addTarget(self, action: #selector(self.registerBtnPressed), for: .touchUpInside);
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

    private lazy var passwordField: UITextField = {
        let field = UITextField();
        field.autocapitalizationType = .none;
        let passwordPh = NSAttributedString(string: "kPassword".localized, attributes:
        [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.8)])
        field.attributedPlaceholder = passwordPh;
        field.textColor = UIColor.white;
        field.isSecureTextEntry = true;
        return field
    }()

    private lazy var passwordReField: UITextField = {
        let field = UITextField();
        field.autocapitalizationType = .none;
        let passwordPh = NSAttributedString(string: "kRePassword".localized, attributes:
        [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.8)])
        field.attributedPlaceholder = passwordPh;
        field.textColor = UIColor.white;
        field.isSecureTextEntry = true;
        return field
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
    
    private lazy var termLabel: TTTAttributedLabel = { [unowned self] in
        let attrLabel = TTTAttributedLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40));
        attrLabel.textColor = UIColor(white: 1.0, alpha: 0.8);
        attrLabel.font = fontSystem14;
        let dict = [NSUnderlineStyleAttributeName: false,
                    kCTForegroundColorAttributeName as AnyHashable: UIColor(white: 1.0, alpha: 0.8),
                    NSFontAttributeName: fontSystem14Bold] as [AnyHashable : Any];
        attrLabel.linkAttributes = dict
        attrLabel.activeLinkAttributes = dict;
        
        attrLabel.lineBreakMode = .byWordWrapping;
        attrLabel.numberOfLines = 0;
        attrLabel.textAlignment = .center;
        attrLabel.delegate = self;
        
        var termRange = NSMakeRange(NSNotFound, 0);
        var privacyRange = NSMakeRange(NSNotFound, 0);
        
        let content:NSMutableString = "You hereby agree to "
        let term:NSString = "Loop Online Service Agreement"
        let privacy:NSString = "Privacy Policy"
        
        termRange.location = content.length;
        termRange.length = term.length;
        
        content.append(term as String);
        content.append(" and ".localized);
        
        privacyRange.location = content.length;
        privacyRange.length = privacy.length;
        
        content.append(privacy as String);
        
        let attributedText = NSMutableAttributedString(string: content as String);
        
        attributedText.setAttributes([NSForegroundColorAttributeName: CL_LINK_COLOR], range: termRange);
        attributedText.setAttributes([NSForegroundColorAttributeName: CL_LINK_COLOR], range: privacyRange);
        
        attrLabel.setText(attributedText, afterInheritingLabelAttributesAndConfiguringWith: { attrString in
            return attrString
        })
        
        attrLabel.addLink(to: URL(string: "terms"), with: termRange);
        attrLabel.addLink(to: URL(string: "privacy"), with: privacyRange);
        
        return attrLabel;
        }()

    let validator = Validator();

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(bgImageView);
        self.view.addSubview(logoImageView);
        self.view.addSubview(inputBgView);
        self.view.addSubview(emailIndicator);
        self.view.addSubview(pwdIndicator)
        self.view.addSubview(pwdReIndicator)
        self.view.addSubview(emailField);
        self.view.addSubview(passwordField);
        self.view.addSubview(passwordReField);
        self.view.addSubview(separator1);
        self.view.addSubview(separator2);
        self.view.addSubview(registerBtn);
        self.view.addSubview(cancelBtn);
        self.view.addSubview(termLabel);

        self.addLayoutConstraints();

        validator.registerField(emailField, rules: [RequiredRule(message: "kRuleEmailRequired".localized), EmailRule(message: "kRuleEmailFormatd".localized)]);
        validator.registerField(passwordField, rules: [RequiredRule(message: "kRulePwdRequired".localized)]);
        validator.registerField(passwordReField, rules: [RequiredRule(message: "kRulePwdRequired".localized),ConfirmationRule(confirmField: passwordField, message:"kRulePwdRepeatMatch".localized)]);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(true, animated: true);
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true);
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
            make.height.equalTo(152);
            make.centerX.equalToSuperview();
            make.top.equalTo(self.logoImageView.snp.bottom).offset(40);
        }

        self.separator1.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.inputBgView);
            make.height.equalTo(1);
            make.centerX.equalToSuperview();
            make.top.equalTo(self.inputBgView).offset(50);
        }

        self.separator2.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.inputBgView);
            make.height.equalTo(1);
            make.centerX.equalToSuperview();
            make.top.equalTo(self.inputBgView).offset(101);
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

        self.passwordField.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(self.emailField);
            make.top.equalTo(self.emailField.snp.bottom);
            make.left.equalTo(self.emailField);
        }

        self.pwdIndicator.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(50);
            make.height.equalTo(50);
            make.top.equalTo(self.passwordField);
            make.left.equalTo(self.inputBgView);
        }

        self.passwordReField.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(self.emailField);
            make.top.equalTo(self.passwordField.snp.bottom);
            make.left.equalTo(self.emailField);
        }

        self.pwdReIndicator.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(50);
            make.height.equalTo(50);
            make.top.equalTo(self.passwordReField);
            make.left.equalTo(self.inputBgView);
        }

        self.registerBtn.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kScreenW * 0.8);
            make.height.equalTo(50);
            make.left.equalTo(self.inputBgView);
            make.top.equalTo(self.inputBgView.snp.bottom).offset(kButtonPadding);
        }

        self.cancelBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(15);
            make.width.equalTo(registerBtn);
            make.top.equalTo(self.registerBtn.snp.bottom).offset(kButtonPadding)
            make.left.equalTo(self.inputBgView);
        }
        
        self.termLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(40);
            make.width.equalToSuperview().offset(-40);
            make.bottom.equalToSuperview().offset(-40);
            make.centerX.equalToSuperview();
        }
    }

    func registerBtnPressed() {

        self.validator.validate({ errors in
            if (errors.count == 0) {

                self.showProgress()
                self.register(emailField.text!, passwd: passwordField.text!);
                self.hideProgress();

            } else {
                for (field, error) in errors {
                    self.displayAlertView(error.errorMessage);
                    return;
                }
            }
        });
    }

    func cancelBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true);
    }

    private func register(_ email: String, passwd: String) {
        print("begin register");

        let user: AVUser = AVUser()
        user.username = email
        user.password = passwd
        user.email = email
        user.signUpInBackground({ (succeeded: Bool, error: Error?) in
            if (self.filterError(error)) {
                //self.displayAlertView("sign up successfully.");
                print("用户注册成功 \(user)")
                UserDefaults.standard.set(AVOSCloud.getApplicationId(), forKey: "appid");
                let installation = AVInstallation.current();
                installation.setObject(AVUser.current(), forKey: KEY_USER);
                installation.save()
                let registerDetailController = RegisterDetailController(style: .grouped);
                self.navigationController?.pushViewController(registerDetailController, animated: true)
            }
        })
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        let controller = WebViewController();
        if(url.absoluteString == "terms"){
            controller.setAsTerm();
        }else{
            controller.setAsPrivacy();
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        self.navigationController?.pushViewController(controller, animated: true);
    }
}
