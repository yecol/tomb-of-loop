//
//  BadgeFeaturedCollectionView.swift
//  loop
//
//  Created by Yecol Hsu on 03/03/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

let kBadgeFeaturedCollectionViewHeight:CGFloat = 220.0;

fileprivate let kFeaturedCellWidth: CGFloat = kScreenW*0.8;
fileprivate let kFeaturedCellHeight: CGFloat = 120.0;
fileprivate let kPadding: CGFloat = 10.0;
fileprivate let kCollectionHeight:CGFloat = 200;

class BadgeFeaturedCollectionView: UIView {

    private lazy var badgeCollection: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: kFeaturedCellWidth, height: kFeaturedCellHeight)
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0;
        let collectionView = UICollectionView(frame: CGRect.null, collectionViewLayout: flowLayout);
        collectionView.register(BadgeFeaturedCell.self, forCellWithReuseIdentifier: kBadgeFeaturedCell);
        collectionView.backgroundColor = UIColor.clear;
        return collectionView;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame);

        let gradient = CAGradientLayer()
        gradient.frame.size = CGSize.init(width: kScreenW, height: kBadgeFeaturedCollectionViewHeight);
        gradient.startPoint = CGPoint.init(x: 0.5, y: 0);
        gradient.endPoint = CGPoint.init(x: 0.5, y: 1);
        gradient.colors = [UIColor.white.cgColor, CL_GREY_CARDBG.cgColor]
        self.layer.addSublayer(gradient)

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
    
    private func addLayoutContraints() {
        self.badgeCollection.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(kCollectionHeight+10)
            make.width.equalToSuperview();
            make.bottom.lessThanOrEqualToSuperview();
        }
    }

}
