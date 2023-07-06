//
//  DiscoveryBadgesController.swift
//  loop
//
//  Created by Yecol Hsu on 30/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

fileprivate let kTagBadgeHottest = 0;
fileprivate let kTagBadgeFeatured = 1;
fileprivate let kTagBadgeInterest = 2;

class DiscoveryBadgesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var featuredBadges: NSArray?;
    var interestingBadges: NSArray?;
    var hottestBadges: NSArray?;
    var filledBadgeGroup = 0;

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView;
    }();


    private lazy var hottestArea: BadgeFeaturedCollectionView = {
        let collectionView = BadgeFeaturedCollectionView(frame: CGRect.null);
        collectionView.setCollectionViewDataSourceDelegate(self, forSection: kTagBadgeHottest);
        return collectionView;
    }();

    private lazy var featuredArea: BadgeCollectionView = {
        let collectionView = BadgeCollectionView(frame: CGRect.null);
        collectionView.setCollectionViewDataSourceDelegate(self, forSection: kTagBadgeFeatured);
        collectionView.setTitle(title: "kSectionTitle_DiscoveryBadge_Featured".localized)
        return collectionView;
    }();

    private lazy var interestingArea: BadgeCollectionView = {
        let collectionView = BadgeCollectionView(frame: CGRect.null);
        collectionView.setCollectionViewDataSourceDelegate(self, forSection: kTagBadgeInterest);
        collectionView.setTitle(title: "kSectionTitle_DiscoveryBadge_Interesting".localized)
        return collectionView;
    }();

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = CL_GREY_BG_EC;
        self.view.addSubview(scrollView);
        self.scrollView.addSubview(hottestArea)
        self.scrollView.addSubview(featuredArea)
        self.scrollView.addSubview(interestingArea);
        self.addLayoutConstrains();
        self.loadData();
    }

    func loadData() {

        DataModelManager.sharedInstance.cloudGetBadgeList(BadgeRequestTypeHot, limit: kGetAllInOnePage, skip: 0,
                specific: "", block: { (badges: Array<Any>?, error: Error?) in
            if (self.filterError(error)) {
                self.hottestBadges = NSMutableArray.init(array: badges!);
                self.hottestArea.reloadData();
            }
        })

        DataModelManager.sharedInstance.cloudGetBadgeList(BadgeRequestTypeFeatured, limit: kGetAllInOnePage, skip: 0,
                specific: "", block: { (badges: Array<Any>?, error: Error?) in
            if (self.filterError(error)) {
                self.featuredBadges = NSMutableArray.init(array: badges!);
                self.featuredArea.reloadData();
            }
        })

        DataModelManager.sharedInstance.cloudGetBadgeList(BadgeRequestTypeInterested, limit: kGetAllInOnePage, skip: 0,
                specific: "", block: { (badges: Array<Any>?, error: Error?) in
            if (self.filterError(error)) {
                self.interestingBadges = NSMutableArray.init(array: badges!);
                self.interestingArea.reloadData();
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case kTagBadgeFeatured: return self.featuredBadges?.count ?? 0;
        case kTagBadgeInterest: return self.interestingBadges?.count ?? 0;
        case kTagBadgeHottest: return self.hottestBadges?.count ?? 0;
        default: return 0;
        }
    }


    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch collectionView.tag {
        case kTagBadgeHottest:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kBadgeFeaturedCell, for: indexPath) as! BadgeFeaturedCell
            let badge = self.hottestBadges!.object(at: indexPath.row) as! LPBadge;
            let subtitle = String.init(format: "kDiscoveryBadgeHot_Holder".localized, badge.rarity) + "%"
            cell.bindData(badge.name, badgeImageURL: badge.smallIcon!.url!, badgeSubtitle: subtitle, badgeDetail: badge.definition ?? badge.tagline)
            return cell;

        case kTagBadgeFeatured:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kABadgeCell, for: indexPath) as!
            ABadgeCell
            let badge = self.featuredBadges!.object(at: indexPath.row) as! LPBadge;
            cell.bindData(badge.name, badgeImageURL: badge.smallIcon!.url!, badgeDetail: String.init(format: "kDiscoveryBadgeHot_Holder".localized, badge.rarity) + "%");
            return cell

        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kABadgeCell, for: indexPath) as!
            ABadgeCell
            let badge = self.interestingBadges!.object(at: indexPath.row) as! LPBadge;
            cell.bindData(badge.name, badgeImageURL: badge.smallIcon!.url!, badgeDetail: String.init(format: "kDiscoveryBadgeHot_Holder".localized, badge.rarity) + "%")
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch collectionView.tag {
        case kTagBadgeHottest:
            badgeDetail(badge: self.hottestBadges!.object(at: indexPath.row) as! LPBadge);
        case kTagBadgeFeatured:
            badgeDetail(badge: self.featuredBadges!.object(at: indexPath.row) as! LPBadge);
        default:
            badgeDetail(badge: self.interestingBadges!.object(at: indexPath.row) as! LPBadge);
        }
    }


    func badgeDetail(badge: LPBadge) {
        let badgeDetailController = BadgeController(badge: badge);
        self.navigationController?.pushViewController(badgeDetailController, animated: true);
    }


    private func addLayoutConstrains() {

        self.scrollView.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview();
            make.size.equalToSuperview();
        }

        self.hottestArea.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview();
            make.centerX.equalToSuperview();
            make.width.equalToSuperview()
            make.height.equalTo(kBadgeFeaturedCollectionViewHeight);
        }

        self.featuredArea.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.hottestArea.snp.bottom);
            make.centerX.equalToSuperview();
            make.width.equalToSuperview()
            make.height.equalTo(kBadgeCollectionHeight);
        }

        self.interestingArea.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.featuredArea.snp.bottom).offset(FL_PADDING);
            make.centerX.equalToSuperview();
            make.width.equalToSuperview()
            make.height.equalTo(kBadgeCollectionHeight);
        }

        let contentHeight: CGFloat = kBadgeFeaturedCollectionViewHeight + FL_PADDING * 2 + kBadgeCollectionHeight * 2;
        self.scrollView.contentSize = CGSize(width: kScreenW, height: contentHeight)
    }
}
