//
//  DiscoveryPeopleController.swift
//  loop
//
//  Created by Yecol Hsu on 29/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import CarbonKit

fileprivate let kFriendCell = "kFriendCell"

class DiscoveryPeopleController: UITableViewController {

    var dataSource = NSMutableArray();
    var currentRefreshType = RefreshType.loadDefault;
    
    var datasourceRequesting = false;

    override init(style: UITableViewStyle) {
        super.init(style: style);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = CL_GREY_BG_EC;
        self.tableView.estimatedRowHeight = 56
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(FriendBadgeCell.self, forCellReuseIdentifier: kFriendCell)
        self.tableView.dataSource = self;

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

        DataModelManager.sharedInstance.cloudGetUserList(UserRequestTypeRecommended, limit: kDefaultUserNumPerPage,
                skip: offset, specific: "",
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
                    }
                })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FL_SEPARATOR_HEIGHT;
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FL_SEPARATOR_HEIGHT;
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kFriendCell, for: indexPath) as!
        FriendBadgeCell;
        let friend = self.dataSource.object(at: indexPath.row) as! AVUser;
        cell.bindData(friend)
        return cell;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = self.dataSource.object(at: indexPath.row) as! AVUser;
        let profileController = ProfilePublicController();
        profileController.userId = friend.objectId!;
        self.navigationController!.pushViewController(profileController, animated: true);
        tableView.deselectRow(at: indexPath, animated: true);
    }

}


fileprivate let kDiscoveryAvatarSize: CGFloat = 36.0
fileprivate let kDiscoveryPeopleBadgeSize: CGFloat = 40;

class FriendBadgeCell: UITableViewCell {

    private lazy var badgesView: UIView = { [unowned self] in
        let view = UIView();
        return view;
    }()

    private lazy var avatarImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView();
        imageView.asAvatar(size: kDiscoveryAvatarSize);
        return imageView;
    }()

    private lazy var distanceLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_GREEN_ASSISTANCE;
        label.font = fontSystem12;
        return label;
    }()

    private lazy var detailLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_GREY_FONT;
        label.font = fontSystem12;
        return label;
    }()

    private lazy var nameLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_BLACK_GRACE;
        label.font = fontSystem14Bold;
        return label;
    }()

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier);
        self.contentView.backgroundColor = UIColor.white;
        self.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
        self.contentView.addSubview(self.avatarImageView);
        self.contentView.addSubview(self.nameLabel);
        self.contentView.addSubview(self.detailLabel);
        self.contentView.addSubview(self.distanceLabel);
        self.contentView.addSubview(self.badgesView)
        self.addLayoutConstrains();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(_ userWithBadge: AVUser) {
        self.nameLabel.text = userWithBadge.displayName() as String;
        self.avatarImageView.sd_setImage(with: URL(string: userWithBadge.avatar?.url ?? ""),
                placeholderImage: UIImage(named: "avatar-ph"));

        let locationSelf = AVUser.current()!.lastKnownLocation;
        let locationOther = userWithBadge.lastKnownLocation;
        if (locationSelf != nil && locationOther != nil) {
            self.distanceLabel.text = String(format: "kDistanceDetail_Holder".localized, locationSelf!.distanceInKilometers(to: locationOther!))
        } else {
            self.distanceLabel.text = "kDistanceUnknown".localized
        }

        let details = String(format: "kFriendItemDetail_Holder".localized, userWithBadge.postCount,
                userWithBadge.badgeCount,
                userWithBadge.friendCount);

        detailLabel.text = details;

        for view in self.badgesView.subviews {
            view.removeFromSuperview();
        }

        let oneOffset: CGFloat = kDiscoveryPeopleBadgeSize + 10;
        var offset: CGFloat = 0;
        for badge in userWithBadge.badgeList {
            let rBadge = badge as! LPBadge;
            let frame = CGRect(x: offset, y: 0, width: kDiscoveryPeopleBadgeSize, height: kDiscoveryPeopleBadgeSize);
            offset += oneOffset;
            let badgeView = UIImageView.init(frame: frame);
            badgeView.contentMode = .scaleAspectFill;
            badgeView.sd_setImage(with: URL.init(string: rBadge.smallIcon!.url!), placeholderImage: UIImage(named:
            "badge-ph"))
            self.badgesView.addSubview(badgeView)
        }
    }


    private func addLayoutConstrains() {

        self.avatarImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
            make.width.equalTo(kDiscoveryAvatarSize)
            make.height.equalTo(kDiscoveryAvatarSize)
        }

        self.nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.avatarImageView)
            make.left.equalTo(self.avatarImageView.snp.right).offset(12)
        }

        self.detailLabel.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.avatarImageView)
            make.left.equalTo(self.nameLabel)
        }

        self.distanceLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.detailLabel);
            make.right.equalToSuperview().offset(-12)
        }

        self.badgesView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.detailLabel.snp.bottom).offset(12)
            make.left.equalTo(self.avatarImageView)
            make.width.equalToSuperview();
            make.height.equalTo(kDiscoveryPeopleBadgeSize);
            make.bottom.lessThanOrEqualToSuperview().offset(-12);
        }
    }
}
