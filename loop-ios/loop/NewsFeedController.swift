//
//  NewsFeedBase.swift
//  loop
//
//  Created by Yecol Hsu on 21/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit
import ESPullToRefresh
import DZNEmptyDataSet

fileprivate let kNewsCell = "kNewsCell";

class NewsFeedController: UIViewController, UITableViewDelegate, UITableViewDataSource,
        NewsFeedPostCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var streamType: StreamType
    var selectedIndex: IndexPath?
    var dataSource = NSMutableArray()
    var badgeIdArray = Array<String>()
    var currentRefreshType = RefreshType.loadDefault
    
    var datasourceRequesting = false;
    var datasourceIsEmpty = false;

    lazy var tableView: UITableView = { [unowned self] in
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.showsVerticalScrollIndicator = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = nil
        tableView.backgroundColor = CL_GREY_BG_EC
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(NewsFeedPostCell.self, forCellReuseIdentifier: kNewsCell)
        return tableView
    }()

    init(type: StreamType) {
        self.streamType = type;
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()


//        self.tableView.emptyDataSetSource = self;
//        self.tableView.emptyDataSetDelegate = self;

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) -> Void in
            make.size.equalToSuperview();
            make.center.equalToSuperview();
        }

        self.tableView.es_addPullToRefresh { [weak self] in
            self?.refresh(.loadLatest)
        }

        self.tableView.es_addInfiniteScrolling { [weak self] in
            self?.refresh(.loadMore)
        }

        self.refresh(.loadDefault)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBar.isTranslucent = true
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty-post");
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.datasourceIsEmpty;
    }


    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white;
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyText = "kEmptyFeed".localized;
        let attributes = [NSForegroundColorAttributeName: CL_GREY_BG_EC, NSFontAttributeName: fontMontserrat18]
        return NSAttributedString(string: emptyText, attributes: attributes);
    }

    func refresh(_ type: RefreshType) {
        guard AVUser.current() != nil else {
            return
        }
        
        if(self.datasourceRequesting){
            return;
        }
        
        self.datasourceRequesting = true;
        self.showLoadingProgress();

        self.currentRefreshType = type

        let requestType = self.streamType == .friendStream ? PostRequestTypeFriends : PostRequestTypeRecommended
        let size = kDefaultPostNumPerPage;

        var maxPostDate: Date? = nil
        var minPostDate: Date? = nil

        if self.dataSource.count != 0 && self.currentRefreshType == .loadMore {
            let lastPost = (self.dataSource.lastObject! as! LPPost);
            if lastPost.sharedBy == nil {
                maxPostDate = lastPost.createdAt!.addingTimeInterval(-10)
            } else {
                maxPostDate = lastPost.sharedAt!.addingTimeInterval(-10)
            }
        } else if self.dataSource.count != 0 && self.currentRefreshType == .loadLatest {
            let firstPost = (self.dataSource.firstObject! as! LPPost);
            if firstPost.sharedBy == nil {
                minPostDate = firstPost.createdAt!.addingTimeInterval(10)
            } else {
                minPostDate = firstPost.sharedAt!.addingTimeInterval(10)
            }
        }

        DataModelManager.sharedInstance.cloudGetPostList(type: requestType, limit: size, maxPostTime: maxPostDate,
                minPostTime: minPostDate, specifiedUserId: "", badgeIdArray: self.badgeIdArray,
                completion: { [weak self] (posts: Array<Any>?, error: Error?) in
                    withExtendedLifetime(self) {
                        
                        self!.datasourceRequesting = false;
                        self!.hideProgress();
                        guard self!.filterError(error) else {
                            return
                        }

                        if posts == nil || posts!.count == 0 {

                            if (self!.currentRefreshType == .loadDefault) {
                                self!.dataSource.removeAllObjects();
                                self!.tableView.reloadData();
                            } else if self!.currentRefreshType == .loadMore {
                                self!.tableView.es_noticeNoMoreData()
                            } else {
                                self!.tableView.es_stopPullToRefresh(ignoreDate: true)
                            }
                            return
                        }

                        switch self!.currentRefreshType {
                        case .loadLatest:
                            let indexSet = IndexSet(0...posts!.count - 1);
                            self!.dataSource.insert(posts!, at: indexSet);
                            self!.tableView.reloadData();
                            self!.tableView.es_stopPullToRefresh(ignoreDate: true)
                            break
                        case .loadMore:
                            self!.dataSource.addObjects(from: posts!);
                            self!.tableView.reloadData();
                            self!.tableView.es_stopLoadingMore()
                            break
                        default:
                            self!.dataSource = NSMutableArray()
                            self!.dataSource.addObjects(from: posts!);
                            self!.tableView.reloadData();
                            break
                        }
                        
                        if(self!.dataSource.count == 0){
                            self!.datasourceIsEmpty = true;
                            self!.tableView.reloadData();
                        }
                    }
                })
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count;
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kNewsCell, for: indexPath) as! NewsFeedPostCell
        switch (self.streamType) {
        case .friendStream:
            cell.setCurretPost(self.dataSource[indexPath.row] as! LPPost, postStyle: .cardWithComment,
                    indexPath: indexPath);
        default:
            cell.setCurretPost(self.dataSource[indexPath.row] as! LPPost, postStyle: .cardNoComment,
                    indexPath: indexPath);
        }
        cell.delegate = self
        return cell;
    }

    // MARK: NewsFeedCellDelegate

    func didCommentButtonClickAtIndexPath(_ indexPath: IndexPath) {
        let postCommentController = PostCommentController(postID: (self.dataSource[indexPath.row] as! LPPost).objectId!)
        postCommentController.activeIndexPath = indexPath;
        postCommentController.hidesBottomBarWhenPushed = true
        postCommentController.parentController = self;
        self.navigationController?.pushViewController(postCommentController, animated: true)
    }

    func didLikeButtonClickAtIndexPath(_ indexPath: IndexPath) {
        self.selectedIndex = indexPath;
        let post = self.dataSource[self.selectedIndex!.row] as! LPPost;

        if (post.hasLiked == false) {
            let beforeValue: Int = (post.likeCount as? Int) ?? 0;
            post.likeCount = NSNumber.init(value: beforeValue + 1 as Int)
        } else {
            let beforeValue: Int = (post.likeCount as? Int) ?? 0;
            post.likeCount = NSNumber.init(value: beforeValue - 1 as Int)
        }

        post.hasLiked = !post.hasLiked;
        DataModelManager.sharedInstance.cloudFlipPostLikeState(post, block: { succeeded, error in
            if (self.filterError(error)) {
                self.showToast(with: "kToastUpdatePostLikeSuccess".localized);
            }
        })
    }

    func didBadgeClickAtIndexPath(_ indexPath: IndexPath) {

        if ((self.dataSource[indexPath.row] as! LPPost).badge != nil) {
            self.displayDialogBadgeBrief(badge: (self.dataSource[indexPath.row] as! LPPost).badge!);
        } else {
//            print("badge = nil")
        }
    }

    func didProfileClickAtIndexPath(_ indexPath: IndexPath, userId: String) {
        let profileController = ProfilePublicController();
        if (userId == "") {
            let x = (self.dataSource[indexPath.row] as! LPPost).creator.objectId!;
            profileController.userId = (x)
        } else {
            profileController.userId = userId
        }
        self.navigationController!.pushViewController(profileController, animated: true)
    }

    func didShareButtonClickAtIndexPath(_ indexPath: IndexPath) {
        let post = self.dataSource[indexPath.row] as! LPPost;
        self.confirmSharingPost(postId: post.objectId!);
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
    
    
    func didMoreButtonClickAtIndexPath(_ indexPath: IndexPath) {
        
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        
        let cancelAction = UIAlertAction(title: "kCancel".localized, style: UIAlertActionStyle.cancel, handler: nil)
        let reportAction = UIAlertAction(title: "kAlertItem_Report_Post".localized, style: UIAlertActionStyle.destructive, handler:{Void in
            DataModelManager.sharedInstance.cloudReportPost(self.dataSource[indexPath.row] as! LPPost, block: { succeeded, error in
                if (self.filterError(error)) {
                    self.showToast(with: "kToastPostReportSuccess".localized);
                    self.dataSource.removeObject(at: indexPath.row);
                    self.tableView.reloadData();
                }
            })
        })
        let blockUserAction = UIAlertAction(title: "kAlertItem_Block_User".localized, style: UIAlertActionStyle.default, handler: {Void in
            let blockedUser = (self.dataSource[indexPath.row] as! LPPost).creator!;
            DataModelManager.sharedInstance.cloudBlockUser(blockedUser, block: { succeeded, error in
                if (self.filterError(error)) {
                    self.showToast(with: "kToastUserBlockedSuccess".localized);
                    let blockedUserId = (self.dataSource[indexPath.row] as! LPPost).creator.objectId!;
                    for item in self.dataSource{
                        let post = item as! LPPost;
                        if(post.creator.objectId! == blockedUserId){
                            self.dataSource.removeObject(identicalTo: post);
                        }
                    }
                    self.tableView.reloadData();
                }
            })
        })
        alertSheet.addAction(cancelAction)
        alertSheet.addAction(reportAction)
        alertSheet.addAction(blockUserAction)
        
        self.present(alertSheet, animated: true, completion: nil);
    }
}
