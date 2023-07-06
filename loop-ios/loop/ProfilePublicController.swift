//
//  ProfilePublicController.swift
//  loop
//
//  Created by Yecol Hsu on 02/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit
import CarbonKit
import QuartzCore
import ETNavBarTransparent
import SwipeTableView
import MWPhotoBrowser

fileprivate let kHeaderHeight: CGFloat = 220.0;
fileprivate let kProfileInfoSectionHeight: CGFloat = 180.0;
fileprivate let kProfileSegmentalControl: CGFloat = 60.0;
fileprivate let kProfileAvatarSize: CGFloat = 80.0;

fileprivate let kNavigationBarAlphaDistance: CGFloat = 20.0;
fileprivate let kNavigationBarAppear: CGFloat = -220.0;

protocol ProfileScrollDelegate {
    func didScroll(_ offsetY: CGFloat);
}

class ProfilePublicController: UIViewController, SwipeTableViewDataSource, SwipeTableViewDelegate,
        UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, ProfileScrollDelegate,
        MWPhotoBrowserDelegate {

    var swipeTableView: SwipeTableView?
    var userId: String?;
    var user: AVUser?;
    var currentOffset: CGFloat = -500.0;
    var parentController: UIViewController?
    
//    override func didMove(toParentViewController parent: UIViewController?) {
//        if parent == nil {
//            if self.parentController != nil {
//                self.hidesBottomBarWhenPushed = true;
//            }
//        }
//    }

    private lazy var badgesView: ProfileBadgeView = { [unowned self] in
        let collection = ProfileBadgeView.init(frame: self.swipeTableView!.bounds)
        collection.backgroundColor = UIColor.white;
        collection.profileScrollDelegate = self;
        collection.viewUserId = self.userId!;
        return collection;
    }()

    private lazy var friendsView: ProfileFriendView = { [unowned self] in
        let tableView = ProfileFriendView.init(frame: self.swipeTableView!.bounds, style: .grouped);
        tableView.profileScrollDelegate = self;
        tableView.viewUserId = self.userId!;
        return tableView;
    }()

    private lazy var postView: ProfilePostView = { [unowned self] in
        let tableView = ProfilePostView.init(frame: self.swipeTableView!.bounds, style: .grouped);
        tableView.profileScrollDelegate = self;
        tableView.backgroundColor = CL_GREY_BG_EC
        tableView.viewUserId = self.userId!;
        return tableView;
    }()


    lazy var segmentBar: ProfileSegmentControl = { [unowned self] in
        let segmentControl = ProfileSegmentControl.init();
        segmentControl.st_size = CGSize.init(width: kScreenW, height: kProfileSegmentalControl);
        segmentControl.addSubviews();
        segmentControl.addTarget(self, action: #selector(self.changeSwipeViewIndex(seg:)), for: .valueChanged)
        return segmentControl;
    }()


    lazy var tableViewHeader: ProfileInfoView = { [unowned self] in
        let header = ProfileInfoView();
        header.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kHeaderHeight);
        header.addSubviews();
        header.layer.masksToBounds = false;
        return header;
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeTableView = SwipeTableView(frame: self.view.bounds);
        self.swipeTableView!.autoresizingMask = [.flexibleHeight, .flexibleWidth];
        self.swipeTableView!.delegate = self;
        self.swipeTableView!.dataSource = self;
        self.swipeTableView!.shouldAdjustContentSize = true;
        self.swipeTableView!.swipeHeaderView = self.tableViewHeader;
        self.swipeTableView!.swipeHeaderBar = self.segmentBar;
        self.swipeTableView!.swipeHeaderBarScrollDisabled = true;
        self.swipeTableView!.swipeHeaderTopInset = 64;
        self.view.backgroundColor = CL_GREY_BG_EC;
        self.view.addSubview(self.swipeTableView!);
        self.view.clipsToBounds = true;

        // edge gesture
//        self.swipeTableView!.contentView.panGestureRecognizer.require(toFail: self.screenEdgePanGestureRecognizer);
        
        let button = UIButton.init(type: .custom);
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
        button.setImage(UIImage(named:"profile-more"), for: .normal);
        button.addTarget(self, action: #selector(self.moreBtnPressed), for: UIControlEvents.touchUpInside);
        
        let moreButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = moreButton



        self.swipeTableView!.scrollToItem(at: 1, animated: false);

        // get the user detail is not presented
        if (user == nil) {
            DataModelManager.sharedInstance.cloudGetUserDetail(specific: self.userId!, block: { (object, error) in
                if (self.filterError(error)) {
                    self.user = (object as! AVUser);
                    self.tableViewHeader.bindData(user: self.user!)
                    let countArray = NSArray.init(arrayLiteral: self.user!.postCount, self.user!.badgeCount, self.user!.friendCount);
                    self.segmentBar.setNumberArray(with: countArray);

                    self.tableViewHeader.configFriendBtn(curRelation: self.user!.relationCode)
                }
            })
        }

        self.badgesView.refresh();
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navBarBgAlpha = 0
        self.navBarTintColor = .white
        UIApplication.shared.statusBarStyle = .default
        self.determineNavigationAppearance(self.currentOffset)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func didScroll(_ offsetY: CGFloat) {
        //navigationBar alpha
        self.currentOffset = offsetY;
        self.determineNavigationAppearance(offsetY)
    }

    func determineNavigationAppearance(_ offsetY: CGFloat) {
        if offsetY > (kNavigationBarAppear - kNavigationBarAlphaDistance) {
            var navAlpha = (offsetY - (kNavigationBarAppear - kNavigationBarAlphaDistance)) / kNavigationBarAlphaDistance
            if navAlpha > 1 {
                navAlpha = 1
            }
            navBarBgAlpha = navAlpha
            if navAlpha > 0.8 {
                if(self.user != nil){
                    self.title = self.user!.displayName() as String;
                }
                UIApplication.shared.statusBarStyle = .lightContent

            } else {
                self.title = "";
                UIApplication.shared.statusBarStyle = .default
            }
        } else {
            navBarBgAlpha = 0;
            self.title = "";
            UIApplication.shared.statusBarStyle = .default
        }
        setNeedsStatusBarAppearanceUpdate()
    }

//    func screenEdgePanGestureRecognizer() -> UIScreenEdgePanGestureRecognizer{
//        var screenEdgePanGestureRecognizer:UIScreenEdgePanGestureRecognizer = nil;
//        if (self.navigationController?.view.gestureRecognizers.count > 0) {
//            for recognizer in self.navigationController?.view.gestureRecognizers {
//                if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
//                    screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
//                    break;
//                }
//            }
//        }
//        return screenEdgePanGestureRecognizer;
//    }

    func cancelBtnPressed() {
        self.navigationController?.popViewController(animated: true);
    }

    func setSwipeTableHeader(barItem: UIBarButtonItem) {
        if (self.swipeTableView!.swipeHeaderView == nil) {
            self.swipeTableView!.swipeHeaderView = self.tableViewHeader;
            self.swipeTableView!.reloadData();
        }
    }

    func setSwipeTableBar(barItem: UIBarButtonItem) {
        if (self.swipeTableView!.swipeHeaderBar == nil) {
            self.swipeTableView!.swipeHeaderBar = self.segmentBar;
            self.swipeTableView!.scrollEnabled = true;
        }
    }

    func changeSwipeViewIndex(seg: UISegmentedControl) {
        self.swipeTableView?.scrollToItem(at: seg.selectedSegmentIndex, animated: true);
        self.getDataAtIndex(index: seg.selectedSegmentIndex);
    }


    // 请求数据（根据视图滚动到相应的index后再请求数据）
    func getDataAtIndex(index: Int) {
//        self.hideProgress();
        switch (index) {
        case 0:
            self.postView.refresh(type: .loadDefault); break;
        case 1:
            self.badgesView.refresh(); break;
        case 2:
            self.friendsView.refresh(type: .loadDefault); break;
        default:
            break;
        }
    }


    func numberOfItems(in swipeView: SwipeTableView!) -> Int {
        return 3
    }

    func swipeTableView(_ swipeView: SwipeTableView!, viewForItemAt index: Int, reusing view: UIScrollView!) -> UIScrollView! {
        switch index {
        case 0: return self.postView
        case 1: return self.badgesView
        default: return self.friendsView
        }
    }

    func swipeTableViewDidEndDecelerating(_ swipeView: SwipeTableView!) {
        self.getDataAtIndex(index: swipeView.currentItemIndex);
    }

    func swipeTableViewCurrentItemIndexDidChange(_ swipeView: SwipeTableView!) {
        self.segmentBar.setSelectedSegmentIndex(selectedSegmentIndex: swipeView.currentItemIndex)
    }


    /**
     *  以下两个代理，在未定义宏 #define ST_PULLTOREFRESH_HEADER_HEIGHT，并自定义下拉刷新的时候，必须实现
     *  如果设置了下拉刷新的宏，以下代理可根据需要实现即可
     */

    func swipeTableView(_ swipeTableView: SwipeTableView!, shouldPullToRefreshAt index: Int) -> Bool {
        return false;
    }

    func swipeTableView(_ swipeTableView: SwipeTableView!, heightForRefreshHeaderAt index: Int) -> CGFloat {
        return 0;
    }

    func presentAvatarPhoto() {

        let browser = MWPhotoBrowser.init(delegate: self)!
        browser.displayActionButton = false;
        browser.displayNavArrows = false;
        browser.displaySelectionButtons = false;
        browser.alwaysShowControls = false;
        browser.zoomPhotosToFill = true;
        browser.enableGrid = false;
        browser.startOnGrid = false;
        browser.autoPlayOnAppear = false;
        browser.enableSwipeToDismiss = true;

        let nc = UINavigationController.init(rootViewController: browser);
        browser.modalTransitionStyle = .crossDissolve
        self.present(nc, animated: true, completion: nil);
    }
    
    
    func moreBtnPressed(){
        
        if(self.user?.objectId == AVUser.current()?.objectId){
            self.showToast(with: "kToastNoMoreActions".localized);
            return;
        }
        
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        
        let cancelAction = UIAlertAction(title: "kCancel".localized, style: .cancel, handler: nil)
        let unfriendAction = UIAlertAction(title: "kAlertItem_UnFriend_User".localized, style: .default, handler: { action in
            self.tableViewHeader.friendBtnPressed();
        })
        let blockUserAction = UIAlertAction(title: "kAlertItem_Block_User".localized, style: UIAlertActionStyle.default, handler: {Void in
            DataModelManager.sharedInstance.cloudBlockUser(self.user!, block: { succeeded, error in
                if (self.filterError(error)) {
                    self.showToast(with: "kToastUserBlockedSuccess".localized);
                    self.user!.isBlocked = true;
                    self.tableViewHeader.configFriendBtn(curRelation: self.user!.relationCode);
                }
            })
        })
        
        let unblockUserAction = UIAlertAction(title: "kAlertItem_UnBlock_User".localized, style: UIAlertActionStyle.default, handler: {Void in
            DataModelManager.sharedInstance.cloudUnBlockUser(self.user!, block: { succeeded, error in
                if (self.filterError(error)) {
                    self.showToast(with: "kToastUserUnBlockedSuccess".localized);
                    self.user!.isBlocked = false;
                    self.tableViewHeader.configFriendBtn(curRelation: self.user!.relationCode)
                }
            })
        })
        
        alertSheet.addAction(cancelAction)
        if (self.user?.relationCode == UserRelationFriend){
            alertSheet.addAction(unfriendAction)
        }
        if (self.user != nil && self.user!.isBlocked == false){
            alertSheet.addAction(blockUserAction)
        }
        if (self.user != nil && self.user!.isBlocked == true){
            alertSheet.addAction(unblockUserAction)
        }
        
        self.present(alertSheet, animated: true, completion: nil);
    }

    public func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        return MWPhoto.init(url: URL.init(string: self.user!.avatar?.url ?? ""))!
    }

    public func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return 1;
    }

}

