//
//  BadgeController.swift
//  loop
//
//  Created by Yecol Hsu on 01/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import ETNavBarTransparent

let kBadgeHeaderCellIdentifier = "kBadgeHeaderCellIdentifier";
let kBadgeGridCellIdentifier = "kBadgeGridCellIdentifier";
let kSectionTitleCellIdentifier = "kSectionTitleCellIdentifier";
let kSectionTextCellIdentifier = "kSectionTextCellIdentifier";

fileprivate let kPostCardCollection = "kPostCardCollection";
fileprivate let kTableTag = 19283;
let kPostCardCell = "kPostCardCell";

class BadgeController: UITableViewController, BadgeHeaderDelegate, UICollectionViewDelegate,
        UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var badge: LPBadge?;
    var ownerSectionIndex = -1;
    var postsSectionIndex = -1;

    var currentAlpha: CGFloat = 0.0;


    required init(badge: LPBadge) {
        super.init(style: .grouped)
        self.badge = badge;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = CL_GREY_BG_EC;
        self.tableView.backgroundColor = CL_GREY_BG_EC;
        self.automaticallyAdjustsScrollViewInsets = false;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        self.tableView.tag = kTableTag;
        self.refreshWithDetailedInfo();

        self.tableView.register(SectionTitleCell.self, forCellReuseIdentifier: kSectionTitleCellIdentifier)

        self.navBarBgAlpha = 0
        self.navBarTintColor = .white
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func refreshWithDetailedInfo() {

        DataModelManager.sharedInstance.cloudGetBadgeDetail(self.badge!.objectId!, block: { (object, error) in
            if (self.filterError(error)) {
//                print("get badge = ", object!);
                self.badge = (object as! LPBadge);
                self.tableView.reloadData();
            }
        })
    }

    func setShareable() {
        let button = UIButton.init(type: .custom);
        button.frame = CGRect(x: 0, y: 0, width: 19, height: 22);
        button.setImage(UIImage(named: "share-icon"), for: UIControlState());
        button.addTarget(self, action: #selector(self.shareBtnPressed), for: UIControlEvents.touchUpInside);
        let anotherButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = anotherButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        var num = 3;
        // header + infobox + intro;

        if (self.badge!.postList.count > 0) {
            postsSectionIndex = 3;
            num += 1;
        }

        if (self.badge!.ownerList.count > 0) {
            if (postsSectionIndex == -1) {
                ownerSectionIndex = 3;
            } else {
                ownerSectionIndex = 4;
            }
            num += 1;
        }
        return num;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 2) {
            return 2;
        } else if (section == ownerSectionIndex) {
            return self.badge!.ownerList.count + 1;
        } else if (section == postsSectionIndex) {
            return 1;
        } else {
            return 1;
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return CGFloat.leastNormalMagnitude;
        } else {
            return FL_SEPARATOR_HEIGHT / 2;
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FL_SEPARATOR_HEIGHT / 2;
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return kBadgeHeaderCellHeight + self.badge!.tagline.height(withConstrainedWidth: kScreenW - 2 * kSectionSpacing, font: fontSystem14) + kSectionSpacing;

//                BadgeController.calculateCellHeightWith(self.badge!.tagline as NSString, width: kScreenW - 2 * kSectionSpacing) + kSectionSpacing;
        } else if (indexPath.section == 1) {
            if (self.badge!.owned == false) {
                return kBadgeInfoboxHeight;
            } else {
                return kBadgeInfoboxHeight * 2;
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                return kSectionTitleHeight;
            } else {
                return (badge!.definition ?? "").height(withConstrainedWidth: kScreenW - 2 * kSectionSpacing, font: fontSystem14) + kSectionSpacing * 1.5;
            }
        } else if (indexPath.section == ownerSectionIndex) {
            if (indexPath.row == 0) {
                return kSectionTitleHeight;
            } else {
                return kFriendListCellHeight;
            }
        } else if (indexPath.section == postsSectionIndex) {
            return 360;

        } else {
            return 0;
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.section == 0) {
            var cell = tableView.dequeueReusableCell(withIdentifier: kBadgeHeaderCellIdentifier) as! BadgeHeaderCell?;
            if (cell == nil) {
                cell = BadgeHeaderCell(style: .default, reuseIdentifier: kBadgeHeaderCellIdentifier);

            }
//            print("badge = ", self.badge!)
            cell!.bindData(self.badge!);
            cell!.delegate = self;
            return cell!;
        }

        if (indexPath.section == 1) {
            var cell = tableView.dequeueReusableCell(withIdentifier: kBadgeGridCellIdentifier) as! BadgeInfoCell?;
            if (cell == nil) {
                cell = BadgeInfoCell(style: .default, reuseIdentifier: kBadgeGridCellIdentifier);
            }

            if (self.badge!.owned == false) {
                cell!.setupBox(.badgeProfileOther);
            } else {
                cell!.setupBox(.badgeProfileSelf);
                self.setShareable();
            }

            cell!.bindData(self.badge!);
            return cell!;
        }

        if (indexPath.section == 2) {

            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kSectionTitleCellIdentifier, for: indexPath)
                as! SectionTitleCell;
                cell.bindData("kSectionTitle_BadgeDetail_Desc".localized);
                return cell;
            } else {
                var cell = tableView.dequeueReusableCell(withIdentifier: kSectionTextCellIdentifier) as! SectionTextCell?;
                if (cell == nil) {
                    cell = SectionTextCell(style: .default, reuseIdentifier: kSectionTextCellIdentifier);
                }
                cell!.setContent(self.badge!.definition ?? "");
                return cell!;
            }

        }

        if (indexPath.section == postsSectionIndex) {


            var cell = tableView.dequeueReusableCell(withIdentifier: kPostCardCollection) as! PostCardCollectionCell?;

            if (cell == nil) {
                cell = PostCardCollectionCell(style: .default, reuseIdentifier: kPostCardCollection) as PostCardCollectionCell;
            }

            cell!.setCollectionViewDataSourceDelegate(self, forSection: indexPath.section)
            return cell!


        }

        if (indexPath.section == ownerSectionIndex) {

            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kSectionTitleCellIdentifier, for: indexPath)
                as! SectionTitleCell;
                cell.bindData("kSectionTitle_BadgeDetail_Owners".localized);
                return cell;
            } else {

                var cell = tableView.dequeueReusableCell(withIdentifier: kFriendCellIdentifier) as! FriendCell?;

                if (cell == nil) {
                    cell = FriendCell(style: .subtitle, reuseIdentifier: kFriendCellIdentifier) as FriendCell;
                }

                let friend = self.badge!.ownerList.object(at: indexPath.row - 1) as! AVUser;
                let details = String(format: "kFriendItemDetail_Holder".localized, friend.postCount, friend.badgeCount, friend.friendCount);

                cell!.bindData(friend.displayName(), avatar: (friend.avatar?.url ?? ""), detail: details)
                return cell!
            }

        }

        var cell = tableView.dequeueReusableCell(withIdentifier: kBadgeHeaderCellIdentifier)

        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: kBadgeHeaderCellIdentifier);
        }
        return cell!
    }

    func shareBtnPressed() {
        let shareController = ShareController();

        let imageToShare = self.prepareImageToShare();
//        UIImageWriteToSavedPhotosAlbum(imageToShare, nil, nil, nil);
        shareController.shareSheet = imageToShare;
        shareController.modalPresentationStyle = .overCurrentContext
        self.tabBarController!.present(shareController, animated: true, completion: nil);
    }

    func badgeFavouriteBtnPressed() {
        DataModelManager.sharedInstance.cloudFlipBadgeFavoriteState(self.badge!, block: { succeeded, error in
            if (self.filterError(error)) {
                self.showToast(with: "kToastUpdateBadgeLikeSuccess".localized)
            }
        })
    }


    //delegation methods for collections.
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.badge!.postList.count;
    }


    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPostCardCell, for: indexPath) as! PostCardCell
        cell.setData(self.badge!.postList.object(at: indexPath.row) as! LPPost)
