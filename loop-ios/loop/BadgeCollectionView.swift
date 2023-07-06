//
//  BadgeCollectionView.swift
//  loop
//
//  Created by Yecol Hsu on 02/03/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

let kBadgeCollectionHeight: CGFloat = 200;

class BadgeCollectionView: UIView {

    private lazy var sectionTitle: UILabel = {
        let label = UILabel();
        label.textColor = CL_GREY_FONT;
        label.font = fontMontserrat12;
        return label;
    }()

    private lazy var badgeCollection: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: (kScreenW - 2 * kABadgePadding) / 3, height: kABadgeCellSize)
        let collectionView = UICollectionView(frame: CGRect.null, collectionViewLayout: flowLayout);
        collectionView.register(ABadgeCell.self, forCellWithReuseIdentifier: kABadgeCell);
        collectionView.backgroundColor = UIColor.white;
        return collectionView;
    }()

    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.white;
        self.addSubview(sectionTitle);
        self.addSubview(badgeCollection)
        self.addLayoutContraints();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCollectionViewDataSourceDelegate
            <D:UICollectionViewDataSource & UICollectionViewDelegate>
            (_ dataSourceDelegate: D, forSection section: Int) {
        self.badgeCollection.delegate = dataSourceDelegate
        self.badgeCollection.dataSource = dataSourceDelegate
        self.badgeCollection.tag = section
    }

    func reloadData() {
        self.badgeCollection.reloadData();
    }

    func setTitle(title: String) {
        self.sectionTitle.text = title;
    }

    private func addLayoutContraints() {
        self.sectionTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(FL_PADDING)
            make.left.equalToSuperview().offset(FL_PADDING);
            make.width.equalToSuperview();
            make.height.equalTo(12)
        }
        self.badgeCollection.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.sectionTitle.snp.bottom).offset(FL_PADDING)
            make.centerX.equalToSuperview()
            make.height.equalTo(kBadgeCollectionHeight - 20);
            make.width.equalToSuperview();
            make.bottom.lessThanOrEqualToSuperview();
        }
    }
}
