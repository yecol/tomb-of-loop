//
//  PostCommentController.swift
//  loop
//
//  Created by XueCheng on 1/29/17.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import Foundation
import SnapKit
import TTTAttributedLabel

class PostCommentController: UIViewController, UITableViewDelegate, UITableViewDataSource,
NewsFeedPostCellDelegate {
    
    func didMoreButtonClickAtIndexPath(_ indexPath: IndexPath) {
//        TODO:
    }


    private let cellIdentifier: String = "comment"

    private let postID: String;

    private var postInfoModel: LPPost?
    private var dataSource: Array<LPComment>?

    var activeIndexPath: IndexPath?;
    weak var parentController: NewsFeedController?;
    weak var parentProfileView: ProfilePostView?;

    private lazy var tableView: UITableView = { [unowned self] in
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.showsVerticalScrollIndicator = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = CL_GREY_BG_EC
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(CommentRowCell.self, forCellReuseIdentifier: self.cellIdentifier)
        return tableView
    }()

    private lazy var separatorLine: UIView = {
        let line = UIView()
        line.backgroundColor = CL_GREY_BG_EC
        return line
    }()

    private lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.font = fontSystem14;
        textField.placeholder = "kFeedWriteACommentHint".localized
        return textField
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton()

        button.setTitle("kSend".localized, for: .normal)
        button.setLoopBtnGreenFramed(font: fontSystem14Bold)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        button.addTarget(self, action: #selector(self.sendButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var commentTitleLabel: CommentTitleLabel = { [unowned self] in
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30)
        var label = CommentTitleLabel(frame: frame)

        label.backgroundColor = UIColor.white;
        label.text = "kSectionTitle_PostDetail_Comments".localized
        label.textColor = CL_GREY_FONT
        label.font = fontSystem12Bold
        return label
    }()

    // MARK: Initializer

