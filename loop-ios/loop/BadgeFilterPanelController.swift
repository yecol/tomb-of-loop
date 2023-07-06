//
//  BadgeFilterController.swift
//  loop
//
// Created by XueCheng on 3/5/17.
// Copyright (c) 2017 Jingbo. All rights reserved.
//

import Foundation
import SnapKit
import SDWebImage

class BadgeFilterPanelController: UIViewController {

    private var badgeArray: Array<LPBadge>

    private lazy var filterOnLabel: UILabel = {
        let label = UILabel()
        label.text = "kFeedBadgeFilterOn".localized
        label.font = fontSystem12Bold
        label.textColor = CL_GREEN_ASSISTANCE
        return label
    }()

    private lazy var clickToEditLabel: UILabel = {
        let label = UILabel()
        label.text = "kFeedBadgeFilterOnDetailed".localized
        label.font = fontSystem12
        label.textColor = CL_GREY_SHADOW
        return label
    }()

    private lazy var iconViewArray: Array<UIImageView> = {
        var array: Array<UIImageView> = Array<UIImageView>()

        for (i, badge) in self.badgeArray.enumerated() {
            guard let iconUrl = badge.smallIcon?.url else {
                continue
            }

            var imageView = UIImageView()
            imageView.sd_setImage(with: URL(string: iconUrl))

            array.append(imageView)
        }

        return array
    }()

    // MARK: Override Functions

    init(badgeArray: Array<LPBadge>) {
        self.badgeArray = Array(badgeArray.prefix(5))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = CL_GREEN_LIGHT;

        self.view.addSubview(self.filterOnLabel)
        self.view.addSubview(self.clickToEditLabel)
        for imageView in self.iconViewArray {
            self.view.addSubview(imageView)
        }

        self.addLayoutConstraints()
    }

    // MARK: Private Functions

    private func addLayoutConstraints() {
        self.filterOnLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(15)
            make.left.equalTo(self.view).offset(20)
        }

        self.clickToEditLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.filterOnLabel.snp.bottom).offset(4)
            make.left.equalTo(self.filterOnLabel)
        }

        var prevImageView: UIImageView?
        for curImageView in self.iconViewArray.reversed() {
            if curImageView == self.iconViewArray.last! {
                curImageView.snp.makeConstraints { (make) -> Void in
                    make.width.equalTo(30)
                    make.height.equalTo(30)
                    make.right.equalTo(self.view).offset(-20)
                    make.centerY.equalTo(self.view)
                }

                prevImageView = curImageView
                continue;
            }

            curImageView.snp.makeConstraints { (make) -> Void in
                make.width.equalTo(30)
                make.height.equalTo(30)
                make.right.equalTo(prevImageView!.snp.left).offset(-10)
                make.centerY.equalTo(self.view)
            }

            prevImageView = curImageView
        }
    }

}
