//
//  ProfileBadgeController.swift
//  loop
//
//  Created by Yecol Hsu on 14/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SwipeTableView
import DZNEmptyDataSet

fileprivate let kCell = "kCell"

class ProfileBadgeView: STCollectionView, STCollectionViewDataSource, STCollectionViewDelegate,
        STCollectionViewFlowLayoutDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var badgesArray = NSMutableArray();
    var profileScrollDelegate: ProfileScrollDelegate?;
    var viewUserId = "";
    
//    var datasourceRequesting = false;
    var datasourceIsEmpty = false;

    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout: STCollectionViewFlowLayout = self.st_collectionViewLayout;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        self.stDelegate = self;
        self.stDataSource = self;

//        self.emptyDataSetSource = self;
//        self.emptyDataSetDelegate = self;

        self.backgroundColor = UIColor.white;
        self.register(ABadgeCell.self, forCellWithReuseIdentifier: "item");
        self.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }


    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty-badge");
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.datasourceIsEmpty;
    }


    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyText = "kEmptyBadges".localized;
        let attributes = [NSForegroundColorAttributeName: CL_GREY_BG_EC, NSFontAttributeName: fontMontserrat18]
        return NSAttributedString(string: emptyText, attributes: attributes);
    }

    func refresh() {
//        if(self.datasourceRequesting){
//            return;
//        }
//        self.datasourceRequesting = true;
//        self.viewController()?.showLoadingProgress();
        if (self.badgesArray.count == 0) {
            DataModelManager.sharedInstance.cloudGetBadgeList(BadgeRequestTypeSpecific, limit: kGetAllInOnePage,
                    skip: 0, specific: self.viewUserId,
                    block: { (badges: Array<Any>?, error: Error?) in
//                        self.datasourceRequesting = false;
//                        self.viewController()?.hideProgress();
                        if (self.viewController()?.filterError(error) ?? false) {
                            print("got badges", badges!)
                            self.badgesArray = NSMutableArray.init(array: badges!)
                            if(self.badgesArray.count == 0){
                                self.datasourceIsEmpty = true;
                            }
                            else{
                                self.datasourceIsEmpty = false;
                            }
                            self.reloadData();
                        }
                    })
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.profileScrollDelegate?.didScroll(scrollView.contentOffset.y);
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: kScreenW / 3, height: 150);
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: kScreenW, height: 12);
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.init(width: kScreenW, height: 50);
    }

    func numberOfSections(inStCollectionView collectionView: UICollectionView!) -> Int {
        return 1;
    }

    func stCollectionView(_ collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return self.badgesArray.count;
    }


    func collectionView(_ collectionView: UICollectionView!, layout: STCollectionViewFlowLayout!,
                        numberOfColumnsInSection section: Int) -> Int {
        return 3;
    }


    func stCollectionView(_ collectionView: UICollectionView!, viewForSupplementaryElementOfKind kind: String!, at indexPath: IndexPath!) -> UICollectionReusableView! {

        if (kind == UICollectionElementKindSectionHeader) {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath);
            view.backgroundColor = CL_GREY_BG_EC;
            return view;
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath);
        }
    }

    func stCollectionView(_ collectionView: STCollectionView!, cellForItemAt indexPath: IndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! ABadgeCell;
        let badge = self.badgesArray.object(at: indexPath.row) as! LPBadge;

        cell.bindData(badge.name, badgeImageURL: badge.smallIcon!.url!, badgeDetail: badge.displayGrantDate())
        return cell;
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let badge = self.badgesArray.object(at: indexPath.row) as! LPBadge;
        let badgeDetailController = BadgeController(badge: badge);
        self.viewController()?.navigationController?.pushViewController(badgeDetailController, animated: true);
    }
}