//    init(postInfoModel: LPPost) {
//        self.postInfoModel = postInfoModel
//        super.init(nibName: nil, bundle: nil)
//    }

    init(postID: String) {
        self.postID = postID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.separatorLine)
        self.view.addSubview(self.commentTextField)
        self.view.addSubview(self.sendButton)

        self.addLayoutConstrains()
        self.sendRequestAndReloadData()

        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            var pos = 0;
            var index = 0;


            if self.parentController != nil {
                for post in self.parentController!.dataSource {
                    if (post as! LPPost).objectId! == self.postInfoModel!.objectId! {
                        pos = index;
                        break;
                    }
                    index = index + 1;
                }
                self.parentController!.dataSource.replaceObject(at: pos, with: self.postInfoModel!);
                self.parentController!.tableView.reloadRows(at: [self.activeIndexPath!], with: .none)
            }

            if self.parentProfileView != nil {
                for post in self.parentProfileView!.posts {
                    if (post as! LPPost).objectId! == self.postInfoModel!.objectId! {
                        pos = index;
                        break;
                    }
                    index = index + 1;
                }
                self.parentProfileView!.posts.replaceObject(at: pos, with: self.postInfoModel!);
                self.parentProfileView!.reloadRows(at: [self.activeIndexPath!], with: .none)
            }


        }
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {

        if (self.postInfoModel == nil) {
            return 0
        } else {
            return 2;
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return self.dataSource?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return self.commentTitleLabel.frame.size.height
        default:
            return 12
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            return self.commentTitleLabel
        default:
            return UIView();
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView();
    }


    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12;
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.section == 0) {
            let newsFeedPostCell = NewsFeedPostCell.init(style: .default, reuseIdentifier: "kPostCell");
            newsFeedPostCell.setCurretPost(self.postInfoModel!, postStyle: .noPadding,
                    indexPath: indexPath);
            newsFeedPostCell.delegate = self
            return newsFeedPostCell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as! CommentRowCell
            cell.bindData(comment: self.dataSource![indexPath.row])
            return cell
        }
    }

    // MARK: NewsFeedPostCellDelegate
    func didCommentButtonClickAtIndexPath(_ indexPath: IndexPath) {
        self.commentTextField.becomeFirstResponder();
    }

    func didLikeButtonClickAtIndexPath(_ indexPath: IndexPath) {
        if (self.postInfoModel!.hasLiked == false) {
            let beforeValue: Int = (self.postInfoModel!.likeCount as? Int) ?? 0;
            self.postInfoModel!.likeCount = NSNumber.init(value: beforeValue + 1 as Int)
        } else {
            let beforeValue: Int = (self.postInfoModel!.likeCount as? Int) ?? 0;
            self.postInfoModel!.likeCount = NSNumber.init(value: beforeValue - 1 as Int)
        }

        self.postInfoModel!.hasLiked = !self.postInfoModel!.hasLiked;

        DataModelManager.sharedInstance.cloudFlipPostLikeState(self.postInfoModel!, block: { succeeded, error in
            if (self.filterError(error)) {
//                print("update post like successfully.")
                self.showToast(with: "kToastUpdatePostLikeSuccess".localized);
                self.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: UITableViewRowAnimation.none)
            }
        })
    }


    func didShareButtonClickAtIndexPath(_ indexPath: IndexPath) {
        self.confirmSharingPost(postId: self.postID);
    }

    func confirmSharingPost(postId: String) {

        let shareActionHandler = { (action: UIAlertAction!) -> Void in
            self.showProgress();
            DataModelManager.sharedInstance.cloudSharePost(postId: postId, completion: { object, error in
                self.hideProgress();
                if (self.filterError(error)) {
                    self.showComplete(with: "kToastSharedSuccess".localized)
                }
            });
        }

        let alertController = UIAlertController(title: "kAlertConfirmationTitle".localized, message: "kAlert_ConfirmSharePost".localized,
                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "kCancel".localized, style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "kShare".localized, style: .default, handler: shareActionHandler);
        alertController.addAction(cancelAction);
        alertController.addAction(yesAction);
        self.present(alertController, animated: true)
    }

    func didBadgeClickAtIndexPath(_ indexPath: IndexPath) {
        self.displayDialogBadgeBrief(badge: self.postInfoModel!.badge!);
    }

    func didProfileClickAtIndexPath(_ indexPath: IndexPath, userId: String) {
        let profileController = ProfilePublicController();
        profileController.userId = postInfoModel!.creator.objectId!
        self.navigationController!.pushViewController(profileController, animated: true)
    }

    // MARK: Public Functions
    func sendButtonClicked() {
        guard let content = self.commentTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), !content.isEmpty else {
            return
        }

        self.commentTextField.resignFirstResponder()

        DataModelManager.sharedInstance.cloudPostComment(postId: self.postInfoModel!.objectId, content: content) {
            [weak self] (comment: Any?, error: Error?) in
            withExtendedLifetime(self) {
                guard let comment = comment as! LPComment?, error == nil else {
                    self!.showToast(with: "kToastCommentFailed".localized)
                    return
                }

                self!.showToast(with: "kToastCommentSuccess".localized)
                comment.user = AVUser.current()!
                self!.dataSource?.insert(comment, at: 0)

                let indexPath = IndexPath(row: 0, section: 1)
                self!.tableView.beginUpdates()
                self!.tableView.insertRows(at: [indexPath], with: .fade)
                self!.tableView.endUpdates()

                let beforeValue: Int = (self!.postInfoModel!.commentCount as? Int) ?? 0;
                self!.postInfoModel!.commentCount = NSNumber.init(value: beforeValue + 1 as Int)

                self!.commentTextField.text = nil

                self!.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: UITableViewRowAnimation.none)
            }

        }
    }


    // MARK: Private Functions

    private func sendRequestAndReloadData() {
        DataModelManager.sharedInstance.cloudGetPostDetail(postID, block: {
            (object, error) in
            if (self.filterError(error)) {
                print("get post info model", object ?? "empty");
                self.postInfoModel = (object as! LPPost);
                self.dataSource = self.postInfoModel!.commentPreviewList as! Array<LPComment>?
                self.tableView.reloadData();
            }
        });
    }

    private func addLayoutConstrains() {
        self.tableView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.top.equalTo(self.view)
            make.right.equalTo(self.view)
        }

        self.separatorLine.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.tableView.snp.bottom)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view)
            make.height.equalTo(1)
        }

        self.commentTextField.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(8)
            make.top.equalTo(self.tableView.snp.bottom).offset(4)
            make.height.equalTo(40)
            make.bottom.equalTo(self.view).offset(-4)
        }

        self.sendButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.commentTextField.snp.right).offset(8)
            make.right.equalTo(self.view).offset(-8)
            make.centerY.equalTo(self.commentTextField)
        }
    }

}

