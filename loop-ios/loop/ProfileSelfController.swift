//
//  ProfileSelfController.swift
//  loop
//
//  Created by Yecol Hsu on 27/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

fileprivate let kDefaultCell = "kDefaultCell"
fileprivate let kUncountableCell = "kUncountableCell"
fileprivate let kAvatarCell = "kAvatarCell"

let kProfileSelfLeftSpacing: CGFloat = 16;
fileprivate let kProfileSelfIconSize: CGFloat = 28;

class ProfileSelfController: UITableViewController {

    let profileItems = NSDictionary();

    let myContentTitles = ["kProfileSelfMyFriends".localized,
                           "kProfileSelfMyBadges".localized,
                           "kProfileSelfMyPosts".localized,
                           "kProfileSelfMyCheckIns".localized,
                           "kProfileSelfMyFavouriteBadges".localized,
                           "kProfileSelfBlockedUsers".localized];
    let myContentIcons = ["profile-friends", "profile-badges", "profile-posts", "profile-checkins", "profile-badgelike", "profile-blocks"];

    let otherTitles = ["kProfileSelfEditProfile".localized,
                       "kProfileSelfSettings".localized];
    let otherIcons = ["profile-edit", "profile-settings"];

    init() {
        super.init(style: .grouped);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "kTitle_Profile".localized

        self.tableView.register(ProfileSelfCell.self, forCellReuseIdentifier: kDefaultCell)
        self.tableView.register(ProfileSelfUncountableCell.self, forCellReuseIdentifier: kUncountableCell)
        self.tableView.register(ProfileSelfAvatarCell.self, forCellReuseIdentifier: kAvatarCell)

        self.tableView.estimatedRowHeight = 60;
        self.tableView.rowHeight = UITableViewAutomaticDimension;

        self.tableView.backgroundColor = CL_GREY_BG_EC;
        self.navigationController?.navigationBar.isTranslucent = true;
        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        AVUser.current()?.refreshInBackground({ _, _ in
            self.tableView.reloadData();
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4;
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return FL_SEPARATOR_HEIGHT
        } else {
            return FL_SEPARATOR_HEIGHT / 2;
        }

    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FL_SEPARATOR_HEIGHT / 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 2: return myContentTitles.count;
        case 3: return otherTitles.count;
        default: return 1;
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: kAvatarCell, for: indexPath)
            as! ProfileSelfAvatarCell;
            cell.bindData(AVUser.current()!.displayName() as String,
                          withAvatar: (AVUser.current()!.avatar?.url ?? "") as String)
            cell.accessoryType = .disclosureIndicator;
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: kUncountableCell, for: indexPath) as! ProfileSelfUncountableCell;
            cell.bindData("kProfileSelfNotifications".localized, withIcon: "profile-notifications");
            cell.accessoryType = .disclosureIndicator;
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: kUncountableCell, for: indexPath) as! ProfileSelfUncountableCell;
            cell.bindData(myContentTitles[indexPath.row], withIcon: myContentIcons[indexPath.row]);
            cell.accessoryType = .disclosureIndicator
            return cell
//            var count = 0;
//            switch indexPath.row {
//            case 0: count = AVUser.current()!.friendCount;
//            case 1: count = AVUser.current()!.badgeCount;
//            case 2: count = AVUser.current()!.postCount;
//            case 3: count = AVUser.current()!.checkinCount;
//            case 4: count = AVUser.current()!.favoriteBadgeCount;
//            default: count = 0;
//            }
//            cell.bindData(myContentTitles[indexPath.row], withIcon: myContentIcons[indexPath.row], andCount: count);
//            cell.accessoryType = .disclosureIndicator;
//            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: kUncountableCell, for: indexPath) as! ProfileSelfUncountableCell;
            cell.bindData(otherTitles[indexPath.row], withIcon: otherIcons[indexPath.row]);
            cell.accessoryType = .disclosureIndicator
            return cell
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:
            let profilePublicController = ProfilePublicController();
            profilePublicController.userId = AVUser.current()!.objectId!;
            self.navigationController!.pushViewController(profilePublicController, animated: true)
        case 1:
            let notificationsController = NotificationsController(style: .grouped);
            self.navigationController!.pushViewController(notificationsController, animated: true);
        case 2:
            switch (indexPath.row) {
            case 0:
                let friendsList = ProfileSelfListFriendsController(aUser: AVUser.current()!);
                self.navigationController?.pushViewController(friendsList, animated: true);
            case 1:
                let flowLayout = UICollectionViewFlowLayout();
                let badgesList = ProfileSelfListBadgesController(collectionViewLayout: flowLayout);
                badgesList.setBadgeRequestType(type: BadgeRequestTypeSpecific);
                self.navigationController?.pushViewController(badgesList, animated: true);
            case 2:
                let postsList = ProfileSelfListPostsController();
                postsList.userID = AVUser.current()!.objectId!;
                self.navigationController?.pushViewController(postsList, animated: true);
            case 3:
                let checkInList = ProfileSelfListCheckinController(style: .grouped);
                self.navigationController?.pushViewController(checkInList, animated: true);
            case 4:
                let flowLayout = UICollectionViewFlowLayout();
                let badgesList = ProfileSelfListBadgesController(collectionViewLayout: flowLayout);
                badgesList.setBadgeRequestType(type: BadgeRequestTypeFavourited);
                self.navigationController?.pushViewController(badgesList, animated: true);
            case 5:
                let blocksList = ProfileSelfListBlocksController(aUser: AVUser.current()!);
                self.navigationController?.pushViewController(blocksList, animated: true);
            default:();
            }
        case 3:
            switch (indexPath.row) {
            case 0:
                let profileEditController = RegisterDetailController(style: .grouped);
                profileEditController.updateProfileView = true;
                profileEditController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(profileEditController, animated: true)
            case 1:
                let settingsController = SettingsController(style: .grouped);
                self.navigationController!.pushViewController(settingsController, animated: true);
            default:();
            }
        default:();
        }
        tableView.deselectRow(at: indexPath, animated: true);
    }
}