//        cell.adjustUI();
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postCommentController = PostCommentController(postID: (self.badge!.postList.object(at: indexPath.row) as! LPPost).objectId!)
        postCommentController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(postCommentController, animated: true)

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == ownerSectionIndex) {
            if (indexPath.row > 0) {
                let friend = self.badge!.ownerList.object(at: indexPath.row - 1) as! AVUser
                let profileController = ProfilePublicController();
                profileController.userId = friend.objectId!;
                self.navigationController!.pushViewController(profileController, animated: true);
            }
        }
        tableView.deselectRow(at: indexPath, animated: true);
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if (scrollView.tag == kTableTag) {

            let contentOffsetY = scrollView.contentOffset.y
            let showNavBarOffsetY = kBadgeHeaderCellHeight - topLayoutGuide.length

            //navigationBar alpha
            if contentOffsetY > showNavBarOffsetY {
                var navAlpha = (contentOffsetY - (showNavBarOffsetY)) / 40.0
                if navAlpha > 1 {
                    navAlpha = 1
                }
                navBarBgAlpha = navAlpha
                if navAlpha > 0.8 {
                    self.title = self.badge!.name;
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
    }


    private func prepareImageToShare() -> UIImage {
        let bgImageWidth = 541.0;
        let bgImageHeight = 385.0;

        let badgeImageSize = 200.0;

        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: bgImageWidth, height: bgImageHeight));
        let bgImageView = UIImageView.init(image: UIImage(named: "sharesheet-bg"));
        bgImageView.frame = CGRect.init(x: 0, y: 0, width: bgImageWidth, height: bgImageHeight);
        bgImageView.contentMode = .scaleAspectFill;

        let badgeImageView = UIImageView();
        badgeImageView.sd_setImage(with: URL.init(string: self.badge!.icon!.url!));
        badgeImageView.frame = CGRect.init(x: (bgImageWidth - badgeImageSize) / 2, y: 40, width: badgeImageSize, height:
        badgeImageSize);
        badgeImageView.contentMode = .scaleAspectFill;

        let descriptionLabel = UILabel();
        descriptionLabel.frame = CGRect.init(x: 22, y: 296, width: 300, height: 30)
        descriptionLabel.text = (AVUser.current()!.displayName() as String) + "kShareSheetDesc_Piece".localized;
        descriptionLabel.font = fontHelveticaNeueThin18;

        let badgeName = UILabel();
        badgeName.frame = CGRect.init(x: 22, y: 320, width: 300, height: 60)
        badgeName.text = self.badge!.name;
        badgeName.font = fontHelveticaNeueThin36;
        badgeName.textColor = CL_GREEN_DEFAULT;

        view.addSubview(bgImageView);
        view.addSubview(badgeImageView);
        view.addSubview(descriptionLabel);
        view.addSubview(badgeName);

        return view.screenShot!;
//        return UIImage.init(view: view);
    }


