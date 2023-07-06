//
//  StartBadgeSelectController.swift
//  loop
//
//  Created by Yecol Hsu on 02/04/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit

fileprivate let kSelectedBadgeLimit = 4;

class StartBadgeSelectController: UICollectionViewController,
        UICollectionViewDelegateFlowLayout {


    //for usual use.
    var dataSource = NSMutableArray();
    var selectedBadges = NSMutableArray();

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "kTitle_InitSelectBadge".localized;

        // Register cell classes
        self.collectionView!.backgroundColor = UIColor.white;
        self.collectionView!.allowsMultipleSelection = true;
        self.collectionView!.register(ABadgeCell.self, forCellWithReuseIdentifier: kABadgeCell)

        let doneButton = UIButton();
        doneButton.setTitle("kDone".localized, for: .normal);
        doneButton.frame = CGRect(x: 0, y: 0, width: 60, height: 25);
        doneButton.setLoopBtnGreenFramed(font: fontMontserrat14);
        doneButton.addTarget(self, action: #selector(self.doneBtnPressed), for: .touchUpInside);
        let anotherButton = UIBarButtonItem.init(customView: doneButton)
        self.navigationItem.rightBarButtonItem = anotherButton;

        let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(self.skipBtnPressed))
        self.navigationItem.leftBarButtonItem = skipButton;

//        self.navigationController?.setLoopTheme()


        // A little trick for removing the cell separators
        self.navBarBgAlpha = 1
        self.navBarTintColor = CL_GREEN_DEFAULT

        self.refresh();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func refresh() {
        self.showLoadingProgress()
        DataModelManager.sharedInstance.cloudGetBadgeList(BadgeRequestTypeStart, limit: 100,
                skip: 0, specific: AVUser.current()!.objectId!, block: { (badges: Array<Any>?, error: Error?) in
                    self.hideProgress();
            if (self.filterError(error)) {
                self.dataSource = NSMutableArray.init(array: badges!)
                self.collectionView!.dataSource = self;
                self.collectionView!.reloadData();
            }
        })
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
        cell.bindData(badge.name!, badgeImageURL: badge.smallIcon!.url!, badgeDetail: "")
        let bgview = UIView.init(frame: cell.contentView.frame);
        bgview.backgroundColor = CL_BADGEFAV_SELECT;
        cell.selectedBackgroundView = bgview;
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

        let selectedBadgeId = (dataSource.object(at: indexPath.row) as! LPBadge).objectId!;
        if(selectedBadges.contains(selectedBadgeId) == false){
            selectedBadges.add(selectedBadgeId);
        }

    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if selectedBadges.count < kSelectedBadgeLimit {
            return true;
        } else {
            self.showToast(with: "kToastBadgeSelectorAtMost".localized)
            return false
        }

    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let objId = (dataSource.object(at: indexPath.row) as! LPBadge).objectId!;
        selectedBadges.remove(objId);
    }

    func skipBtnPressed() {
        AVUser.current()!.initialized = true;
        AVUser.current()!.saveInBackground();
        self.dismiss(animated: true, completion: nil);
    }

    func doneBtnPressed() {
        AVUser.current()!.initialized = true;
        AVUser.current()!.saveInBackground();
        DataModelManager.sharedInstance.cloudSetupStarterBadgeList(selectedBadges, block: { (success, error) in
            if (self.filterError(error)) {
                self.dismiss(animated: true, completion: nil)
            }
        });
    }
}
