//
//  ABadgeCell.swift
//  loop
//
//  Created by Yecol Hsu on 02/03/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

let kABadgeCell = "kABadgeCell"
let kABadgeCellSize: CGFloat = 120;
let kABadgePadding: CGFloat = 10.0;
let kBadgeCellInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

fileprivate let kABadgeCellImageSize: CGFloat = 70;

class ABadgeCell: UICollectionViewCell {

    private lazy var nameLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_BLACK_GRACE;
        label.font = fontSystem14Bold;
        return label;
    }()

    private lazy var detailLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_GREY_FONT;
        label.font = fontSystem12;
        return label;
    }()

    private lazy var badgeImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit
        return imageView;
    }()

    override init(frame: CGRect) {
        super.init(frame: frame);
        self.contentView.addSubview(self.badgeImageView);
        self.contentView.addSubview(self.nameLabel);
        self.contentView.addSubview(self.detailLabel);
        self.addLayoutConstrains()
    }

    func bindData(_ badgeName: String, badgeImageURL: String, badgeDetail: String) {
        self.nameLabel.text = badgeName;
        self.badgeImageView.sd_setImage(with: URL(string: badgeImageURL),
                placeholderImage: UIImage(named: "badge-ph"));
        self.detailLabel.text = badgeDetail;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLayoutConstrains() {

        self.badgeImageView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview();
//            make.bottom.lessThanOrEqualTo(self.contentView).offset(-12)
            make.width.equalTo(kABadgeCellImageSize)
            make.height.equalTo(kABadgeCellImageSize)
        }

        self.nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.badgeImageView.snp.bottom).offset(10);
            make.centerX.equalToSuperview();
        }

        self.detailLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(5);
            make.centerX.equalToSuperview();
        }

    }
}
