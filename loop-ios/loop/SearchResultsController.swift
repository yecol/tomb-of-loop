//
//  SearchResultsController.swift
//  loop
//
//  Created by Yecol Hsu on 24/02/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit

fileprivate let kHeaderCell = "kHeaderCell"
fileprivate let kPostCell = "kPostCell"
fileprivate let kPeopleCell = "kPeopleCell"
fileprivate let kBadgeCell = "kBadgeCell"

class SearchResultsController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var searchPostResults = NSMutableArray();
    var searchPeopleResults = NSMutableArray();
    var searchBadgeResults = NSMutableArray();

    var postSection = -1;
    var peopleSection = -1;
    var badgeSection = -1;

    var curIndex = 0;

    weak var delegate: SearchController?;

    override func viewDidLoad() {
        super.viewDidLoad();
        self.tableView.backgroundColor = CL_GREY_BG_EC;
        self.tableView.estimatedRowHeight = 60;
        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func clearResults() {

        self.searchPeopleResults.removeAllObjects();
        self.searchBadgeResults.removeAllObjects();
        self.searchPostResults.removeAllObjects();

        self.peopleSection = -1;
        self.badgeSection = -1;
        self.postSection = -1;

        self.curIndex = 0;

    }

    func bindSearchResult(dict: NSDictionary) {

        self.clearResults();

        let badges = dict.value(forKey: "badge");
        let users = dict.value(forKey: "user");
        let posts = dict.value(forKey: "post");

        if badges != nil {
            self.searchBadgeResults.addObjects(from: badges as! [Any]);
            self.badgeSection = self.curIndex;
            self.curIndex += 1;
        }
        if users != nil {
            self.searchPeopleResults.addObjects(from: users as! [Any]);
            self.peopleSection = self.curIndex;
            self.curIndex += 1;
        }
        if posts != nil {
            self.searchPostResults.addObjects(from: posts as! [Any]);
            self.postSection = self.curIndex;
            self.curIndex += 1
        }

        self.tableView.reloadData();
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.curIndex;
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case self.badgeSection: return 1;
        case self.peopleSection: return searchPeopleResults.count;
        case self.postSection: return searchPostResults.count;
        default: return 0;
        }
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == self.badgeSection) {
            return 150;
        } else {
            return UITableViewAutomaticDimension;
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0){
            return FL_SEPARATOR_HEIGHT;
        }
        else{
            return FL_SEPARATOR_HEIGHT/2;
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FL_SEPARATOR_HEIGHT/2;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case self.badgeSection:

            var cell = tableView.dequeueReusableCell(withIdentifier: kBadgeCell);
            if (cell == nil) {
                cell = BadgeCollectionCell.init(style: .default, reuseIdentifier: kBadgeCell);
            }
            return cell!
        case self.peopleSection:
            var cell = tableView.dequeueReusableCell(withIdentifier: kPeopleCell) as! FriendCell?;

            if (cell == nil) {
                cell = FriendCell(style: .subtitle, reuseIdentifier: kPeopleCell) as FriendCell;
            }

            let friend = self.searchPeopleResults.object(at: indexPath.row) as! AVUser;
            let details = String(format: "kFriendItemDetail_Holder".localized, friend.postCount, friend.badgeCount,
                    friend.friendCount);

            cell!.bindData(friend.displayName(), avatar: friend.avatar?.url ?? "", detail: details)
            return cell!

        case self.postSection:
            var cell = tableView.dequeueReusableCell(withIdentifier: kPostCell) as? PostBriefCell
            if (cell == nil) {
                cell = PostBriefCell.init(style: .default, reuseIdentifier: kPostCell);
            }
            cell!.bindData(post: self.searchPostResults[indexPath.row] as! LPPost);
            return cell!;

        default:
            var cell = tableView.dequeueReusableCell(withIdentifier: "kcell");
            if (cell == nil) {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "kcell");
            }
            cell!.textLabel?.text = "Hello world."
            return cell!

        }
    }

    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        if (indexPath.section == self.badgeSection) {
            let featuredCell = cell as! BadgeCollectionCell
            featuredCell.setCollectionViewDataSourceDelegate(self, forSection: indexPath.section)
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case self.peopleSection:
            let friend = self.searchPeopleResults.object(at: indexPath.row) as! AVUser;
            let profileController = ProfilePublicController();
            profileController.userId = friend.objectId!;
            self.delegate?.navigationController?.pushViewController(profileController, animated: true);

        case self.postSection:
            let postDetailController = PostCommentController(postID: (self.searchPostResults[indexPath.row] as! LPPost).objectId!)
            postDetailController.hidesBottomBarWhenPushed = true;
            self.delegate?.navigationController?.pushViewController(postDetailController, animated: true);
        default:
            break;
        }
        tableView.deselectRow(at: indexPath, animated: true);
    }


    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.searchBadgeResults.count;
    }


    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kABadgeCell, for: indexPath) as! ABadgeCell
        let badge = self.searchBadgeResults.object(at: indexPath.row) as! LPBadge;
        cell.bindData(badge.name, badgeImageURL: badge.smallIcon!.url!, badgeDetail: String.init(format: "kDiscoveryBadgeHot_Holder".localized, badge.rarity) + "%")
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let badge = self.searchBadgeResults.object(at: indexPath.row) as! LPBadge;
        let badgeDetailController = BadgeController(badge: badge);
        self.delegate?.navigationController?.pushViewController(badgeDetailController, animated: true);
    }
}

class BadgeCollectionCell: UITableViewCell {
    
    private lazy var collectionView: UICollectionView = { [unowned self] in
        
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: (kScreenW - 2 * kABadgePadding) / 3, height: kABadgeCellSize)
        let collectionView = UICollectionView(frame: CGRect.null, collectionViewLayout: flowLayout);
        collectionView.backgroundColor = UIColor.white;
        return collectionView
        }()
    
    //    private lazy var titleLabel: UILabel = { [unowned self] in
    //        let label = UILabel();
    //        label.textColor = CL_BLACK_GRACE;
    //        label.font = fontSystem14Bold;
    //        return label;
    //        }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.contentView.backgroundColor = UIColor.white;
        self.contentView.addSubview(collectionView);
        
        self.collectionView.register(ABadgeCell.self, forCellWithReuseIdentifier: kABadgeCell);
        self.collectionView.snp.makeConstraints { (make) -> Void in
            make.size.equalToSuperview();
            make.center.equalToSuperview();
        }
    };
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setRowInTable(_ row: Int) {
        self.collectionView.tag = row;
    }
    
    func setCollectionViewDataSourceDelegate
        < D: UICollectionViewDataSource & UICollectionViewDelegate >
        (_ dataSourceDelegate: D, forSection section: Int) {
        
        self.collectionView.delegate = dataSourceDelegate
        self.collectionView.dataSource = dataSourceDelegate
        self.collectionView.tag = section
        self.collectionView.reloadData()
    }
    
}

