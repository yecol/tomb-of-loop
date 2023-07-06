//
//  PostCardCell.swift
//  loop
//
//  Created by Yecol Hsu on 10/02/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

fileprivate let kPadding: CGFloat = 5.0;
fileprivate let kInnerPadding: CGFloat = 10.0;
fileprivate let kPhotoHeight: CGFloat = 200.0;
fileprivate let kContentTextHeight: CGFloat = 70.0;
fileprivate let kAvatarSize: CGFloat = 20.0;

class PostCardCell: UICollectionViewCell {

//    var post:LPPost?

    private lazy var bgView: UIView = {
        let view = UIView(frame: CGRect.null);
        view.backgroundColor = UIColor.white
        view.layer.borderColor = CL_GREY_BORDER_6C.cgColor;
        view.layer.borderWidth = 1.0;
        return view;
    }()

    private lazy var photoView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.null)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = CL_GREY_BG_EC;
        imageView.layer.borderColor = CL_GREY_BORDER_6C.cgColor;
        imageView.layer.borderWidth = 1.0;
        imageView.clipsToBounds = true;
        return imageView
    }()

    private lazy var contentTextView: TopAlignedLabel = {
        let label = TopAlignedLabel();
        label.textColor = CL_BLACK_GRACE;
        label.lineBreakMode = .byTruncatingTail;
        label.numberOfLines = 0;
        label.font = fontSystem14;
        label.clipsToBounds = true;
        return label;
    }()

    private lazy var creatorAvatar: UIImageView = {
        let imageView = UIImageView(frame: CGRect.null)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = CL_GREY_BG_EC;
        imageView.asAvatar(size: kAvatarSize);
        return imageView
    }()

    private lazy var creatorName: UILabel = {
        let label = UILabel();
        label.textColor = CL_GREY_FONT;
        label.font = fontSystem12;
        return label;
    }()


    override init(frame: CGRect) {
        super.init(frame: frame);
        self.contentView.addSubview(self.bgView)
        self.contentView.addSubview(self.photoView);
        self.contentView.addSubview(self.contentTextView);
        self.contentView.addSubview(self.creatorAvatar);
        self.contentView.addSubview(self.creatorName);

        self.addLayoutConstraints();
    }

    func setData(_ post: LPPost) {

        let photo = post.imageList!.object(at: 0) as! AVFile
        let photoURL = URL.init(string: photo.url ?? "")
        self.photoView.sd_setImage(with: photoURL);
        self.contentTextView.text = post.message;
        let avatarURL = URL.init(string: post.creator!.avatar?.url ?? "");
        self.creatorAvatar.sd_setImage(with: avatarURL, placeholderImage: UIImage(named: "avatar-ph"));
        self.creatorName.text = post.creator.displayName() as String;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLayoutConstraints() {
        self.bgView.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview().offset(-2 * kPadding);
            make.height.equalToSuperview().offset(-2 * kPadding);
            make.center.equalToSuperview();
        }

        self.photoView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.bgView);
            make.height.equalTo(kPhotoHeight);
            make.centerX.equalToSuperview();
            make.top.equalTo(self.bgView);
        }

        self.contentTextView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.bgView).offset(-2 * kInnerPadding);
            make.height.equalTo(kContentTextHeight);
            make.left.equalTo(self.bgView).offset(kInnerPadding);
            make.top.equalTo(self.photoView.snp.bottom).offset(kPadding);
        }

        self.creatorAvatar.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kAvatarSize);
            make.height.equalTo(kAvatarSize);
            make.left.equalTo(self.bgView).offset(kInnerPadding);
            make.bottom.equalTo(self.bgView).offset(-kInnerPadding);
        }

        self.creatorName.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.bgView).offset(-kAvatarSize);
            make.height.equalTo(kAvatarSize);
            make.left.equalTo(self.creatorAvatar.snp.right).offset(kInnerPadding);
            make.centerY.equalTo(self.creatorAvatar);
        }
    }
}
