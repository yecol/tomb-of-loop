//
//  ProfileSelfListFriendsController.swift
//  loop
//
//  Created by Yecol Hsu on 25/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class ProfileSelfListFriendsController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var user: AVUser;
    var currentRefreshType = RefreshType.loadDefault;
    
    var datasourceRequesting = false;
    var datasourceIsEmpty =  false;

    init(aUser: AVUser) {
        self.user = aUser;
        super.init(style: .grouped);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var dataSource = NSMutableArray();

    override func viewDidLoad() {

        super.viewDidLoad()
        self.title = "kTitle_MyFriends".localized;

        self.tableView.backgroundColor = CL_GREY_BG_EC;

        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;

        self.tableView.estimatedRowHeight = 60;
        self.tableView.rowHeight = UITableViewAutomaticDimension;

        // A little trick for removing the cell separators
        self.tableView.tableFooterView = UIView();
        self.tableView.dataSource = self;
//                self.tableView.register(FriendCell.self, forCellReuseIdentifier: kFriendCellIdentifier)

        self.navBarBgAlpha = 1
        self.navBarTintColor = .white

        self.tableView.es_addPullToRefresh {
            [weak self] in
            self?.refresh(type: .loadDefault)
        }

        self.tableView.es_addInfiniteScrolling {
            [weak self] in
            self?.refresh(type: .loadMore)
        }

        self.refresh(type: .loadDefault);
    }

    func refresh(type: RefreshType) {
        
        if(self.datasourceRequesting){
            return;
        }
        
        self.datasourceRequesting = true;
        self.showLoadingProgress();
        self.currentRefreshType = type;

        var offset = 0;
        if (type == RefreshType.loadDefault) {
            self.dataSource.removeAllObjects();
            offset = 0;
        } else if (self.dataSource.count != 0) {
            offset = self.dataSource.count;
        }

        DataModelManager.sharedInstance.cloudGetUserList(UserRequestTypeFriends, limit: kDefaultUserNumPerPage,
                skip: offset, specific: user.objectId!,
                block: { (users: Array<Any>?, error: Error?) in
                    self.datasourceRequesting = false;
                    self.hideProgress();
                    if (self.filterError(error)) {
                        if (users == nil || users!.count == 0) {
                            if (self.currentRefreshType == RefreshType.loadDefault) {
                                self.tableView.es_stopPullToRefresh(ignoreDate: true)
                            } else {
                                self.tableView.es_noticeNoMoreData()
                            }
                        } else {
                            self.dataSource.addObjects(from: users!);
                            self.tableView.reloadData();
                            if (self.currentRefreshType == RefreshType.loadDefault) {
                                self.tableView.es_stopPullToRefresh(ignoreDate: true)
                            } else {
                                self.tableView.es_stopLoadingMore()
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
        return UIImage(named: "empty-friend");
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white;
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.datasourceIsEmpty;
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyText = "kEmptyFriends".localized;
        let attributes = [NSForegroundColorAttributeName: CL_GREY_BG_EC, NSFontAttributeName: fontMontserrat18]
        return NSAttributedString(string: emptyText, attributes: attributes);
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        var cell = tableView.dequeueReusableCell(withIdentifier: kFriendCellIdentifier) as! FriendCell?;

        if (cell == nil) {
            cell = FriendCell(style: .subtitle, reuseIdentifier: kFriendCellIdentifier) as FriendCell;
        }

        let friend = self.dataSource.object(at: indexPath.row) as! AVUser;
        let details = String(format: "kFriendItemDetail_Holder".localized, friend.postCount, friend.badgeCount, friend.friendCount);

        cell!.bindData(friend.displayName(), avatar: friend.avatar?.url ?? "", detail: details)
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = self.dataSource.object(at: indexPath.row) as! AVUser;
        let profileController = ProfilePublicController();
        profileController.userId = friend.objectId!;
        self.navigationController!.pushViewController(profileController, animated: true);
        tableView.deselectRow(at: indexPath, animated: true);
    }

}
