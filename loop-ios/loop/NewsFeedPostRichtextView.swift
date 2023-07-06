//
//  NewsFeedPostRichtextView.swift
//  loop
//
//  Created by Yecol Hsu on 14/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.

import UIKit
import SnapKit
import TTTAttributedLabel
import DateTools
import pop

//import FaveButton

let kDefaultAvatarSize: CGFloat = 48.0;
let kDefaultBadgeSize: CGFloat = 48.0;

let kAvatarSpacing: CGFloat = 10.0;
let kBGFrameSpacing: CGFloat = 4.0;

fileprivate let kShareOffset: CGFloat = 36.0;

let kTitleWidth: CGFloat = kScreenW - kDefaultAvatarSize - kDefaultBadgeSize - kAvatarSpacing * 4 - kBGFrameSpacing * 2;
let kContentWidth: CGFloat = kScreenW - 2 * kAvatarSpacing - 2 * kBGFrameSpacing;
let kBGFrameWidth: CGFloat = kScreenW - 2 * kBGFrameSpacing;
let kVerticalSpacing: CGFloat = 5.0;

//let kPostTailWithoutComment: CGFloat = 44;
let kCommentBtnSize: CGFloat = 44;


enum StreamType {
    case recommandStream
    case friendStream
}

enum PostStyle {
    case cardNoComment;
    case cardWithComment
    case noPadding;
}

protocol NewsFeedPostRichtextViewDelegate: class {

    func didSelectCommentBtn();

    func didSelectLikeBtn();

    func didSelectBadge();

    func didSelectShare();

    func didSelectMore();

    func didSelectProfile(_ userID: String);
}

class NewsFeedPostRichtextView: UIView, TTTAttributedLabelDelegate, FaveButtonDelegate {

    weak var delegate: NewsFeedPostRichtextViewDelegate?

    var isShared = false;
    var hasCommentsPreview = false;
    var isLiked = false;
    var postStyle: PostStyle = .cardNoComment;

    //TODO: remove this temp
    var likeCommentsViewHeight: CGFloat = 0.0;

    private lazy var bgFrame: UIView = {
        let view = UIView();
        view.backgroundColor = UIColor.white;
        view.layer.borderColor = CL_GREY_BORDER_6C.cgColor;
        view.layer.borderWidth = 0.5;
        return view;
    }()

    private lazy var sharedLabel: UILabel = {
        let label = UILabel();
        label.font = fontSystem14;
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()

    private lazy var sharedLine: UIView = {

        let line = UIView.init(frame: CGRect.init(x: kBGFrameSpacing + kAvatarSpacing, y: kShareOffset -
                1, width: kContentWidth, height: 1));
        line.backgroundColor = CL_GREY_BORDER_6C;
        return line
    }()

//    var photoBgFrame = UIView();s

    private lazy var badgeBtn: UIButton = { [unowned self] in
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: kDefaultBadgeSize, height: kDefaultBadgeSize))
        button.addTarget(self, action: #selector(self.badgeBtnPressed), for:
        .touchUpInside);
        return button;
    }()

    private lazy var shareBtn: UIButton = {

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: kCommentBtnSize, height:
        kCommentBtnSize));
        button.setImage(UIImage(named: "index-forward"), for: UIControlState());
        button.addTarget(self, action: #selector(self.shareBtnPressed),
                for: UIControlEvents.touchUpInside);
        return button

    }()

    private lazy var moreBtn: UIButton = {

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: kCommentBtnSize, height:
        kCommentBtnSize));
        button.setImage(UIImage(named: "index-more"), for: UIControlState());
        button.addTarget(self, action: #selector(self.moreBtnPressed),
                for: UIControlEvents.touchUpInside);
        return button
    }()

    private lazy var commentBtn: UIButton = { [unowned self] in

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: kCommentBtnSize, height:
        kCommentBtnSize));
        button.setImage(UIImage(named: "index-comments"), for: UIControlState());
        button.addTarget(self, action: #selector(self.commentBtnPressed),
                for: UIControlEvents.touchUpInside);
        return button;
    }()

    private lazy var commentLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 12));
        label.font = fontSystem12Bold
        label.textColor = CL_GREY_FONT;
        return label;
    }()

    private lazy var likeLabel: UILabel = {

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 12));
        label.font = fontSystem12Bold
        label.textColor = CL_GREY_FONT;
        return label;
    }()