class ProfileInfoView: STHeaderView {

    lazy var headerImageView: UIImageView = {
        let imageView = UIImageView.init(image: UIImage(named: "profile-bg"));
        imageView.contentMode = .bottom;
        imageView.autoresizingMask = .flexibleHeight;
        return imageView
    }()

    private lazy var infoSection: UIView = { [unowned self] in
        let view = UIView();
        view.backgroundColor = UIColor.white;
        return view;
    }()

    private lazy var avatarImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView();
        imageView.asAvatar(size: kProfileAvatarSize);
        imageView.image = UIImage(named: "avatar-ph");
        return imageView;
    }()

    private lazy var nameLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textAlignment = .center;
        label.text = ""
        label.font = fontSystem18Bold;
        return label;
    }()

    private lazy var descriptionLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.numberOfLines = 0;
        label.text = ""
        label.textAlignment = .center;
        label.font = fontSystem14;
        return label;
    }()

    private lazy var locationLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textAlignment = .center;
        label.font = fontSystem14;
        label.text = ""
        return label;
    }()

    private lazy var friendBtn: UIButton = { [unowned self] in
        let button = UIButton(type: .custom);
        button.addTarget(self, action: #selector(self.friendBtnPressed), for: .touchUpInside);
        return button;
    }()

    func addSubviews() {
        self.addSubview(headerImageView);
        self.addSubview(infoSection);
        self.addSubview(avatarImageView);
        self.addSubview(nameLabel)
        self.addSubview(friendBtn)
        self.addSubview(descriptionLabel);
        self.addSubview(locationLabel);
        self.addLayoutConstraints();
    }

    func bindData(user: AVUser) {
        let avatarUrl = URL(string: user.avatar?.url ?? "");
        self.avatarImageView.sd_setImage(with: avatarUrl, placeholderImage: UIImage(named: "avatar-ph"));
        self.nameLabel.text = user.displayName() as String
        self.descriptionLabel.text = user.introduction;
        self.locationLabel.text = user.city
    }

    private func addLayoutConstraints() {
        self.headerImageView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview();
            make.top.equalToSuperview()
            make.size.equalToSuperview();
        }

        self.infoSection.snp.makeConstraints { (make) -> Void in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(kScreenW)
            make.height.equalTo(kProfileInfoSectionHeight)
        }

        self.avatarImageView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.infoSection.snp.top);
            make.centerX.equalToSuperview();
            make.width.equalTo(kProfileAvatarSize)
            make.height.equalTo(kProfileAvatarSize)
        }

        self.nameLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(8);
            make.width.equalTo(kScreenW * 0.8)
            make.height.equalTo(22)
        }

        self.friendBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview();
            make.top.equalTo(self.nameLabel.snp.bottom).offset(8);
            make.width.equalTo(110)
            make.height.equalTo(26)
        }

        self.descriptionLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview();
            make.top.equalTo(self.friendBtn.snp.bottom).offset(6);
            make.width.equalTo(kScreenW * 0.8)
            make.height.equalTo(20)
        }

        self.locationLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview();
            make.top.equalTo(self.descriptionLabel.snp.bottom);
            make.width.equalTo(kScreenW * 0.8)
            make.height.equalTo(20)
        }
    }


    func friendBtnPressed() {
        let user = (self.viewController() as! ProfilePublicController).user!
        let oldRel = user.relationCode;


        let friendActionHandler = { (action: UIAlertAction!) -> Void in
            self.viewController()!.showProgress();
            let newRel = DataModelManager.sharedInstance.cloudUpdateUserRelation(user.objectId!,
                    curRelation: user.relationCode);
            (self.viewController() as! ProfilePublicController).user!.relationCode = newRel;
            self.configFriendBtn(curRelation: newRel)
            self.viewController()!.hideProgress();
            self.viewController()!.showToast(with: "kAlert_ConfirmUnFriend".localized);
        }


        switch oldRel {
        case UserRelationFriend:
            let alertController = UIAlertController(title: "kAlertConfirmationTitle".localized, message: "", preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "kCancel".localized, style: .cancel, handler: nil)
            let yesAction = UIAlertAction(title: "kConfirm".localized, style: .default, handler: friendActionHandler);
            alertController.addAction(cancelAction);
            alertController.addAction(yesAction);
            self.viewController()!.present(alertController, animated: true)
            break;
        default:
//            self.viewController()!.showProgress();
            let newRel = DataModelManager.sharedInstance.cloudUpdateUserRelation(user.objectId!,
                    curRelation: user.relationCode);
            (self.viewController() as! ProfilePublicController).user!.relationCode = newRel;
            self.configFriendBtn(curRelation: newRel)
//            self.viewController()!.hideProgress();
            self.viewController()!.showToast(with: "kToastFriendshipUpdatedSuccess".localized);
            break;
        }

    }



    func configFriendBtn(curRelation: Int) {

        if ((self.viewController() as! ProfilePublicController).user!.objectId! == AVUser.current()?.objectId) {
            self.friendBtn.isEnabled = false;
            self.friendBtn.setTitle("kButton_Profile_Friend_Yourself".localized, for: UIControlState());
            self.friendBtn.layer.borderColor = UIColor.clear.cgColor
            self.friendBtn.setTitleColor(CL_GREEN_DEFAULT, for: .disabled)
            self.friendBtn.titleLabel?.font = fontSystem12;
        }
            
        else if ((self.viewController() as! ProfilePublicController).user!.isBlocked == true) {
            self.friendBtn.isEnabled = false;
            self.friendBtn.setTitle("kButton_Profile_Friend_Blocked".localized, for: .disabled);
            self.friendBtn.setLoopBtnGreenFramed(font: fontSystem12Bold);
            self.friendBtn.layer.borderColor = CL_GREY_BG_EC.cgColor;
            self.friendBtn.setTitleColor(CL_GREY_BG_EC, for: .disabled)
        }

        else if (curRelation == UserRelationFriend) {
            //display unfriend
            self.friendBtn.isEnabled = false;
            self.friendBtn.setTitle("kButton_Profile_Friend_Friends".localized, for: .disabled);
            self.friendBtn.layer.borderColor = UIColor.clear.cgColor
            self.friendBtn.setTitleColor(CL_GREEN_DEFAULT, for: .disabled)
            self.friendBtn.titleLabel?.font = fontSystem12;
        }
        else if (curRelation == UserRelationStranger || curRelation == UserRelationFollower) {
            self.friendBtn.isEnabled = true;
            self.friendBtn.setTitle("kButton_Profile_Friend_AddFriend".localized, for: UIControlState());
            self.friendBtn.setLoopBtnGreenFramed(font: fontSystem12Bold);
        } else if (curRelation == UserRelationFollowee) {
            self.friendBtn.isEnabled = false;
            self.friendBtn.setTitle("kButton_Profile_Friend_Requested".localized, for: .disabled);
            self.friendBtn.setLoopBtnGreenFramed(font: fontSystem12Bold);
            self.friendBtn.layer.borderColor = CL_GREY_BG_EC.cgColor;
            self.friendBtn.setTitleColor(CL_GREY_BG_EC, for: .disabled)
        }

    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            if (self.avatarImageView.frame.contains(point)) {
//                self..presentPhotoPicker(index: imageview.tag);
//                self.viewController.presentAvatarPhoto();
                (self.viewController()! as! ProfilePublicController).presentAvatarPhoto();
            }
        }
    }

}

