//
//  ProfilePostController.swift
//  loop
//
//  Created by Yecol Hsu on 08/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import CarbonKit
import ESPullToRefresh
import DZNEmptyDataSet

fileprivate let kNewsCell = "kNewsCell";

class ProfilePostView: UITableView, NewsFeedPostCellDelegate,
UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func didMoreButtonClickAtIndexPath(_ indexPath: IndexPath) {
//        TODO
    }


    var viewUserId = "";
    var posts = NSMutableArray();
    var selectedIndex: IndexPath?
    var currentRefreshType: RefreshType = .loadDefault;
    var profileScrollDelegate: ProfileScrollDelegate?;
    
//    var datasourceRequesting = false;
    var datasourceIsEmpty = false;

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style);
        self.backgroundColor = CL_GREY_BG_EC;
        self.separatorStyle = .none;
        self.allowsSelection = false;
        self.estimatedRowHeight = 60;
        self.rowHeight = UITableViewAutomaticDimension
        self.register(NewsFeedPostCell.self, forCellReuseIdentifier: kNewsCell);
        self.delegate = self;
        self.dataSource = self;

//        self.emptyDataSetSource = self;
//        self.emptyDataSetDelegate = self;

        self.es_addInfiniteScrolling {
            [weak self] in
            self?.refresh(type: .loadMore)
        }
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty-post");
    }


    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white;
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.datasourceIsEmpty;
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyText = "kEmptyFeed".localized;
        let attributes = [NSForegroundColorAttributeName: CL_GREY_BG_EC, NSFontAttributeName: fontMontserrat18]
        return NSAttributedString(string: emptyText, attributes: attributes);
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.profileScrollDelegate?.didScroll(scrollView.contentOffset.y);
    }

    func refresh(type: RefreshType) {
        if (type == RefreshType.loadDefault && self.posts.count != 0) {
            return;
        }
//        
//        if(self.datasourceRequesting){
//            return;
//        }
//        
//        self.datasourceRequesting = true;
//        self.viewController()?.showLoadingProgress();
        
        self.currentRefreshType = type;

        let size = kDefaultPostNumPerPage;

        var maxDate: Date? = nil;

        if (self.posts.count != 0 && self.currentRefreshType == RefreshType.loadMore) {
            let lastPost = (self.posts.lastObject! as! LPPost);
            if (lastPost.sharedBy == nil) {
                //created post
                maxDate = lastPost.createdAt!.addingTimeInterval(-10)
            } else {
                //shared post
                maxDate = lastPost.sharedAt!.addingTimeInterval(-10)
            }
        }

        DataModelManager.sharedInstance.cloudGetPostList(PostRequestTypeSpecific, limit: size, max: maxDate, min: nil, specifiedUserId: self.viewUserId,
                block: { (posts: Array<Any>?, error: Error?) in
//                    self.datasourceRequesting = false;
//                    self.viewController()?.hideProgress();
                    if (self.viewController()?.filterError(error) ?? false) {
                        if (posts == nil || posts!.count == 0) {
                            print("no updated")
                            self.es_noticeNoMoreData()
                        } else {
                            if (self.currentRefreshType == RefreshType.loadMore) {
                                // loadMore
                                self.posts.addObjects(from: posts!);
                                self.reloadData();
                                self.es_stopLoadingMore()
                            } else {
                                self.posts.addObjects(from: posts!);
                                self.reloadData();
                            }
                        }
                        if(self.posts.count == 0){
                            self.datasourceIsEmpty = true;
                            self.reloadData();
                        }
                    }
                })
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count;
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: kNewsCell, for: indexPath) as! NewsFeedPostCell
        cell.setCurretPost(self.posts[indexPath.row] as! LPPost, postStyle: .cardWithComment, indexPath:
        indexPath);
        cell.delegate = self
        return cell;
    }

    func didCommentButtonClickAtIndexPath(_ indexPath: IndexPath) {
        let postCommentController = PostCommentController(postID: (self.posts[indexPath.row] as! LPPost).objectId!)
        postCommentController.activeIndexPath = indexPath;
        postCommentController.parentProfileView = self;
        postCommentController.hidesBottomBarWhenPushed = true
        self.viewController()!.navigationController?.pushViewController(postCommentController, animated: true)
    }

    func didLikeButtonClickAtIndexPath(_ indexPath: IndexPath) {
        self.selectedIndex = indexPath;
        let post = self.posts[self.selectedIndex!.row] as! LPPost;
        post.hasLiked = !post.hasLiked;

        if (post.hasLiked == false) {
            let beforeValue: Int = (post.likeCount as? Int) ?? 0;
            post.likeCount = NSNumber.init(value: beforeValue - 1 as Int)
        } else {
            let beforeValue: Int = (post.likeCount as? Int) ?? 0;
            post.likeCount = NSNumber.init(value: beforeValue + 1 as Int)
        }

        DataModelManager.sharedInstance.cloudFlipPostLikeState(post, block: { succeeded, error in
            if (self.viewController()!.filterError(error)) {
                self.viewController()!.showToast(with: "kToastUpdatePostLikeSuccess".localized);
            }
        })
    }

    func didBadgeClickAtIndexPath(_ indexPath: IndexPath) {
        let badgeDetailController = BadgeController(badge: (self.posts[indexPath.row] as! LPPost).badge!);
        self.viewController()!.navigationController?.pushViewController(badgeDetailController, animated: true)
    }

    func didShareButtonClickAtIndexPath(_ indexPath: IndexPath) {
        let post = self.posts[indexPath.row] as! LPPost;
        self.confirmSharingPost(postId: post.objectId!);
    }

    func confirmSharingPost(postId: String) {

        let shareActionHandler = { (action: UIAlertAction!) -> Void in
            self.viewController()!.showProgress();
            DataModelManager.sharedInstance.cloudSharePost(postId: postId, completion: { object, error in
                self.viewController()!.hideProgress();
                if (self.viewController()!.filterError(error)) {
                    self.viewController()!.showComplete(with: "kToastSharedSuccess".localized)
                }
            });
        }

        let alertController = UIAlertController(title: "kAlertConfirmationTitle".localized, message: "kAlert_ConfirmSharePost".localized,
                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "kCancel".localized, style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "kShare".localized, style: .default, handler: shareActionHandler);
        alertController.addAction(cancelAction);
        alertController.addAction(yesAction);
        self.viewController()!.present(alertController, animated: true)

    }

    func didProfileClickAtIndexPath(_ indexPath: IndexPath, userId: String) {
        let profileController = ProfilePublicController();
        profileController.userId = AVUser.current()!.objectId!;
        self.viewController()?.navigationController?.pushViewController(profileController, animated: true)
    }

}