private class CommentTitleLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

}

private class CommentRowCell: UITableViewCell {

    private let avatarEdgeLen: CGFloat = 32
    private var commenterId: String?

    private lazy var avatarImageView: UIImageView = { [unowned self] in
        let frame = CGRect(x: 0, y: 0, width: self.avatarEdgeLen, height: self.avatarEdgeLen)
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.asAvatar()
        return imageView
    }()

    private lazy var userNameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = fontSystem12Bold
        return label
    }()

    private lazy var postTimeLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = fontSystem12
        label.textColor = CL_GREY_FONT
        return label
    }()

    private lazy var commentDetailLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = fontSystem14
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var avatarBtn:UIButton = {
        let btn = UIButton.init(type: .custom);
        btn.addTarget(self, action: #selector(self.avatarBtnPressed), for:.touchUpInside);
        return btn;
    }()
    
    func avatarBtnPressed(){
//        let profileController = ProfilePublicController();
//        profileController.userId = self.commenterId!
//        profileController.parentController = self.viewController()!;
//        self.viewController()!.hidesBottomBarWhenPushed = false;
//        self.viewController()!.navigationController?.pushViewController(profileController, animated: true)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.avatarBtn);
        self.contentView.addSubview(self.userNameLabel)
        self.contentView.addSubview(self.postTimeLabel)
        self.contentView.addSubview(self.commentDetailLabel)

        self.addLayoutConstrains()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(comment: LPComment?) {
        guard let comment = comment else {
            return
        }

        self.avatarImageView.sd_setImage(with: URL(string: comment.user.avatar?.url ?? ""),
                                         placeholderImage: UIImage(named: "avatar-ph"))
        self.userNameLabel.text = comment.user.displayName() as String
        self.commentDetailLabel.text = comment.content
        self.postTimeLabel.text = comment.postTime
        self.commenterId = comment.user.objectId!;
    }

    private func addLayoutConstrains() {
        self.avatarImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(8)
            make.left.equalTo(self.contentView).offset(8)
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-8)
            make.width.equalTo(self.avatarEdgeLen)
            make.height.equalTo(self.avatarEdgeLen)
        }
        
        self.avatarBtn.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self.avatarImageView);
            make.size.equalTo(self.avatarImageView);
        }

        self.userNameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.avatarImageView)
            make.left.equalTo(self.avatarImageView.snp.right).offset(8)
        }

        self.postTimeLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.userNameLabel)
            make.left.equalTo(self.userNameLabel.snp.right).offset(8)
            make.height.equalTo(self.userNameLabel)
            make.right.equalTo(self.contentView).offset(-8)
        }

        self.commentDetailLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            make.left.equalTo(self.userNameLabel)
            make.right.equalTo(self.contentView).offset(-8)
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-8)
        }

        self.userNameLabel.setContentHuggingPriority(252, for: .horizontal)
        self.postTimeLabel.setContentCompressionResistancePriority(1000, for: .horizontal)
    }

}


