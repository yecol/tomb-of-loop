//
//  NewsFeedCell.swift
//  loop
//
//  Created by Yecol Hsu on 14/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

protocol NewsFeedPostCellDelegate: class {
    func didCommentButtonClickAtIndexPath(_ indexPath: IndexPath)

    func didLikeButtonClickAtIndexPath(_ indexPath: IndexPath)

    func didShareButtonClickAtIndexPath(_ indexPath: IndexPath)
    
    func didMoreButtonClickAtIndexPath(_ indexPath: IndexPath)

    func didBadgeClickAtIndexPath(_ indexPath: IndexPath)

    func didProfileClickAtIndexPath(_ indexPath: IndexPath, userId: String)
}

class NewsFeedPostCell: UITableViewCell, NewsFeedPostRichtextViewDelegate {

    weak var delegate: NewsFeedPostCellDelegate?
//    var post:LPPost?s
    var indexPath: IndexPath?

    private lazy var richtextView: NewsFeedPostRichtextView = {
        let view = NewsFeedPostRichtextView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 60));
        return view;
    }()

    func setup() {
        self.backgroundColor = CL_GREY_BG_EC;
        self.selectionStyle = .none;
        self.contentView.addSubview(self.richtextView);

        self.richtextView.snp.makeConstraints { (make) -> Void in
//            make.top.equalToSuperview();
//            make.left.equalToSuperview();
            make.size.equalToSuperview();
//            make.right.equalToSuperview();
//            make.bottom.equalToSuperview();
            make.center.equalToSuperview();
        }
    }

    func setCurretPost(_ post: LPPost, postStyle: PostStyle, indexPath: IndexPath) {
        self.richtextView.bindData(with: post, style: postStyle)
        self.richtextView.delegate = self;
        self.indexPath = indexPath;
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

//    static func calculateCellHeightWithPost(_ post:LPPost, type:StreamType) -> CGFloat{
//        return NewsFeedPostRichtextView.calculateRichtextHeightWithPost(post, type:type);
//    }

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }

    func didSelectCommentBtn() {
        self.delegate?.didCommentButtonClickAtIndexPath(self.indexPath!)
    }

    func didSelectLikeBtn() {
        self.delegate?.didLikeButtonClickAtIndexPath(self.indexPath!)
    }

    func didSelectShare() {
        self.delegate?.didShareButtonClickAtIndexPath(self.indexPath!)
    }
    
    func didSelectMore() {
        self.delegate?.didMoreButtonClickAtIndexPath(self.indexPath!)
    }

    func didSelectBadge() {
        self.delegate?.didBadgeClickAtIndexPath(self.indexPath!);
    }

    func didSelectProfile(_ userId: String) {
        self.delegate?.didProfileClickAtIndexPath(self.indexPath!, userId: userId);
    }

}