class ProfileSegmentControl: UIControl {

    let items = ["Posts", "Badges", "Friends"]
    var numbers = ["0", "0", "0"]
    var selectedSegmentIndex = 1;

    lazy var contentView: UIView = {
        let view = UIView();
        view.backgroundColor = UIColor.white;
        return view;
    }()

    func setNumberArray(with array: NSArray) {
        numbers.removeAll();
        for count in array {
            numbers.append(String(format: "%d", count as! Int));
        }
        self.setNeedsLayout();
    }

    private lazy var tabPostLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_GREY_FONT;
        label.text = "kProfileTabPosts".localized;
        label.font = fontMontserrat12;
        label.textAlignment = .center;
        return label;
    }()

    private lazy var tabBadgeLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_GREY_FONT;
        label.text = "kProfileTabBadges".localized;
        label.font = fontMontserrat12;
        label.textAlignment = .center;
        return label;
    }()

    private lazy var tabFriendsLabel: UILabel = { [unowned self] in
        let label = UILabel();
        label.textColor = CL_GREY_FONT;
        label.text = "kProfileTabFriends".localized;
        label.font = fontMontserrat12;
        label.textAlignment = .center;
        return label;
    }()

    private lazy var tabBtmBorder: UIView = { [unowned self] in
        let view = UIView();
        view.backgroundColor = CL_GREY_BORDER_6C;
        return view;
    }()

    func addSubviews() {
        self.addSubview(contentView);
        self.addSubview(tabPostLabel)
        self.addSubview(tabBadgeLabel)
        self.addSubview(tabFriendsLabel)
        self.addSubview(tabBtmBorder);
        self.selectedSegmentIndex = 1;
        self.addLayoutConstraints();
    }


    override func layoutSubviews() {
        super.layoutSubviews();

        for view in contentView.subviews {
            view.removeFromSuperview();
        }

        self.contentView.frame = self.bounds;

        for i in 0...self.items.count - 1 {
            let itemBtn = UIButton.init(type: .custom);
            itemBtn.tag = 666 + i;
            itemBtn.isUserInteractionEnabled = true
            itemBtn.setTitle(self.numbers[i], for: .normal);
            itemBtn.setTitleColor(CL_BLACK_GRACE, for: .normal);
            itemBtn.setTitleColor(CL_GREEN_DEFAULT, for: .selected);
            itemBtn.titleLabel?.font = fontMontserrat24;
            let btnWidth = kScreenW / CGFloat(self.items.count)
            itemBtn.st_size = CGSize.init(width: btnWidth, height: self.st_height);
            itemBtn.st_x = btnWidth * CGFloat(i);
            itemBtn.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0)
            if (i == self.selectedSegmentIndex) {
                itemBtn.isSelected = true;
                self.setLabelSelectedColor(self.selectedSegmentIndex);
            } else {
                itemBtn.isSelected = false;
            }
            itemBtn.addTarget(self, action: #selector(self.didSelectedSegment(sender:)), for: .touchUpInside);
            self.contentView.addSubview(itemBtn);
        }

    }

    func didSelectedSegment(sender: UIButton) {
        let oldBtn = self.contentView.viewWithTag(666 + self.selectedSegmentIndex) as! UIButton;
        oldBtn.isSelected = false;
        self.setLabelNormalColor(self.selectedSegmentIndex)

        sender.isSelected = true;
        self.selectedSegmentIndex = sender.tag - 666;
        self.setLabelSelectedColor(self.selectedSegmentIndex)
        self.sendActions(for: .valueChanged)
    }


    func setSelectedSegmentIndex(selectedSegmentIndex: NSInteger) {
        let oldBtn = self.contentView.viewWithTag(666 + self.selectedSegmentIndex) as! UIButton;
        oldBtn.isSelected = false;
        self.setLabelNormalColor(self.selectedSegmentIndex);

        let newBtn = self.contentView.viewWithTag(666 + selectedSegmentIndex) as! UIButton;
        newBtn.isSelected = true;
        self.setLabelSelectedColor(selectedSegmentIndex)

        self.selectedSegmentIndex = selectedSegmentIndex;
    }

    func setLabelNormalColor(_ index: Int) {
        switch index {
        case 0: self.tabPostLabel.textColor = CL_GREY_FONT; break;
        case 1: self.tabBadgeLabel.textColor = CL_GREY_FONT; break;
        default: self.tabFriendsLabel.textColor = CL_GREY_FONT; break;
        }
    }

    func setLabelSelectedColor(_ index: Int) {
        switch index {
        case 0: self.tabPostLabel.textColor = CL_GREEN_DEFAULT; break;
        case 1: self.tabBadgeLabel.textColor = CL_GREEN_DEFAULT; break;
        default: self.tabFriendsLabel.textColor = CL_GREEN_DEFAULT; break;
        }
    }

    func addLayoutConstraints() {

        self.tabPostLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(5);
            make.width.equalTo(kScreenW / 3)
            make.height.equalTo(20)
        }

        self.tabBadgeLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(5);
            make.width.equalTo(kScreenW / 3)
            make.height.equalTo(20)
        }

        self.tabFriendsLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(5);
            make.width.equalTo(kScreenW / 3)
            make.height.equalTo(20)
        }

        self.tabBtmBorder.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView.snp.bottom).offset(-1)
            make.centerX.equalToSuperview()
            make.width.equalTo(kScreenW)
            make.height.equalTo(1)
        }
    }
}