//    class func calculateCellHeightWith(_ content: NSString, width: CGFloat) -> CGFloat {
//
//        let paragraph = NSMutableParagraphStyle();
//        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
//
//        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
//
//        return ceil(content.boundingRect(with:
//        CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
//                options: options, attributes: [NSFontAttributeName: fontSystem14,
//                                               NSParagraphStyleAttributeName: paragraph],
//                context: nil).size.height)+100;
//    }
}


class SectionTextCell: UITableViewCell {

    private lazy var contentLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = fontSystem14
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping;
        label.textColor = CL_BLACK_GRACE;
        label.font = fontSystem14;
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.selectionStyle = .none;
        self.contentView.addSubview(self.contentLabel)
        self.addLayoutConstraints();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setContent(_ content: String) {
        self.contentLabel.text = content;
    }

    private func addLayoutConstraints() {
        self.contentLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(kSectionSpacing * 0.5);
            make.width.equalToSuperview().offset(-kSectionSpacing * 2);
            make.left.equalToSuperview().offset(kSectionSpacing);
        }
    }

}


let kBadgeHeaderCellHeight: CGFloat = 300 + 60;
let kBadgeHeaderImageHeight: CGFloat = 300;
let kBadgeHeaderTitleHeight: CGFloat = 60;
let kBadgeHeaderBadgeSize: CGFloat = 180;
fileprivate let kBadgeDetailLightSize = 300;

protocol BadgeHeaderDelegate: class {
    func badgeFavouriteBtnPressed();
}

class BadgeHeaderCell: UITableViewCell, FaveButtonDelegate {

//    var badgeTitle: UILabel?
//    var favButton: FaveButton?
    var delegate: BadgeHeaderDelegate?

