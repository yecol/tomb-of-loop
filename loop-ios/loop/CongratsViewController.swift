//
//  CongratsViewController.swift
//  loop
//
//  Created by Yecol Hsu on 07/08/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit
import pop

let kBadgeBGLightSize: CGFloat = 200;
fileprivate let kBadgeSize:CGFloat = 140;

enum BadgeGrantType{
    case grant;
    case upgrade;
}

class CongratsViewController: UIViewController {

    private lazy var bgImage: UIImageView = { [unowned self] in
        let imageView = UIImageView(frame: CGRect.null)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var bgLightImage1: UIImageView = { [unowned self] in
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: kBadgeBGLightSize, height: kBadgeBGLightSize))
        imageView.contentMode = .scaleAspectFit;
        imageView.image = UIImage.init(named: "badge-light-1");
        return imageView
    }()

    private lazy var bgLightImage2: UIImageView = { [unowned self] in
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: kBadgeBGLightSize, height: kBadgeBGLightSize))
        imageView.contentMode = .scaleAspectFit;
        imageView.image = UIImage.init(named: "badge-light-2");
        return imageView
    }()

    private lazy var badgeImage: UIImageView = { [unowned self] in
        let imageView = UIImageView(frame: CGRect.null)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var congratsTitle: UILabel = { [unowned self] in
        let label = UILabel()
        label.textAlignment = .center;
        label.textColor = CL_BLACK_GRACE;
        label.font = fontMontserrat21;
        label.text = "kCongrats_Title".localized
        return label
    }()

    private lazy var congratsDetails: UILabel = { [unowned self] in
        let label = UILabel()
        label.textAlignment = .center;
        label.textColor = CL_BLACK_GRACE;
        label.font = fontSystem14;
        label.text = "kCongrats_Grant".localized
        return label
    }()

    private lazy var badgeName: UILabel = { [unowned self] in
        let label = UILabel()
        label.textAlignment = .center;
        label.textColor = CL_GREEN_DEFAULT;
        label.font = fontHelveticaNeueThin36
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(bgImage)
        self.view.addSubview(bgLightImage1);
        self.view.addSubview(bgLightImage2);

        self.view.addSubview(badgeImage);

        self.view.addSubview(congratsTitle);
        self.view.addSubview(congratsDetails);
        self.view.addSubview(badgeName);

        self.addLayoutConstraints();
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.bgLightImage1.startZRotation(duration: 24, clockwise: true);
        self.bgLightImage2.startZRotation(duration: 24, clockwise: false);


        let anim = POPSpringAnimation.init(propertyNamed: kPOPLayerBounds);
        anim!.toValue = NSValue.init(cgRect: CGRect.init(x: 0, y: 0, width: 150, height: 150));
        anim!.springBounciness = 19;
        // 弹簧弹力 取值范围为[0, 20]，默认值为4
        anim!.springSpeed = 7;
        anim!.beginTime = 0.3 + CACurrentMediaTime();
        self.badgeImage.pop_add(anim, forKey: "size");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func addLayoutConstraints() {
        self.view.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(340)
            make.width.equalTo(200)
        }

        self.bgImage.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(200)
            make.width.equalToSuperview()
        }

        self.badgeImage.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self.bgImage);
            make.height.equalTo(kBadgeSize)
            make.width.equalTo(kBadgeSize)
        }

        self.congratsTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.bgImage.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalToSuperview()
        }

        self.congratsDetails.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.congratsTitle.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalToSuperview()
        }

        self.badgeName.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.congratsDetails.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalToSuperview()
        }

        self.bgLightImage1.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self.badgeImage);
            make.height.equalTo(kBadgeBGLightSize)
            make.width.equalTo(kBadgeBGLightSize)
        }

        self.bgLightImage2.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self.badgeImage);
            make.height.equalTo(kBadgeBGLightSize)
            make.width.equalTo(kBadgeBGLightSize)
        }



    }

    func bindData(_ badge: LPBadge, grantType: BadgeGrantType) {
        self.badgeName.text = badge.name;
        self.bgImage.sd_setImage(with: URL.init(string: badge.background!.url!));
        self.badgeImage.sd_setImage(with: URL.init(string: badge.icon!.url!), placeholderImage: UIImage(named: "ph-badge"));
        if(grantType == .grant){
            self.congratsDetails.text = "kCongrats_Grant".localized;
        }
        else{
            self.congratsDetails.text = "kCongrats_Upgrade".localized;
        }
    }
}
