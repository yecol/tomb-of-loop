//
//  PostAttachBadgeController.swift
//  loop
//
//  Created by Yecol Hsu on 01/01/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

protocol PostAttachBadgeDelegate : class {
    func attachBadge(_ badge:LPBadge);
}

class PostAttachBadgeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    //for usual use.
    var delegate:PostAttachBadgeDelegate?
    var dataSource = NSMutableArray();

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.backgroundColor = UIColor.white;
        self.collectionView!.register(ABadgeCell.self, forCellWithReuseIdentifier: kABadgeCell)
        
        let cancelButton = UIBarButtonItem.init(title: "kCancel".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancelBtnPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        // set color of navigation bar
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.tintColor = CL_GREEN_DEFAULT
        self.navigationController?.navigationBar.barTintColor = CL_GREY_NAVIBAR;
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: CL_BLACK_GRACE, NSFontAttributeName: fontMontserrat16]
        title = "kTitle_PostNew_AttachBadges".localized;
        

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
        DataModelManager.sharedInstance.cloudGetBadgeList(BadgeRequestTypeSpecific, limit: kGetAllInOnePage, skip: nil, specific: AVUser.current()!.objectId!, block: { (badges: Array<Any>?, error: Error?) in
            self.hideProgress()
            if(self.filterError(error)) {
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
        cell.bindData(badge.name!, badgeImageURL: badge.smallIcon!.url!, badgeDetail: badge.displayGrantDate())
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
        self.delegate?.attachBadge(badge);
        self.dismiss(animated: true, completion: nil);
    }
    
    func cancelBtnPressed(){
        self.dismiss(animated: true, completion: nil);
    }

}
