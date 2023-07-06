//
//  LPDefaultCell.swift
//  loop
//
//  Created by Yecol Hsu on 09/01/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

class LPDefaultCell: UITableViewCell {

    private lazy var lpImageView: UIImageView = {
        let frame = CGRect.init(x: 0, y: 0, width: 48, height: 48);
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.asAvatar(size: 48);
        return imageView
    }()

    private lazy var lpTextLabel: UILabel = {
        let label = UILabel()
        label.font = fontSystem14;
        label.numberOfLines = 0;
        label.textColor = CL_BLACK_GRACE;
        return label
    }()


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier);
        self.contentView.backgroundColor = UIColor.clear;
        self.selectionStyle = .default;
        self.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0);
        self.contentView.addSubview(lpImageView);
        self.contentView.addSubview(lpTextLabel);
        self.addLayoutConstraints();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLayoutConstraints() {

        self.lpImageView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(kProfileSelfLeftSpacing)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }

        self.lpTextLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.lpImageView.snp.right).offset(kProfileSelfLeftSpacing)
            make.width.equalToSuperview().offset(-3 * kProfileSelfLeftSpacing - 48);
        }
    }

    func bindData(_ content: String, withAvatar url: String) {
        self.lpTextLabel.text = content
        self.lpImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "avatar-ph"));
    }

}
