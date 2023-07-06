//
//  PostBriefCell.swift
//  loop
//
//  Created by Yecol Hsu on 12/02/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import SnapKit
import DateTools
import SDWebImage
import TTTAttributedLabel

fileprivate let kPostBriefAvatarSize: CGFloat = 36;
fileprivate let kPostBriefBadgeSize: CGFloat = 30;
fileprivate let kPostBriefPhotoSize: CGFloat = 80;
fileprivate let kPostFavIconSize: CGFloat = 16;

fileprivate let kPadding: CGFloat = 12;

class PostBriefCell: UITableViewCell {

    private lazy var avatarImageView: UIImageView = { [unowned self] in
        let frame = CGRect(x: 0, y: 0, width: kPostBriefAvatarSize, height: kPostBriefAvatarSize)
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.asAvatar()
        return imageView
    }()

    private lazy var badgeImageView: UIImageView = { [unowned self] in
        let frame = CGRect(x: 0, y: 0, width: kPostBriefBadgeSize, height: kPostBriefBadgeSize)
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var photoImageView: UIImageView = { [unowned self] in
        let frame = CGRect(x: 0, y: 0, width: kPostBriefPhotoSize, height: kPostBriefPhotoSize)
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true;
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

//    private lazy var userNameLabel: UILabel = { [unowned self] in
//        let label = UILabel()
//        label.font = fontSystem14
//        return label
//    }()
//
//    private lazy var postTimeLabel: UILabel = { [unowned self] in
//        let label = UILabel()
//        label.font = fontSystem12
//        label.textColor = CL_GREY_FONT
//        return label
//    }()

    private lazy var titleLabel: TTTAttributedLabel = { [unowned self] in
        let attrLabel = TTTAttributedLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40));
        attrLabel.textColor = UIColor.darkGray;
        attrLabel.font = fontSystem14;
        attrLabel.linkAttributes = [NSUnderlineStyleAttributeName: false, kCTForegroundColorAttributeName as
        AnyHashable: CL_LINK_COLOR, NSFontAttributeName: fontSystem14Bold];

        attrLabel.lineBreakMode = .byWordWrapping;
        attrLabel.numberOfLines = 0;
//        attrLabel.delegate = self;
        return attrLabel;
    }()

