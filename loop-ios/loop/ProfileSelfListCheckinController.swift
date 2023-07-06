//
//  ProfileSelfListCheckinController.swift
//  loop
//
//  Created by Yecol Hsu on 09/02/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

fileprivate let kCheckinCell = "kCheckinCell";

class ProfileSelfListCheckinController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {


    var dataSource = NSMutableArray();
    var currentRefreshType = RefreshType.loadDefault;
    
    var datasourceRequesting = false;
    var datasourceIsEmpty = false;

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "kTitle_MyCheckIns".localized;

        self.tableView.backgroundColor = CL_GREY_BG_EC;
        self.tableView.dataSource = self;
        self.tableView.register(CheckInLocationCell.self, forCellReuseIdentifier: kCheckinCell);

        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;

        self.tableView.tableFooterView = UIView();
        self.tableView.allowsSelection = false;

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty-checkin");
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white;
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.datasourceIsEmpty;
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyText = "kEmptyCheckIns".localized;
        let attributes = [NSForegroundColorAttributeName: CL_GREY_BG_EC, NSFontAttributeName: fontMontserrat18]
        return NSAttributedString(string: emptyText, attributes: attributes);
    }

    func refresh(type: RefreshType) {
        
        if(datasourceRequesting){
            return;
        }
        
        self.datasourceRequesting = true;
        self.showLoadingProgress();
        
        self.currentRefreshType = type;

        var maxDate: Date?;
        if (type == RefreshType.loadDefault) {
            self.dataSource.removeAllObjects();
        } else if (self.dataSource.count != 0) {
            maxDate = (self.dataSource.lastObject as! LPCheckin).createdAt!.addingTimeInterval(-10);
        }

        DataModelManager.sharedInstance.cloudGetCheckInList(kDefaultCheckInNumPerPage, max: maxDate,
                block: { (checkins: Array<Any>?, error: Error?) in
                    self.datasourceRequesting = false;
                    self.hideProgress();
                    if (self.filterError(error)) {
                        if (checkins == nil || checkins!.count == 0) {
                            if (self.currentRefreshType == RefreshType.loadDefault) {
                                self.tableView.es_stopPullToRefresh(ignoreDate: true)
                            } else {
                                self.tableView.es_noticeNoMoreData()
                            }
                        } else {
//                            print("self.checkins = ", checkins)
                            self.dataSource.addObjects(from: checkins!);
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (self.dataSource.count == 0) {
            return 0;
        } else {
            return 1;
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSource.count;
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12;
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell = tableView.dequeueReusableCell(withIdentifier: kCheckinCell, for: indexPath) as! CheckInLocationCell;
        let ci = self.dataSource.object(at: indexPath.row) as! LPCheckin;
        cell.bindData(title: ci.place!.name!, detailed:ci.displayCheckinDate() + " · " + ci.place!.address!,
                withIcon: ci.place!.iconUrl ?? "");
        return cell
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56;
    }

}