//    private lazy var avatarImageView: UIImageView = {
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kDefaultAvatarSize, height:
//        kDefaultAvatarSize));
//        imageView.asAvatar(size: kDefaultAvatarSize);
//        return imageView;
//    }()


    private lazy var avatarButton: UIButton = {
        let imageButton = UIButton();
        imageButton.frame = CGRect(x: 0, y: 0, width: kDefaultAvatarSize, height: kDefaultAvatarSize)
        imageButton.addTarget(self, action: #selector(self.avatarBtnPressed),
                for: UIControlEvents.touchUpInside);
        imageButton.asAvatar(size: kDefaultAvatarSize);
        return imageButton;
    }()


    private lazy var titleLabel: TTTAttributedLabel = {
        let attrLabel = TTTAttributedLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40));
        attrLabel.textColor = UIColor.darkGray;
        attrLabel.font = fontSystem14;
        attrLabel.linkAttributes = [NSUnderlineStyleAttributeName: false, kCTForegroundColorAttributeName as
        AnyHashable: CL_LINK_COLOR, NSFontAttributeName: fontSystem14Bold];

        attrLabel.lineBreakMode = .byWordWrapping;
        attrLabel.numberOfLines = 0;
        attrLabel.delegate = self;
        return attrLabel;
    }()

    private lazy var timestampLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: self.avatarButton.frame.maxX + kAvatarSpacing,
                y: self.titleLabel.frame.maxY, width: 200, height: 12));
        label.lineBreakMode = .byWordWrapping;
        label.numberOfLines = 0;
        label.font = fontSystem12
        label.textColor = CL_GREY_FONT;
        return label;
    }()

    private lazy var contentLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: kAvatarSpacing, y: self.timestampLabel.frame.maxY, width: 200, height:
        50));
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0;
        label.font = fontSystem14
        return label;
    }()


    private lazy var faveButton: FaveButton = { [unowned self] in
        let button = FaveButton(
                frame: CGRect(x: 100, y: 100, width: 36, height: 32),
                faveIconNormal: UIImage(named: "index-like")
        )
        button.selectedColor = CL_LIKE_SELECT;
        button.normalColor = CL_GREY_BG_EC;
        button.delegate = self
        return button
    }()

    private lazy var contentPhotoImageView: CollageView = {
        let contentPhotoImageView = CollageView();
        return contentPhotoImageView;
    }()


    var likeCommentView: LikeCommentView = {
        let likeCommentView = LikeCommentView(frame: CGRect.zero);
        likeCommentView.isScrollEnabled = false;
        likeCommentView.backgroundColor = UIColor.clear;
        return likeCommentView;
    }()


    func bindData(with post: LPPost, style styleType: PostStyle) {

        self.postStyle = styleType;

        self.titleLabel.setUserWithFriends(poster: post.creator, friends: post.taggedFriendList);

        self.contentLabel.text = post.message ?? ""

        var detailText = post.createdAt?.timeAgoSinceNow
        if (post.place != nil) {
            detailText = detailText!.appending(" · ");
            detailText = detailText!.appending(post.place!.name!);
        }

        self.timestampLabel.text = detailText;

        self.avatarButton.sd_setImage(with: URL(string: post.creator.avatar?.url ?? ""), for: .normal);
        self.contentPhotoImageView.setPhotosAVFile(post.imageList);

        self.commentLabel.text = String(describing: post.commentCount ?? 0)
//        self.faveButton.isSelected = post.hasLiked;
        self.faveButton.setSelected(selected: post.hasLiked, animation: false)
        self.isLiked = post.hasLiked;
        self.likeLabel.text = String(describing: post.likeCount ?? 0)

        if let badge = post.badge {
            self.badgeBtn.sd_setImage(with: URL(string: badge.smallIcon!.url!), for: .normal);
        }

        if (self.postStyle == .cardWithComment) {
            self.hasCommentsPreview = true;
            self.likeCommentView.setCurrentPost(post);
            self.likeCommentsViewHeight = LikeCommentView.calculateCommentsViewHeightWithPost(post);
        }

        if let sharer = post.sharedBy {
            self.isShared = true
            self.sharedLabel.text = (sharer.displayName() as String)
             + "kFeedSharedThisPost_Piece".localized
        } else {
            self.isShared = false;
        }

        self.updateLayoutConstrains();
        self.setNeedsLayout()
    }


    private func updateLayoutConstrains() {

        let collageHeight = contentPhotoImageView.calculateHeight()
        self.contentPhotoImageView.snp.updateConstraints { (update) -> Void in
            update.height.equalTo(collageHeight);
        }

        if self.isShared {
            self.sharedLabel.snp.updateConstraints { (update) -> Void in
                update.height.equalTo(16.0)
            }

            self.sharedLine.snp.updateConstraints { (update) -> Void in
                update.height.equalTo(1)
            }

            self.avatarButton.snp.updateConstraints { (update) -> Void in
                update.top.equalTo(self.snp.top).offset(kShareOffset + kAvatarSpacing + kBGFrameSpacing)
            }
        } else {
            self.sharedLabel.snp.updateConstraints { (update) -> Void in
                update.height.equalTo(0)
            }

            self.sharedLine.snp.updateConstraints { (update) -> Void in
                update.height.equalTo(0)
            }

            self.avatarButton.snp.updateConstraints { (update) -> Void in
                update.top.equalTo(self.snp.top).offset(kAvatarSpacing + kBGFrameSpacing)
            }
        }

        if self.hasCommentsPreview {
            self.likeCommentView.snp.updateConstraints { (update) -> Void in
                update.height.equalTo(self.likeCommentsViewHeight);
            }
        }

        if self.postStyle == PostStyle.noPadding {
            self.bgFrame.snp.updateConstraints { (update) -> Void in
                update.width.equalTo(self.snp.width).offset(2 * kBGFrameSpacing)
            }
        }
    }

    private func addLayoutConstrains() {

//        self.backgroundColor = UIColor.green;

        self.snp.makeConstraints { (make) -> Void in
            make.bottom.greaterThanOrEqualTo(self.likeCommentView.snp.bottom);
            make.bottom.greaterThanOrEqualTo(self.commentBtn.snp.bottom);
            make.width.equalTo(kScreenW);
        }

        self.bgFrame.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview().offset(-2 * kBGFrameSpacing)
            make.height.equalToSuperview().offset(-kBGFrameSpacing);
            make.center.equalToSuperview();
        }

        self.sharedLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(kBGFrameSpacing + kAvatarSpacing);
            make.width.equalTo(kContentWidth)
            make.height.equalTo(0)
        }

        self.sharedLine.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.sharedLabel.snp.left);
            make.top.equalTo(kShareOffset - 1)
            make.width.equalTo(kContentWidth)
            make.height.equalTo(0)
        }

        self.avatarButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(kDefaultAvatarSize);
            make.width.equalTo(kDefaultAvatarSize);
            make.top.equalToSuperview().offset(kAvatarSpacing + kBGFrameSpacing)
            make.left.equalToSuperview().offset(kBGFrameSpacing + kAvatarSpacing)
        }

        self.badgeBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(kDefaultBadgeSize);
            make.width.equalTo(kDefaultBadgeSize);
            make.top.equalTo(self.avatarButton.snp.top);
            make.right.equalToSuperview().offset(-kBGFrameSpacing - kAvatarSpacing);
        }

        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kTitleWidth);
            make.left.equalTo(self.avatarButton.snp.right).offset(kAvatarSpacing);
            make.top.equalTo(self.avatarButton.snp.top).offset(5)
        }

        self.titleLabel.sizeToFit();

        self.timestampLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kTitleWidth)
            make.left.equalTo(self.titleLabel.snp.left);
            make.top.equalTo(self.titleLabel.snp.bottom).offset(kVerticalSpacing);
        }

        self.timestampLabel.sizeToFit();

        self.contentLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kContentWidth);
            make.left.equalTo(self.avatarButton.snp.left);
            make.top.greaterThanOrEqualTo(self.avatarButton.snp.bottom).offset(kVerticalSpacing);
            make.top.greaterThanOrEqualTo(self.timestampLabel.snp.bottom).offset(kVerticalSpacing);
        }

        self.contentLabel.sizeToFit();

        let collageHeight = contentPhotoImageView.calculateHeight()
        self.contentPhotoImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview();
            make.height.equalTo(collageHeight);
            make.top.equalTo(self.contentLabel.snp.bottom).offset(kVerticalSpacing);
            make.left.equalToSuperview();
        }

        self.commentBtn.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kCommentBtnSize);
            make.height.equalTo(kCommentBtnSize);
            make.left.equalToSuperview().offset(kBGFrameSpacing);
            make.top.equalTo(self.contentPhotoImageView.snp.bottom);
        }

        self.commentLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(self.commentBtn.snp.height);
            make.width.equalTo(15);
            make.left.equalTo(self.commentBtn.snp.right);
            make.centerY.equalTo(self.commentBtn.snp.centerY);
        }

        self.shareBtn.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(self.commentBtn);
            make.left.equalTo(self.commentLabel.snp.right)
            make.centerY.equalTo(self.commentBtn.snp.centerY);
        }

        self.moreBtn.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(self.commentBtn);
            make.right.equalToSuperview();
            make.centerY.equalTo(self.commentBtn.snp.centerY);
        }

        self.likeLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(self.commentBtn.snp.height);
            make.width.equalTo(15);
            make.right.equalTo(self.moreBtn.snp.left);
            make.centerY.equalTo(self.commentBtn.snp.centerY);
        }

        self.faveButton.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(self.commentBtn);
            make.right.equalTo(self.likeLabel.snp.left);
            make.centerY.equalTo(self.commentBtn.snp.centerY);
        }

        self.likeCommentView.snp.makeConstraints { (make) -> Void in
//            make.width.equalTo(kContentWidth);
//            make.bottom.equalToSuperview();
            make.height.equalTo(self.likeCommentsViewHeight);
            make.top.equalTo(self.commentBtn.snp.bottom);
            make.left.equalTo(self.contentLabel);
            make.width.equalTo(kContentWidth)
        }

        self.contentLabel.setContentHuggingPriority(252, for: .horizontal)
        self.contentLabel.setContentCompressionResistancePriority(1000, for: .horizontal)
    }

    override required init(frame: CGRect) {
        super.init(frame: frame);

        self.addSubview(self.bgFrame)
        self.addSubview(self.avatarButton);
        self.addSubview(self.badgeBtn)

        self.addSubview(self.titleLabel);
        self.addSubview(self.timestampLabel);

        self.addSubview(self.contentLabel);
        self.addSubview(self.contentPhotoImageView);

        self.addSubview(self.commentBtn)
        self.addSubview(self.commentLabel)
        self.addSubview(self.likeLabel)
        self.addSubview(self.faveButton)
        self.addSubview(self.shareBtn)
        self.addSubview(self.moreBtn)

        self.addSubview(self.sharedLabel)
        self.addSubview(self.sharedLine);
        self.addSubview(self.likeCommentView)

        self.addLayoutConstrains()
    }

    required init? (coder: NSCoder) {
        super.init(coder: coder);
    }

    func commentBtnPressed() {
        self.delegate?.didSelectCommentBtn()
    }

    func faveButton(_ faveButton: FaveButton, didSelectedAndBeforeAnimation selected: Bool) {
        // change display for this round
        self.isLiked = !self.isLiked
        if (isLiked == true) {
            let beforeValue = Int(self.likeLabel.text!)
            let val = beforeValue! + 1;
            self.likeLabel.text = NSString.init(format: "%d", val) as String
        } else {
            let beforeValue = Int(self.likeLabel.text!)
            let val = beforeValue! - 1;
            self.likeLabel.text = NSString.init(format: "%d", val) as String
        }
    }


    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        self.delegate?.didSelectLikeBtn()
    }

    func badgeBtnPressed() {
        self.delegate?.didSelectBadge();
    }

    func shareBtnPressed() {
        self.delegate?.didSelectShare();
    }

    func moreBtnPressed() {
        self.delegate?.didSelectMore();
    }

    func avatarBtnPressed() {
        self.delegate?.didSelectProfile("");
    }

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        self.delegate?.didSelectProfile(url.absoluteString)
    }
}