    private lazy var timestampLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: self.avatarImageView.frame.maxX + kAvatarSpacing,
                y: self.titleLabel.frame.maxY, width: 200, height: 12));
        label.lineBreakMode = .byWordWrapping;
        label.font = fontSystem12
        label.textColor = CL_GREY_FONT;

        return label;
    }()

    private lazy var postContentLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = fontSystem14
        label.textColor = CL_BLACK_GRACE;
        label.numberOfLines = 0
        label.clipsToBounds = true;
        return label
    }()

    private lazy var favIcon: UIImageView = {
        let frame = CGRect(x: 0, y: 0, width: kPostFavIconSize, height: kPostFavIconSize)
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "postbrief-fav")
        return imageView
    }()

    private lazy var commentIcon: UIImageView = {
        let frame = CGRect(x: 0, y: 0, width: kPostFavIconSize, height: kPostFavIconSize)
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "postbrief-comment")
        return imageView
    }()

    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = fontSystem12
        label.textColor = CL_GREY_FONT;
        return label
    }()

    private lazy var favLabel: UILabel = {
        let label = UILabel()
        label.font = fontSystem12
        label.textColor = CL_GREY_FONT;
        return label
    }()

    private lazy var sharedLabel: UILabel = {
        let label = UILabel()
        label.font = fontSystem12
        label.textColor = CL_GREY_FONT;
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.avatarImageView);
        self.contentView.addSubview(self.badgeImageView);
        self.contentView.addSubview(self.titleLabel);
        self.contentView.addSubview(self.timestampLabel);
        self.contentView.addSubview(self.postContentLabel);
        self.contentView.addSubview(self.photoImageView);
        self.contentView.addSubview(self.commentIcon);
        self.contentView.addSubview(self.commentLabel);
        self.contentView.addSubview(self.favIcon);
        self.contentView.addSubview(self.favLabel);
        self.contentView.addSubview(self.sharedLabel);

        self.addLayoutConstrains()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(post: LPPost) {

        let userAvatarURL = URL.init(string: post.creator.avatar?.url ?? "");
        self.avatarImageView.sd_setImage(with: userAvatarURL, placeholderImage: UIImage(named: "avatar-ph"));

        if (post.badge != nil) {
            let badgeURL = URL.init(string: post.badge!.smallIcon!.url!);
            self.badgeImageView.sd_setImage(with: badgeURL);
        }

        if (post.imageList != nil) {
            if (post.imageList!.count > 0) {
                let photo = post.imageList!.object(at: 0) as! AVFile
                let photoURL = URL.init(string: photo.url!)
                self.photoImageView.sd_setImage(with: photoURL)
            }
        }

        self.titleLabel.setUserWithFriends(poster: post.creator, friends: post.taggedFriendList);
        var detailText = post.createdAt?.timeAgoSinceNow
        if (post.place != nil) {
            detailText = detailText!.appending(" · ");
            detailText = detailText!.appending(post.place!.name!);
        }
        self.timestampLabel.text = detailText;
        self.postContentLabel.text = post.message;
        self.favLabel.text = String(describing: post.likeCount ?? 0);
        self.commentLabel.text = String(describing: post.commentCount ?? 0);
        if post.sharedBy != nil {
            self.sharedLabel.text = "kFeedYouSharedThisPost".localized;
        } else {
            self.sharedLabel.text = "";
        }
    }

    private func addLayoutConstrains() {

        self.avatarImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(kPadding)
            make.left.equalTo(self.contentView).offset(kPadding)
            make.width.equalTo(kPostBriefAvatarSize)
            make.height.equalTo(kPostBriefAvatarSize)
        }

        self.badgeImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(kPadding)
            make.right.equalTo(self.contentView).offset(-kPadding)
            make.width.equalTo(kPostBriefBadgeSize)
            make.height.equalTo(kPostBriefBadgeSize)
        }

        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.avatarImageView);
            make.right.lessThanOrEqualTo(self.badgeImageView.snp.left).offset(-kPadding)
            make.left.equalTo(self.avatarImageView.snp.right).offset(kPadding)
        }

        self.timestampLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5);
            make.right.lessThanOrEqualTo(self.badgeImageView.snp.left).offset(-kPadding)
            make.left.equalTo(self.avatarImageView.snp.right).offset(kPadding)
        }

        self.photoImageView.snp.makeConstraints { (make) -> Void in
            make.top.greaterThanOrEqualTo(self.avatarImageView.snp.bottom).offset(5);
            make.top.greaterThanOrEqualTo(self.timestampLabel.snp.bottom).offset(5);
            make.right.equalTo(self.contentView).offset(-kPadding);
            make.height.equalTo(kPostBriefPhotoSize);
            make.width.equalTo(kPostBriefPhotoSize);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-kPadding)
        }

        self.commentIcon.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.photoImageView);
            make.left.equalTo(self.avatarImageView);
            make.height.equalTo(kPostFavIconSize);
            make.width.equalTo(kPostFavIconSize);
        }

        self.postContentLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.photoImageView);
            make.left.equalTo(self.avatarImageView.snp.left);
            make.right.equalTo(self.photoImageView.snp.left).offset(-kPadding);
            make.bottom.lessThanOrEqualTo(self.commentIcon.snp.top).offset(-5);
        }

        self.commentLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.commentIcon.snp.right).offset(5);
            make.width.equalTo(20)
            make.centerY.equalTo(self.commentIcon)
        }

        self.favIcon.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.commentLabel.snp.right).offset(5);
            make.height.equalTo(kPostFavIconSize);
            make.width.equalTo(kPostFavIconSize);
            make.bottom.equalTo(self.commentIcon)
        }

        self.favLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.favIcon.snp.right).offset(5);
            make.width.equalTo(20)
            make.centerY.equalTo(self.commentIcon)
        }

        self.sharedLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.favLabel.snp.right).offset(5);
            make.right.lessThanOrEqualTo(self.postContentLabel);
            make.centerY.equalTo(self.commentIcon)
        }

    }

}
