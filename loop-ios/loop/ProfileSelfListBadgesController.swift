//
//  ProfileSelfBadgesListController.swift
//  loop
//
//  Created by Yecol Hsu on 25/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

let kNumBadgesPerRow: CGFloat = 3.0;

class ProfileSelfListBadgesController: UICollectionViewController,
        UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {


    //for usual use.
    var dataSource = NSMutableArray();
    var badgeRequestType = BadgeRequestTypeSpecific;
    
    var datasourceIsEmpty = false;
    var datasourceRequesting = false;

    override func viewDidLoad() {
        super.viewDidLoad()

        if (badgeRequestType == BadgeRequestTypeFavourited) {
            self.title = "kTitle_MyFavouriteBadges".localized
        } else {
            self.title = "kTitle_MyBadges".localized;
        }


        // Register cell classes
        self.collectionView!.backgroundColor = UIColor.white;
        self.collectionView!.register(ABadgeCell.self, forCellWithReuseIdentifier: kABadgeCell)

        self.collectionView!.emptyDataSetSource = self;
        self.collectionView!.emptyDataSetDelegate = self;

        // A little trick for removing the cell separators
        self.navBarBgAlpha = 1
        self.navBarTintColor = .white

        self.refresh();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setBadgeRequestType(type: Int) {
        self.badgeRequestType = type;
    }

    func refresh() {
        if(self.datasourceRequesting == true){
            return;
        }
        self.datasourceRequesting = true;
        self.showLoadingProgress()
        DataModelManager.sharedInstance.cloudGetBadgeList(self.badgeRequestType, limit: kGetAllInOnePage,
                skip: 0, specific: AVUser.current()!.objectId!,
                block: { (badges: Array<Any>?, error: Error?) in
                    self.datasourceRequesting = false;
                    self.hideProgress()
                    if (self.filterError(error)) {
                        print("got badges", badges!)
                        self.dataSource = NSMutableArray.init(array: badges!)
                        if(self.dataSource.count == 0){
                            self.datasourceIsEmpty = true;
                        }
                        else{
                            self.datasourceIsEmpty = false;
                        }
                        self.collectionView!.dataSource = self;
                        self.collectionView!.reloadData();
                    }
                })
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty-badge");
    }


    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyText = "kEmptyBadges".localized;
        let attributes = [NSForegroundColorAttributeName: CL_GREY_BG_EC, NSFontAttributeName: fontMontserrat18]
        return NSAttributedString(string: emptyText, attributes: attributes);
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.datasourceIsEmpty;
    }

    override func collectionView(_ nView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.dataSource.count;
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kABadgeCell, for: indexPath) as! ABadgeCell;
        let badge = self.dataSource[indexPath.row] as! LPBadge;

        if (self.badgeRequestType == BadgeRequestTypeSpecific) {
            cell.bindData(badge.name!, badgeImageURL: badge.smallIcon!.url!, badgeDetail: badge.displayGrantDate())
        } else {
            let detailStr = String.init(format: "kProfileBadgeLevel_Holder".localized, badge.level);
            cell.bindData(badge.name!, badgeImageURL: badge.smallIcon!.url!, badgeDetail: detailStr)
        }
        return cell;
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = kBadgeCellInsets.left * (kNumBadgesPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = floor(availableWidth / kNumBadgesPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem + 30)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return kBadgeCellInsets;
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kBadgeCellInsets.top;
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kBadgeCellInsets.left;
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let badge = self.dataSource[indexPath.row] as! LPBadge;
        let badgeDetailController = BadgeController(badge: badge);
        self.navigationController?.pushViewController(badgeDetailController, animated: true);
    }

}
