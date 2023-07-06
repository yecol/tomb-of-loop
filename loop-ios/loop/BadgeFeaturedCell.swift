//
//  BadgeFeaturedCell.swift
//  loop
//
//  Created by Yecol Hsu on 01/01/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import Foundation
import SnapKit

let kBadgeFeaturedCell = "kBadgeFeaturedCell"
fileprivate let kFeaturedBadgeSize: CGFloat = 60;
fileprivate let kFeaturedCellHeight: CGFloat = 170;

class BadgeFeaturedCell: UICollectionViewCell {

    private lazy var bgView: UIView = { [unowned self] in
        let bg = UIView();
        bg.backgroundColor = UIColor.white;
        return bg;
    }()

    private lazy var nameLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_BLACK_GRACE;
        label.font = fontHelveticaNeueThin24;
        return label;
    }()

    private lazy var subtitleLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_BLACK_GRACE;
        label.font = fontSystem12;
        return label;
    }()

    private lazy var detailLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = UIColor.darkGray;
        label.font = fontSystem14;
        label.numberOfLines = 0;
        label.lineBreakMode = .byTruncatingTail;
        return label;
    }()

    private lazy var badgeImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit
        return imageView;
    }()

    override init(frame: CGRect) {
        super.init(frame: frame);

        self.contentView.addSubview(self.bgView);
        self.contentView.addSubview(self.badgeImageView);
        self.contentView.addSubview(self.nameLabel);
        self.contentView.addSubview(self.subtitleLabel);
        self.contentView.addSubview(self.detailLabel);

        self.addLayoutConstraints();

        self.bgView.layer.cornerRadius = 8
        self.bgView.layer.masksToBounds = false
        self.bgView.layer.shadowColor = UIColor.black.cgColor
        self.bgView.layer.shadowOpacity = 0.2
        self.bgView.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        self.bgView.layer.shadowRadius = 6
    }

    func bindData(_ badgeName: String, badgeImageURL: String, badgeSubtitle: String, badgeDetail: String) {
        self.nameLabel.text = badgeName;
        self.badgeImageView.sd_setImage(with: URL(string: badgeImageURL),
                placeholderImage: UIImage(named: "badge-ph"));
        self.subtitleLabel.text = badgeSubtitle;
        self.detailLabel.text = badgeDetail;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLayoutConstraints() {

        self.bgView.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview();
            make.width.equalTo(kScreenW * 0.8 - 2 * FL_PADDING);
            make.height.equalTo(kFeaturedCellHeight);
        }

        self.badgeImageView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.bgView.snp.left).offset(20);
            make.top.equalTo(self.bgView.snp.top).offset(20);
            make.width.equalTo(kFeaturedBadgeSize);
            make.height.equalTo(kFeaturedBadgeSize);
        }

        self.nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.badgeImageView);
            make.left.equalTo(self.badgeImageView.snp.right).offset(FL_PADDING);
            make.height.equalTo(28)
        }

        self.subtitleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(FL_PADDING);
            make.left.equalTo(self.nameLabel);
        }

        self.detailLabel.snp.makeConstraints { (make) -> Void in
            make.top.greaterThanOrEqualTo(self.subtitleLabel.snp.bottom).offset(FL_PADDING);
            make.top.greaterThanOrEqualTo(self.badgeImageView.snp.bottom).offset(FL_PADDING);
            make.centerX.equalToSuperview();
            make.width.equalTo(kScreenW * 0.8 - kFeaturedBadgeSize);
            make.height.lessThanOrEqualTo(65)
        }
    }
}
