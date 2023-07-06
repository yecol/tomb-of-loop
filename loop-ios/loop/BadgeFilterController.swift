//
//  BadgeFilterController.swift
//  loop
//
//  Created by XueCheng on 2/19/17.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import Foundation
import SnapKit

class BadgeFilterController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let cellIdentifier = "badge"
    private let kSelectedBadgeLimit = 4;

    private var dataSource: Array<LPBadge>?
    private var selectedBadges = NSMutableArray();

    public var completionHandler: ((Array<LPBadge>) -> Void)?

    private lazy var filterBtn: UIButton = { [unowned self] in
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 25);
        button.setTitle("kButton_BadgeFilter_Filter_Normal".localized, for: .normal)
        button.setLoopBtnGreenFramed(font: fontMontserrat14)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        button.addTarget(self, action: #selector(self.didPressFilterButton), for: .touchUpInside)
        return button
    }()

    private lazy var collectionView: UICollectionView = { [unowned self] in
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true;
        collectionView.register(ABadgeCell.self, forCellWithReuseIdentifier: self.cellIdentifier)

        return collectionView
    }()

    // MARK: Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "kTitle_BadgeFilter".localized
        self.navBarBgAlpha = 1
        self.navBarTintColor = CL_GREEN_DEFAULT;
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.filterBtn)

        let cancelButton = UIBarButtonItem(title: "kCancel".localized, style: .plain, target: self, action: #selector(self
                .cancelBtnPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;

        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
            make.center.equalTo(self.view)
        }

        sendRequestAndReloadData()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIApplication.shared.statusBarStyle = .lightContent
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! ABadgeCell;
        let badge: LPBadge = self.dataSource![indexPath.row]
        cell.bindData(badge.name!, badgeImageURL: badge.smallIcon!.url!, badgeDetail: "")
        let bgview = UIView.init(frame: cell.contentView.frame);
        bgview.backgroundColor = CL_BADGEFAV_SELECT;
        cell.selectedBackgroundView = bgview;
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let badge = dataSource![indexPath.row];
        if(selectedBadges.contains(badge) == false){
            selectedBadges.add(badge);
        }
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
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if selectedBadges.count < kSelectedBadgeLimit {
            return true;
        }
        else{
            self.showToast(with: "kToastBadgeSelectorAtMost".localized)
            return false
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let badge = dataSource![indexPath.row];
        selectedBadges.remove(badge);
    }

    // MARK: Private Functions

    func sendRequestAndReloadData() {
        DataModelManager.sharedInstance.cloudGetUserBadgeList { [weak self] (objects, error) in
            withExtendedLifetime(self) {
                guard error == nil else {
                    return
                }

                self!.dataSource = objects as! Array<LPBadge>?
                self!.collectionView.reloadData()
            }
        }
    }

    func cancelBtnPressed(){
        self.dismiss(animated: true);
    }

    func didPressFilterButton() {
        guard let _ = self.dataSource, let callback = self.completionHandler else {
//            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            return
        }

//        var array = Array<LPBadge>()
//
//        for i in 0...(dataSource.count - 1) {
//            let indexPath = IndexPath(row: i, section: 0)
//            let cell = self.collectionView.cellForItem(at: indexPath) as! BasicBadgeCell
//
//            if cell.checked {
//                array.append(dataSource[i])
//            }
//        }

        if selectedBadges.count == 0 {
            return
        }

        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
        callback(selectedBadges as! Array<LPBadge>)
    }

}
//
//private class BasicBadgeCell: UICollectionViewCell {
//
////    public var touchUpInsideHandler: (() -> Void)?
//
//    private let highlightViewLen = 80
//
//    private lazy var nameLabel: UILabel = { [unowned self] in
//        let label = UILabel()
//        label.textColor = CL_BLACK_GRACE
//        label.font = fontSystem14Bold
//        return label
//    }()
//
//    private lazy var detailLabel: UILabel = { [unowned self] in
//        let label = UILabel()
//        label.textColor = CL_GREY_FONT
//        label.font = fontSystem12
//        return label
//    }()
//
//    private lazy var iconView: UIImageView = { [unowned self] in
//        let imageView = UIImageView(image: UIImage(named: "badge-ph"))
//        imageView.contentMode = .scaleAspectFill
//        return imageView
//    }()
//
//    private lazy var highlightView: UIView = { [unowned self] in
//        let view = UIView()
//        view.layer.cornerRadius = 40
//        view.backgroundColor = CL_BADGEFAV_SELECT
//        return view
//    }()
//
////    public var checked: Bool = false {
////        didSet {
////            self.highlightView.isHidden = !checked
////        }
////    }
//
//    // MARK: Override Functions
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
////        self.contentView.addSubview(self.highlightView)
//        
//        self.contentView.addSubview(self.iconView)
//        self.contentView.addSubview(self.nameLabel)
//        self.selectedBackgroundView = self.highlightView;
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: Internal Functions
//
//    func setData(name: String, imageURL: String, detail: String?) {
//        self.nameLabel.text = name
//        self.detailLabel.text = detail
//        self.iconView.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "badge-ph"))
//
//        if self.detailLabel.text != nil {
//            self.contentView.addSubview(self.detailLabel)
//        } else {
//            self.detailLabel.removeFromSuperview()
//        }
//
//        self.updateLayoutConstraints()
//    }
//
//    // MARK: Private Functions
//
//    private func updateLayoutConstraints() {
//        self.contentView.snp.remakeConstraints { (make) -> Void in
//            make.width.equalTo(UIScreen.main.bounds.size.width / 3)
//        }
//
//        self.iconView.snp.remakeConstraints { (make) -> Void in
//            make.width.equalTo(60)
//            make.height.equalTo(60)
//            make.top.equalToSuperview().offset(10)
//            make.centerX.equalToSuperview()
//        }
//
//        self.highlightView.snp.remakeConstraints { (make) -> Void in
//            make.center.equalTo(self.iconView)
//            make.width.equalTo(highlightViewLen);
//            make.height.equalTo(highlightViewLen);
//        }
//
//        self.nameLabel.snp.remakeConstraints { (make) -> Void in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(self.iconView.snp.bottom).offset(10)
//            make.left.greaterThanOrEqualToSuperview().offset(10)
//            make.right.lessThanOrEqualToSuperview().offset(-10)
//
//            if self.detailLabel.text == nil {
//                make.bottom.equalToSuperview().offset(-10)
//            }
//        }
//
////        self.detailLabel.snp.remakeConstraints { (make) -> Void in
////            guard self.detailLabel.text != nil else {
////                return
////            }
////
////            make.centerY.equalTo(self.iconView)
////            make.top.equalTo(self.nameLabel.snp.bottom)
////            make.topMargin.equalTo(4)
////            make.bottomMargin.equalTo(10)
////        }
//    }
//
//}


