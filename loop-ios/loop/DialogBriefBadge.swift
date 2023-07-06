//
//  DialogBriefBadge.swift
//  loop
//
//  Created by Yecol Hsu on 24/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

fileprivate let kBadgeBriefTopMargin: CGFloat = 30.0
fileprivate let kBadgeSize: CGFloat = 180;
fileprivate let kAlertViewWidth: CGFloat = kScreenW * 0.7;

class DialogBriefBadge: UIViewController {

    private lazy var badgeName: UILabel = { [unowned self] in
        let label = UILabel()
        label.textAlignment = .center;
        label.textColor = CL_BLACK_GRACE;
        label.font = fontHelveticaNeueThin36
        return label
    }()

    private lazy var badgeIntro: UILabel = { [unowned self] in
        let label = UILabel()
        label.textAlignment = .center;
        label.font = fontSystem14;
        label.textColor = CL_BLACK_GRACE;
        label.numberOfLines = 0;
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var badgeImage: UIImageView = { [unowned self] in
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(badgeImage);
        self.view.addSubview(badgeName);
        self.view.addSubview(badgeIntro);

        self.addLayoutConstrains();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func addLayoutConstrains() {

        self.view.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kAlertViewWidth)
        }

        self.badgeImage.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(kBadgeBriefTopMargin)
            make.centerX.equalToSuperview();
            make.width.equalTo(kBadgeSize)
            make.height.equalTo(kBadgeSize)
        }

        self.badgeName.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview();
            make.centerX.equalToSuperview();
            make.height.equalTo(45);
            make.top.equalTo(self.badgeImage.snp.bottom).offset(10);
        }

        self.badgeIntro.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview().offset(-18);
            make.centerX.equalToSuperview();
            make.top.equalTo(self.badgeName.snp.bottom).offset(10);
            make.bottom.lessThanOrEqualToSuperview().offset(-kBadgeBriefTopMargin)
        }
    }


    func setData(badge: LPBadge) {

        self.badgeName.text = badge.name;
        self.badgeIntro.text = badge.tagline;
        self.badgeImage.sd_setImage(with: URL.init(string: badge.icon!.url!), placeholderImage: UIImage(named: "ph-badge"));
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
