//
//  ProfileSelfListPostsController.swift
//  loop
//
//  Created by Yecol Hsu on 25/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit
import DZNEmptyDataSet

fileprivate let kUITableCell = "kUITableCell";

class ProfileSelfListPostsController: UITableViewController,
        DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var userID = "";
    var dataSource = NSMutableArray();
    var selectedIndex: IndexPath?
    var currentRefreshType: RefreshType = .loadDefault;
    
    var datasourceRequesting = false;
    var datasourceIsEmpty = false;

    init() {
        super.init(style: .grouped);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "kTitle_MyPosts".localized;

        self.tableView.backgroundColor = CL_GREY_BG_EC;

        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;

        self.tableView.tableFooterView = UIView();

        self.tableView.estimatedRowHeight = 60;
        self.tableView.rowHeight = UITableViewAutomaticDimension;

        self.tableView.register(PostBriefCell.self, forCellReuseIdentifier: kUITableCell)

        self.tableView.es_addPullToRefresh {
            [weak self] in
            self?.refresh(type: .loadLatest)
        }

        self.tableView.es_addInfiniteScrolling {
            [weak self] in
            self?.refresh(type: .loadMore)
        }

        self.refresh(type: .loadDefault)

        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh(type: RefreshType) {

        if(self.datasourceRequesting){
            return;
        }
        
        self.datasourceRequesting = true;
        self.currentRefreshType = type;
        self.showLoadingProgress();

        let size = kDefaultPostNumPerPage;

        var maxDate: Date? = nil;
        var minDate: Date? = nil;

        if (self.dataSource.count != 0 && self.currentRefreshType == RefreshType.loadMore) {
            let lastPost = (self.dataSource.lastObject! as! LPPost);
            if (lastPost.sharedBy == nil) {
                //created post
                maxDate = lastPost.createdAt!.addingTimeInterval(-10)
            } else {
                //shared post
                maxDate = lastPost.sharedAt!.addingTimeInterval(-10)
            }
        } else if (self.dataSource.count != 0 && self.currentRefreshType == RefreshType.loadLatest) {
            let firstPost = (self.dataSource.firstObject! as! LPPost);
            if (firstPost.sharedBy == nil) {
                //created post
                minDate = firstPost.createdAt!.addingTimeInterval(10)
            } else {
                //shared post
                minDate = firstPost.sharedAt!.addingTimeInterval(10)
            }
        }

        DataModelManager.sharedInstance.cloudGetPostList(PostRequestTypeSpecific, limit: size, max: maxDate, min: minDate,
                specifiedUserId: AVUser.current()!.objectId!,
                block: { (posts: Array<Any>?, error: Error?) in
                    self.datasourceRequesting = false;
                    self.hideProgress();
                    if (self.filterError(error)) {
                        if (posts == nil || posts!.count == 0) {
                            print("no updated")
                            if (self.currentRefreshType == RefreshType.loadDefault ||
                                    self.currentRefreshType == RefreshType.loadMore) {
                                self.tableView.es_noticeNoMoreData()
                            } else {
                                self.tableView.es_stopPullToRefresh(ignoreDate: true)
                            }
                        } else {
                            if (self.currentRefreshType == RefreshType.loadLatest) {
                                let indexSet = IndexSet(0...posts!.count - 1);
                                self.dataSource.insert(posts!, at: indexSet);
                                self.tableView.reloadData();
                                self.tableView.es_stopPullToRefresh(ignoreDate: true)
                            } else if (self.currentRefreshType == RefreshType.loadMore) {
                                // loadMore
                                self.dataSource.addObjects(from: posts!);
                                self.tableView.reloadData();
                                self.tableView.es_stopLoadingMore()
                            } else {
                                self.dataSource.addObjects(from: posts!);
                                self.tableView.reloadData();
                            }
                        }
                        if(self.dataSource.count == 0){
                            self.datasourceIsEmpty = true;
                            self.tableView.reloadData();
                        }
                    }
                })
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count;
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FL_SEPARATOR_HEIGHT
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FL_SEPARATOR_HEIGHT;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kUITableCell, for: indexPath) as! PostBriefCell
        cell.bindData(post: self.dataSource[indexPath.row] as! LPPost);
        return cell;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postDetailController = PostCommentController(postID: (self.dataSource[indexPath.row] as! LPPost).objectId!)
        self.navigationController?.pushViewController(postDetailController, animated: true);
        tableView.deselectRow(at: indexPath, animated: true);
    }


}