private class ProfileSelfAvatarCell: UITableViewCell {

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.asAvatar(size: kDefaultAvatarSize)
        imageView.image = UIImage(named: "avatar-ph");
        return imageView;
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel();
        label.font = fontSystem18Bold
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel();
        label.font = fontSystem12
        label.textColor = CL_GREY_FONT;
        label.text = "kProfileSelfViewYourPublicProfile".localized
        return label;
    }()


    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier);

        self.backgroundColor = UIColor.white;
        self.selectionStyle = .default;

        self.contentView.addSubview(avatarImageView);
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(detailLabel);

        self.addLayoutConstraints();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLayoutConstraints() {

        self.contentView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview();
            make.top.equalToSuperview();
            make.height.equalTo(kDefaultAvatarSize + 24);
        }

        self.avatarImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kDefaultAvatarSize);
            make.height.equalTo(kDefaultAvatarSize);
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(kProfileSelfLeftSpacing);
        }

        self.nameLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kScreenW - kDefaultAvatarSize);
            make.height.equalTo(22);
            make.top.equalTo(self.avatarImageView).offset(4)
            make.left.equalTo(self.avatarImageView.snp.right).offset(kProfileSelfLeftSpacing);
        }

        self.detailLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kScreenW - kDefaultAvatarSize);
            make.height.equalTo(16);
            make.bottom.equalTo(self.avatarImageView.snp.bottom).offset(-4)
            make.left.equalTo(self.nameLabel);
        }
    }

    func bindData(_ name: String, withAvatar avatar_url: String) {
        self.nameLabel.text = name;
        self.avatarImageView.sd_setImage(with: URL(string: avatar_url), placeholderImage: UIImage(named: "avatar-ph"));
    }

}


private class ProfileSelfCell: UITableViewCell {

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView;
    }()

    private lazy var itemLabel: UILabel = {
        let label = UILabel();
        label.font = fontSystem14Bold
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel();
        label.font = fontSystem14Bold
        label.textColor = CL_GREY_FONT;
        label.textAlignment = .right
        return label;
    }()


    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.backgroundColor = UIColor.white;
        self.contentView.addSubview(iconImageView);
        self.contentView.addSubview(itemLabel);
        self.contentView.addSubview(countLabel);
        self.addLayoutConstraints();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLayoutConstraints() {

        self.contentView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview();
            make.top.equalToSuperview();
            make.height.equalTo(kProfileSelfIconSize + 24);
        }

        self.iconImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kProfileSelfIconSize);
            make.height.equalTo(kProfileSelfIconSize);
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(kProfileSelfLeftSpacing);
        }

        self.itemLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kScreenW - kProfileSelfIconSize - 60);
            make.height.equalTo(18);
            make.centerY.equalTo(self.iconImageView)
            make.left.equalTo(self.iconImageView.snp.right).offset(kProfileSelfLeftSpacing);
        }

        self.countLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(40);
            make.height.equalTo(16);
            make.centerY.equalTo(self.iconImageView)
            make.right.equalToSuperview().offset(-35);
        }
    }

    func bindData(_ title: String, withIcon icon: String, andCount count: Int) {
        self.itemLabel.text = title;
        self.iconImageView.image = UIImage(named: icon);
        self.countLabel.text = String.init(format: "%d", count);
    }

}

private class ProfileSelfUncountableCell: UITableViewCell {

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView;
    }()

    private lazy var itemLabel: UILabel = {
        let label = UILabel();
        label.font = fontSystem14Bold
        label.textColor = CL_BLACK_GRACE;
        return label;
    }()


    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.backgroundColor = UIColor.white;
        self.contentView.addSubview(iconImageView);
        self.contentView.addSubview(itemLabel);
        self.addLayoutConstraints();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLayoutConstraints() {

        self.contentView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview();
            make.top.equalToSuperview();
            make.height.equalTo(kProfileSelfIconSize + 24);
        }

        self.iconImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kProfileSelfIconSize);
            make.height.equalTo(kProfileSelfIconSize);
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(kProfileSelfLeftSpacing);
        }

        self.itemLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kScreenW - kProfileSelfIconSize);
            make.height.equalTo(18);
            make.centerY.equalTo(self.iconImageView)
            make.left.equalTo(self.iconImageView.snp.right).offset(kProfileSelfLeftSpacing);
        }
    }

    func bindData(_ title: String, withIcon icon: String) {
        self.itemLabel.text = title;
        self.iconImageView.image = UIImage(named: icon);
    }

}

