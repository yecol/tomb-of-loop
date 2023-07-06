//
//  ProfileFriendController.swift
//  loop
//
//  Created by Yecol Hsu on 14/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import ESPullToRefresh
import DZNEmptyDataSet

class ProfileFriendView: UITableView, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var viewUserId = "";
    var friends = NSMutableArray();
    var profileScrollDelegate: ProfileScrollDelegate?;
    var currentRefreshType = RefreshType.loadDefault;
    
//    var datasourceRequesting = false;
    var datasourceIsEmpty =  false;

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style);
        self.backgroundColor = CL_GREY_BG_EC
        self.dataSource = self;
        self.delegate = self;
        self.estimatedRowHeight = 60;
        self.rowHeight = UITableViewAutomaticDimension;
        
        self.emptyDataSetSource = self;
        self.emptyDataSetDelegate = self;

        self.es_addInfiniteScrolling {
            [weak self] in
            self?.refresh(type: .loadMore)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.profileScrollDelegate?.didScroll(scrollView.contentOffset.y);
    }
    
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: "empty-friend");
//    }
    
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


    func refresh(type: RefreshType) {

        if (type == RefreshType.loadDefault && self.friends.count > 0) {
            return;
        }
        
//        if(self.datasourceRequesting){
//            return;
//        }
//        
//        self.datasourceRequesting = true;
//        self.viewController()?.showLoadingProgress();
        
        self.currentRefreshType = type;

        var offset = 0;
        if (type == RefreshType.loadDefault) {
            self.friends.removeAllObjects();
            offset = 0;
        } else if (self.friends.count != 0) {
            offset = self.friends.count;
        }

        DataModelManager.sharedInstance.cloudGetUserList(UserRequestTypeFriends, limit: kDefaultUserNumPerPage,
                skip: offset, specific: self.viewUserId,
                block: { (users: Array<Any>?, error: Error?) in
//                    self.datasourceRequesting = false;
//                    self.viewController()?.hideProgress();
                    if (self.viewController()?.filterError(error) ?? false) {
                        if (users == nil || users!.count == 0) {
                            self.es_noticeNoMoreData()
                        }
                        else {
                            self.friends.addObjects(from: users!);
                            self.reloadData()
                            self.es_stopLoadingMore()
                        }
                        if(self.friends.count == 0){
                            self.datasourceIsEmpty = true;
                            self.reloadData();
                        }
                    }
        });
    }

// MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count;
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12;
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        var cell = tableView.dequeueReusableCell(withIdentifier: kFriendCellIdentifier) as! FriendCell?;

        if (cell == nil) {
            cell = FriendCell(style: .subtitle, reuseIdentifier: kFriendCellIdentifier) as FriendCell;
        }

        let friend = self.friends.object(at: indexPath.row) as! AVUser;
        let details = String(format: "kFriendItemDetail_Holder".localized, friend.postCount, friend.badgeCount,
                friend.friendCount);

        cell!.bindData(friend.displayName(), avatar:(friend.avatar?.url ?? ""), detail: details)
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = self.friends.object(at: indexPath.row) as! AVUser;
        let profileController = ProfilePublicController();
        profileController.userId = friend.objectId!
        self.viewController()!.navigationController!.pushViewController(profileController, animated: true);
        tableView.deselectRow(at: indexPath, animated: true);
    }

}