    private lazy var bgImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView;
    }()


    private lazy var bgLightImage1: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        imageView.image = UIImage.init(named: "badge-light-1");
        imageView.clipsToBounds = true
        return imageView;
    }()

    private lazy var bgLightImage2: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        imageView.image = UIImage.init(named: "badge-light-2");
        imageView.clipsToBounds = true
        return imageView;
    }()

    private lazy var badgeImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView;
    }()

    private lazy var badgeTitle: UILabel = {
        let label = UILabel(frame: CGRect.null);
        label.numberOfLines = 1;
        label.font = fontHelveticaNeueThin36;
        label.textColor = CL_BLACK_GRACE;
        label.textAlignment = .center;
        return label;
    }()

    private lazy var badgeTagLine: UILabel = {
        let label = UILabel(frame: CGRect.null);
        label.numberOfLines = 0;
        label.font = fontSystem14;
        label.textColor = CL_BLACK_GRACE;
        label.textAlignment = .center;
        return label;
    }()

    private lazy var favButton: FaveButton = { [unowned self] in
        let button = FaveButton(
                frame: CGRect(x: 100, y: 100, width: 36, height: 32),
                faveIconNormal: UIImage(named: "badge-liked")
        )
        button.selectedColor = CL_BADGE_LIKE_SELECT;
        button.normalColor = CL_GREY_BG_EC;
        button.delegate = self
        return button
    }()


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.selectionStyle = .none;
        self.setup();
    }

    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder);
        self.selectionStyle = .none;
        self.setup();
    }

    func setup() {

        self.contentView.addSubview(self.bgImageView);
        self.contentView.addSubview(self.bgLightImage1);
        self.contentView.addSubview(self.bgLightImage2);
        self.contentView.addSubview(self.badgeImageView);
        self.contentView.addSubview(self.badgeTitle)
        self.contentView.addSubview(self.favButton)
        self.contentView.addSubview(self.badgeTagLine)

        self.addLayoutConstraints();


    }

    func bindData(_ badge: LPBadge) {
        self.badgeTitle.text = badge.name!;
        self.badgeTagLine.text = badge.tagline;
        self.badgeImageView.sd_setImage(with: URL.init(string: badge.icon!.url!), placeholderImage: UIImage(named: "badge-ph"));
        self.favButton.setSelected(selected: badge.hasFavorited, animation: false)
        if (badge.background != nil) {
            self.bgImageView.sd_setImage(with: URL.init(string: badge.background!.url!))
        }

        self.bgLightImage1.startZRotation(duration: 40, clockwise: true);
        self.bgLightImage2.startZRotation(duration: 40, clockwise: false);
    }

    private func addLayoutConstraints() {

        self.bgImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview();
            make.height.equalTo(kBadgeHeaderImageHeight);
            make.top.equalToSuperview();
            make.centerX.equalToSuperview();
        }

        self.bgLightImage1.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kBadgeDetailLightSize);
            make.height.equalTo(kBadgeDetailLightSize);
            make.center.equalTo(self.bgImageView)
        }

        self.bgLightImage2.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kBadgeDetailLightSize);
            make.height.equalTo(kBadgeDetailLightSize);
            make.center.equalTo(self.bgImageView)
        }

        self.badgeImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(kBadgeHeaderBadgeSize)
            make.height.equalTo(kBadgeHeaderBadgeSize);
            make.center.equalTo(self.bgImageView)
        }

        self.badgeTitle.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview();
            make.height.equalTo(kBadgeHeaderTitleHeight);
            make.top.equalTo(self.bgImageView.snp.bottom)
            make.centerX.equalToSuperview();
        }

        self.badgeTagLine.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview().offset(-2 * kSectionSpacing);
            make.top.equalTo(self.badgeTitle.snp.bottom).offset(2)
            make.centerX.equalToSuperview();
        }

        self.favButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(44);
            make.height.equalTo(44);
            make.right.equalTo(kScreenW).offset(-12);
            make.centerY.equalTo(self.badgeTitle);
        }
    }

    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        if (selected == true) {
//            print("now selected");
        } else if (selected == false) {
//            print("now deselect.");
        }
        self.delegate?.badgeFavouriteBtnPressed();
    }

    func faveButton(_ faveButton: FaveButton, didSelectedAndBeforeAnimation selected: Bool) {

    }
}

let kSectionSpacing: CGFloat = 12;
let kSectionTitleHeight: CGFloat = 28;

class SectionTitleCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        let label = UILabel();
        label.textColor = CL_GREY_FONT;
        label.font = fontMontserrat12;
        return label;
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier);
        self.selectionStyle = .none;
        self.contentView.addSubview(titleLabel);
        self.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        self.addLayoutConstraints();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLayoutConstraints() {
        self.contentView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalToSuperview();
        }
        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(kSectionSpacing);
            make.left.equalToSuperview().offset(kSectionSpacing);
            make.height.equalTo(15);
            make.width.equalToSuperview().offset(-kSectionSpacing);
        }
    }

    func bindData(_ title: String) {
        self.titleLabel.text = title;
    }
}

