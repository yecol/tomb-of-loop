//
//  NotificationsController.swift
//  loop
//
//  Created by Yecol Hsu on 31/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit

//import RealmSwift

let kTextCell = "kTextCell";
let kFriendRequestCell = "kFriendRequestCell";

class NotificationsController: UITableViewController, FriendRequestDelegate {

//    var dataSource:Results<LPNotification>!;
    var dataSource = NSMutableArray()
    
    var datasourceRequesting = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(LPDefaultCell.self, forCellReuseIdentifier: kTextCell);
        self.tableView.register(NotificationFriendRequestCell.self, forCellReuseIdentifier: kFriendRequestCell);
        self.title = "kTitle_Notifications".localized
        self.tableView.backgroundColor = CL_GREY_BG_EC;
        self.tableView.allowsSelection = false;

        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
        refresh();
    }

    func refresh() {
        
        if(self.datasourceRequesting){
            return;
        }
        
        self.datasourceRequesting = true;
        self.showLoadingProgress();

        DataModelManager.sharedInstance.cloudGetNotificationList(block: {
            (notifications: Array<Any>?, error: Error?) in
            self.datasourceRequesting = false;
            self.hideProgress();
            if (self.filterError(error)) {
                print("all notifications = ", notifications ?? "no notification")
                self.dataSource = NSMutableArray.init(array: notifications!)
                self.tableView.dataSource = self;
                self.tableView.reloadData();
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 12;
        } else {
            return 6;
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6;
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSource.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let notification = self.dataSource.object(at: indexPath.row) as! LPNotification;

        if (notification.type == kNotificationTypeFriendship) {
            if (notification.relationCodeWithFromUser == UserRelationFriend) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kTextCell, for: indexPath) as! LPDefaultCell;
                let fromUser = notification.from;
                let content = String.init(format: "kNotificationNowFriends_Holder".localized, fromUser.displayName());
                cell.bindData(content as String, withAvatar: fromUser.avatar?.url ?? "")
                return cell;
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: kFriendRequestCell, for: indexPath) as!
                NotificationFriendRequestCell
                cell.delegate = self;
                cell.indexPath = indexPath;
                let fromUser = notification.from;
                cell.setup(fromUser.displayName() as String, withAvatar: fromUser.avatar?.url ?? "")
                return cell;
            }
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: kTextCell, for: indexPath);
        return cell
    }

    func processFriendAccept(indexPath: IndexPath) {
        let notification = self.dataSource.object(at: indexPath.row) as! LPNotification;
        let fromUser = notification.from;
        let rel = DataModelManager.sharedInstance.cloudUpdateUserRelation(fromUser.objectId!,
                curRelation: notification.relationCodeWithFromUser);
        notification.relationCodeWithFromUser = rel;
        self.dataSource.replaceObject(at: indexPath.row, with: notification);
        self.tableView.reloadRows(at: [indexPath], with: .none);
    }


    func processFriendIgnore(indexPath: IndexPath) {
    }

}

fileprivate let kNotificationOperationBtnWidth: CGFloat = 80;
fileprivate let kNotificationOperationBtnHeight: CGFloat = 25;

protocol FriendRequestDelegate: class {
    func processFriendAccept(indexPath: IndexPath);

    func processFriendIgnore(indexPath: IndexPath);
}

class NotificationFriendRequestCell: UITableViewCell {

    weak var delegate: FriendRequestDelegate?;
    var indexPath: IndexPath?

    private lazy var avatarImageView: UIImageView = {
        let frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.asAvatar(size: 48)
        return imageView
    }()


    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = fontSystem14
        label.textColor = CL_BLACK_GRACE
        return label;
    }()

    private lazy var acceptBtn: UIButton = { [unowned self] in
        let btn = UIButton.init(type: .custom);
        btn.setTitle("kButton_Notification_FriendAccept_Normal".localized, for: .normal)
        btn.addTarget(self, action: #selector(self.acceptBtnPressed), for: .touchUpInside)
        btn.setLoopBtnGreenBackgrounded(font: fontSystem12Bold);
        return btn;
    }()

    private lazy var declineBtn: UIButton = { [unowned self] in
        let btn = UIButton.init(type: .custom);
        btn.setTitle("kButton_Notification_FriendIgnore_Normal".localized, for: .normal)
        btn.addTarget(self, action: #selector(self.ignoreBtnPressed), for: .touchUpInside)
        btn.setLoopBtnGreenFramed(font: fontSystem12Bold)
        return btn;
    }()

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.contentView.backgroundColor = UIColor.clear;
        self.selectionStyle = .default;

        self.imageView!.contentMode = .scaleAspectFill
        self.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0);

        self.contentView.addSubview(avatarImageView);
        self.contentView.addSubview(detailLabel);
        self.contentView.addSubview(acceptBtn);
        self.contentView.addSubview(declineBtn);

        self.addLayoutConstraints();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func addLayoutConstraints() {


        self.avatarImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(kProfileSelfLeftSpacing)
            make.left.equalToSuperview().offset(kProfileSelfLeftSpacing)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }

        self.detailLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(5);
            make.left.equalTo(self.avatarImageView.snp.right).offset(kProfileSelfLeftSpacing);
            make.width.equalToSuperview().offset(-3 * kProfileSelfLeftSpacing - 48)
            make.height.equalTo(25);
        }

        self.acceptBtn.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kNotificationOperationBtnWidth)
            make.height.equalTo(kNotificationOperationBtnHeight);
            make.left.equalTo(self.detailLabel);
            make.top.equalTo(self.detailLabel.snp.bottom).offset(5);
        }

        self.declineBtn.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(self.acceptBtn)
            make.centerY.equalTo(self.acceptBtn);
            make.left.equalTo(self.acceptBtn.snp.right).offset(10);
        }

    }

    func setup(_ name: String, withAvatar avatar_url: String) {
        self.avatarImageView.sd_setImage(with: URL(string: avatar_url), placeholderImage: UIImage(named: "avatar-ph"));
        self.detailLabel.text = name + "kNotificationFriendRequest_Piece".localized;
    }

    func acceptBtnPressed() {
        self.delegate?.processFriendAccept(indexPath: self.indexPath!);
    }

    func ignoreBtnPressed() {
        self.delegate?.processFriendIgnore(indexPath: self.indexPath!)
    }

}
