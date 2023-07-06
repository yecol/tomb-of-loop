//
//  PostCardCollectionCell.swift
//  loop
//
//  Created by Yecol Hsu on 10/02/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

let kPostCardHeight: CGFloat = 320;
let kPostCardWidth: CGFloat = 300.0

class PostCardCollectionCell: UITableViewCell {

    private lazy var collectionView: UICollectionView = { [unowned self] in
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: kPostCardWidth, height: kPostCardHeight)
        let view = UICollectionView(frame: self.contentView.frame, collectionViewLayout: flowLayout);
        view.backgroundColor = CL_GREY_CARDBG;
        view.register(PostCardCell.self, forCellWithReuseIdentifier: kPostCardCell);
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel();
        label.font = fontMontserrat12;
        label.textColor = CL_GREY_FONT;
        label.text = "kSectionTitle_BadgeDetail_Posts".localized
        return label;
    }()

    private lazy var bgView: UIView = {
        let view = UIView(frame: CGRect.null);
        view.backgroundColor = CL_GREY_CARDBG
        return view;
    }()


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier);

        self.contentView.addSubview(bgView);
        self.contentView.addSubview(collectionView);
        self.contentView.addSubview(titleLabel);

        self.addLayoutConstraints();
    };

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLayoutConstraints() {
        self.collectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(30)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview();
            make.height.equalToSuperview().offset(-30);
        }

        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(12);
            make.left.equalToSuperview().offset(12);
            make.width.equalToSuperview().offset(-12)
        }

        self.bgView.snp.makeConstraints { (make) -> Void in
            make.size.equalToSuperview();
            make.center.equalToSuperview();
        }
    }

    func moreBtnPressed() {
    }

    func setRowInTable(_ row: Int) {
        collectionView.tag = row;
    }


    func setCollectionViewDataSourceDelegate
            <D:UICollectionViewDataSource & UICollectionViewDelegate>
            (_ dataSourceDelegate: D, forSection section: Int) {

        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = section
        collectionView.reloadData()
    }


}
