//
//  FriendCell.swift
//  loop
//
//  Created by Yecol Hsu on 06/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

let kFriendCellIdentifier = "kFriendCellIdentifier";

let kFriendListCellHeight: CGFloat = 64;

fileprivate let kFriendCellAvatarSize: CGFloat = 40.0;
fileprivate let kFrinedCellPadding: CGFloat = 12.0;

class FriendCell: UITableViewCell {


    private lazy var avatarImageView: UIImageView = {
        let frame = CGRect(x: 0, y: 0, width: kFriendCellAvatarSize, height: kFriendCellAvatarSize)
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.asAvatar(size: kFriendCellAvatarSize)
        return imageView
    }()

    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = fontSystem14Bold;
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = fontSystem12
        label.textColor = CL_GREY_FONT
        return label
    }()


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);

        self.separatorInset = UIEdgeInsetsMake(0, 64, 0, 0);

        self.contentView.addSubview(self.avatarImageView);
        self.contentView.addSubview(self.userNameLabel);

        if (style == .subtitle) {
            self.contentView.addSubview(self.detailLabel);
        }

        self.addLayoutConstrains(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(_ username: NSString, avatar url: String, detail content: String) {
        self.userNameLabel.text = username as String;
        self.avatarImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "avatar-ph"));
        self.detailLabel.text = content
    }

    private func addLayoutConstrains(style: UITableViewCellStyle) {

        self.contentView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview();
            make.height.equalTo(kFriendCellAvatarSize + kFrinedCellPadding * 2)
            make.left.equalToSuperview();
        }

        self.avatarImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(kFrinedCellPadding)
            make.left.equalToSuperview().offset(kFrinedCellPadding)
            make.width.equalTo(kFriendCellAvatarSize)
            make.height.equalTo(kFriendCellAvatarSize)
        }

        self.userNameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp.top);
            make.left.equalTo(self.avatarImageView.snp.right).offset(kFrinedCellPadding)
        }

        if (style == .subtitle) {
            self.detailLabel.snp.makeConstraints { (make) -> Void in
                make.bottom.equalTo(self.avatarImageView.snp.bottom);
                make.left.equalTo(self.userNameLabel.snp.left);
            }
        }

    }

}
