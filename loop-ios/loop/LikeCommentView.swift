//
//  LikeCommentView.swift
//  loop
//
//  Created by Yecol Hsu on 20/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SnapKit

fileprivate let kCommentCell = "kCommentCell";
fileprivate let kCommentItemPadding: CGFloat = 2.0;
fileprivate let kCommentLimit = 3;

class LikeCommentView: UITableView, UITableViewDataSource, UITableViewDelegate {

    var post: LPPost?

    //TODO: remove me?
    class func calculateCommentsViewHeightWithPost(_ post: LPPost) -> CGFloat {
        var ret: CGFloat = 0.0;
        if (post.commentPreviewList == nil || post.commentPreviewList!.count == 0) {
            return ret;
        } else {
            var count = 1;
            for comment in post.commentPreviewList as! [LPComment] {
                ret += LikeCommentView.calculateCellHeightWithComment(comment);
                ret += kCommentItemPadding;
                count = count + 1;
                if (count > kCommentLimit) {
                    break;
                }
            }
            return ret + 10;
        }
    }

    //TODO: remove me?
    class func calculateCellHeightWithComment(_ comment: LPComment?) -> CGFloat {
        if (comment == nil) {
            return 0.0;
        }
        let mockLabel = TTTAttributedLabel(frame: CGRect(x: 0, y: 0, width: kContentWidth, height: CGFloat.greatestFiniteMagnitude));
        mockLabel.font = fontSystem14;
        mockLabel.numberOfLines = 0;
        mockLabel.lineBreakMode = .byWordWrapping;
        mockLabel.text = comment!.fullText as String;
        mockLabel.sizeToFit();
        return mockLabel.frame.size.height;
    }


    class func shouldShowCommentsViewWithPost(_ post: LPPost) -> Bool {
        return post.commentPreviewList!.count > 0;
    }

    override required init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.separatorStyle = .none;
        self.dataSource = self;
        self.delegate = self;
        self.isScrollEnabled = false;
        self.estimatedRowHeight = 20
        self.rowHeight = UITableViewAutomaticDimension
        self.register(CommentBriefCell.self, forCellReuseIdentifier: kCommentCell)
        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, .flexibleHeight]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCurrentPost(_ post: LPPost) {
        self.post = post;
        self.reloadData();
    }

//    override func layoutSubviews() {
//        super.layoutSubviews();
////
//        var commentTableFrame = self.commentTableView.frame;
////        commentTableFrame.origin.y = CGRectGetMaxY(self.likeContainerView.frame);//
//        if (self.post != nil) {
//            commentTableFrame.size.height = LikeCommentView.calculateCommentsViewHeightWithPost(self.post!)
//        } else {
//            commentTableFrame.size.height = 0;
//        }
//        self.commentTableView.frame = commentTableFrame;
//    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.post?.commentPreviewList?.count) ?? 0;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let commentCell = tableView.dequeueReusableCell(withIdentifier: kCommentCell, for: indexPath) as! CommentBriefCell;
        let comment = self.post!.commentPreviewList![indexPath.row] as! LPComment;
        commentCell.bindData(comment, atIndexPath: indexPath);
        return commentCell;

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
    }
}

private class CommentBriefCell: UITableViewCell, TTTAttributedLabelDelegate {

    private lazy var commentLabel: TTTAttributedLabel = {
        let label = TTTAttributedLabel(frame: CGRect.null);
        label.textColor = CL_BLACK_GRACE
        label.font = fontSystem14;
        label.numberOfLines = 0;
        label.lineBreakMode = .byWordWrapping;
        let attr = [NSUnderlineStyleAttributeName: false,
                    kCTForegroundColorAttributeName as AnyHashable: CL_LINK_COLOR,
                    NSFontAttributeName: fontSystem14Bold] as [AnyHashable : Any];
        label.linkAttributes = attr;
        label.activeLinkAttributes = attr;
        label.delegate = self;
        return label;
    }();


//    class func calculateCellHeightWithComment(_ comment: LPComment?, fixWidth: CGFloat) -> CGFloat {
//        if (comment == nil) {
//            return 0.0;
//        }
//
//        let mockLabel = TTTAttributedLabel(frame: CGRect(x: 0, y: 0, width: fixWidth, height: CGFloat.greatestFiniteMagnitude));
//        CommentCell.customCommentLabel(mockLabel);
//        mockLabel.text = comment!.fullText as String;
//        mockLabel.sizeToFit();
//        return mockLabel.frame.size.height;
//    }

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.selectionStyle = .none;
        self.contentView.addSubview(self.commentLabel);
        self.addLayoutConstraints();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }

    func bindData(_ comment: LPComment, atIndexPath indexPath: IndexPath) {
        let fromUsernameRange = comment.fromUserRange;
        let fullCommentText = comment.fullText;
        if (fullCommentText.length > 0) {
            let attributedText = NSMutableAttributedString(string: fullCommentText as String);
            attributedText.setAttributes([NSForegroundColorAttributeName: CL_LINK_COLOR], range: fromUsernameRange);
            self.commentLabel.setText(attributedText, afterInheritingLabelAttributesAndConfiguringWith: { attrString in
                return attrString
            });
            if (fromUsernameRange.location != NSNotFound) {
                self.commentLabel.addLink(to: URL(string: comment.user.objectId! as String), with: fromUsernameRange);
            }
        } else {
            self.commentLabel.text = nil;
        }
    }

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    }


    func addLayoutConstraints() {
        self.commentLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kContentWidth);
            make.top.equalToSuperview();
            make.bottom.equalToSuperview().offset(-kCommentItemPadding);
            make.right.equalToSuperview();
            make.left.equalToSuperview();
        }

        self.commentLabel.setContentHuggingPriority(252, for: .horizontal)
    }
}
