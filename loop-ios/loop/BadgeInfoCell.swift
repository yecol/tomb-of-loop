//
//  BadgeInfoCell.swift
//  loop
//
//  Created by Yecol Hsu on 02/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

enum BadgeProfileType {
    case badgeProfileSelf
    case badgeProfileOther
}

let kBadgeInfoboxHeight: CGFloat = 130;

class BadgeInfoCell: UITableViewCell, UICollectionViewDelegate {

    var viewType: BadgeProfileType = .badgeProfileSelf;

    private lazy var levelBox: BadgeInfoBoxView = { [unowned self] in
        let box = BadgeInfoBoxView();
        box.iconImageView.image = UIImage(named: "badge-grade");
        box.titleLabel.text = "kBadgeInfoBoxGrade".localized;
        box.detailTextLabel.text = "kBadgeInfoBoxGradeDetail".localized;
        return box;
    }()

    private lazy var rarityBox: BadgeInfoBoxView = { [unowned self] in
        let box = BadgeInfoBoxView();
        box.iconImageView.image = UIImage(named: "badge-rarity");
        box.titleLabel.text = "kBadgeInfoBoxRarity".localized;
        box.detailTextLabel.text = "kBadgeInfoBoxRarityDetail".localized;
        return box;
    }()

    private lazy var expBox: BadgeInfoBoxView = { [unowned self] in
        let box = BadgeInfoBoxView();
        box.iconImageView.image = UIImage(named: "badge-exp");
        box.titleLabel.text = "kBadgeInfoBoxExperience".localized;
        box.detailTextLabel.text = "kBadgeInfoBoxExperienceDetail".localized;
        return box;
    }()

    private lazy var dateBox: BadgeInfoBoxView = { [unowned self] in
        let box = BadgeInfoBoxView();
        box.iconImageView.image = UIImage(named: "badge-date");
        box.titleLabel.text = "kBadgeInfoBoxObtainedDate".localized;
        return box;
    }()

    private lazy var horizontalSeparator: UIView = {
        let line = UIView()
        line.backgroundColor = CL_GREY_BG_EC
        return line
    }()

    private lazy var verticalSeparator: UIView = {
        let line = UIView()
        line.backgroundColor = CL_GREY_BG_EC
        return line
    }()

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.selectionStyle = .none;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupBox(_ type: BadgeProfileType) {

        self.viewType = type;
        self.contentView.addSubview(self.levelBox);
        self.contentView.addSubview(self.rarityBox);

        if (self.viewType == BadgeProfileType.badgeProfileSelf) {
            self.contentView.addSubview(self.expBox);
            self.contentView.addSubview(self.dateBox);
            self.contentView.addSubview(self.horizontalSeparator)
        }

        self.contentView.addSubview(self.verticalSeparator)

        self.addLayoutConstraints();
    }

    func addLayoutConstraints() {

        self.levelBox.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview();
            make.left.equalToSuperview();
            make.width.equalTo(kScreenW / 2);
            make.height.equalTo(kBadgeInfoboxHeight);
        }
        self.rarityBox.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview();
            make.right.equalToSuperview();
            make.width.equalTo(kScreenW / 2);
            make.height.equalTo(kBadgeInfoboxHeight);
        }

        if (self.viewType == BadgeProfileType.badgeProfileSelf) {
            self.expBox.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.levelBox.snp.bottom);
                make.left.equalToSuperview();
                make.width.equalTo(kScreenW / 2);
                make.height.equalTo(kBadgeInfoboxHeight);
            }
            self.dateBox.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.levelBox.snp.bottom);
                make.right.equalToSuperview();
                make.width.equalTo(kScreenW / 2);
                make.height.equalTo(kBadgeInfoboxHeight);
            }
            self.horizontalSeparator.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.levelBox.snp.bottom);
                make.left.equalToSuperview();
                make.width.equalTo(kScreenW);
                make.height.equalTo(1);
            }
        }

        self.verticalSeparator.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview();
            make.left.equalTo(self.levelBox.snp.right);
            make.width.equalTo(1);
            make.height.equalToSuperview();
        }
    }

    func bindData(_ badge: LPBadge) {
        self.levelBox.valueLabel.text = String(format: "%d", badge.level);
        self.rarityBox.valueLabel.text = String(format: "%0.1f", badge.rarity)+"%";
        if (self.viewType == BadgeProfileType.badgeProfileSelf) {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: badge.grantDate!)
            let month = calendar.component(.month, from: badge.grantDate!)
            let day = calendar.component(.day, from: badge.grantDate!)
            self.expBox.valueLabel.text = String(format: "%0.1f", badge.levelUpPercent)+"%";
            self.dateBox.valueLabel.text = String(format: "%d/%d", month, day);
            self.dateBox.detailTextLabel.text = String(format: "%d", year);
        }
    }
}

let kBadgeInfoBoxSpacing: CGFloat = 10;

class BadgeInfoBoxView: UIView {

    var iconImageView = UIImageView();
    var titleLabel = UILabel();
    var valueLabel = UILabel();
    var detailTextLabel = UILabel();

    init() {
        super.init(frame: CGRect.null);
        self.addSubview(self.iconImageView)

        self.titleLabel.textColor = CL_GREY_FONT;
        self.titleLabel.font = fontMontserrat12
        self.addSubview(self.titleLabel);

        self.valueLabel.textAlignment = .right
        self.valueLabel.font = fontHelveticaNeueThin48
        self.valueLabel.textColor = CL_GREEN_DEFAULT
        self.addSubview(self.valueLabel);

        self.detailTextLabel.textAlignment = .right;
        self.detailTextLabel.textColor = CL_GREY_FONT
        self.detailTextLabel.font = fontHelveticaNeueThin18;
        self.addSubview(self.detailTextLabel);

        self.addLayoutConstraints();
    }

    func addLayoutConstraints() {

        self.iconImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(kBadgeInfoBoxSpacing)
            make.left.equalToSuperview().offset(kBadgeInfoBoxSpacing);
            make.width.equalTo(18);
            make.height.equalTo(18);
        }

        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.iconImageView);
            make.left.equalTo(self.iconImageView.snp.right).offset(kBadgeInfoBoxSpacing);
        }

        self.detailTextLabel.snp.makeConstraints { (make) -> Void in
            make.bottom.equalToSuperview().offset(-kBadgeInfoBoxSpacing);
            make.right.equalToSuperview().offset(-kBadgeInfoBoxSpacing);
        }

        self.valueLabel.snp.makeConstraints { (make) -> Void in
            make.lastBaseline.equalTo(self.detailTextLabel.snp.top).offset(-kBadgeInfoBoxSpacing);
            make.right.equalTo(self.detailTextLabel);
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
