//
//  NewsFeedNavController.swift
//  loop
//
//  Created by Yecol Hsu on 09/08/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import CarbonKit
import CoreLocation
import SnapKit

class NewsFeedNavController: UIViewController, CarbonTabSwipeNavigationDelegate, CLLocationManagerDelegate {

    var items = ["kFeedTabRecommend".localized, "kFeedTabFriends".localized];
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    var locationManager: CLLocationManager!
    var badgeFilterPanelController: BadgeFilterPanelController?
    var swipeViewContainer: UIView?
    
    weak var filterBtn:UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "kTabFeed".localized;

        self.view.backgroundColor = CL_GREY_BG_EC;

        if (AVUser.current() == nil) {
            self.showLoginController()
        } else if (AVUser.current()?.avatar == nil) {
            self.showRegisterDetailController()
        }

        
        let searchButton = UIButton.init(type: .custom);

        searchButton.frame = CGRect(x: 0, y: 0, width: 30, height: 40);
        searchButton.setImage(UIImage.init(named: "search-icon"), for: UIControlState.normal);
        searchButton.addTarget(self, action: #selector(self.searchBtnPressed), for: UIControlEvents.touchUpInside);

        let filterButton = UIButton.init(type: .custom);
        filterButton.frame = CGRect(x: 0, y: 0, width: 30, height: 40);
        filterButton.setImage(UIImage.init(named: "badge-filter"), for: UIControlState.normal);
        filterButton.setImage(UIImage.init(named: "badge-filter-selected"), for: UIControlState.selected);
        
        filterButton.addTarget(self, action: #selector(self.filterBtnPressed), for: UIControlEvents.touchUpInside);
        self.filterBtn = filterButton;

        
//        let button = UIButton.init(type: .custom);
//        button.frame = CGRect(x: 0, y: 0, width: 60, height: 25);
//        button.setTitle("Test", for: UIControlState());
//        button.addTarget(self, action: #selector(self.testBtnPressed), for: UIControlEvents.touchUpInside);
//        button.setLoopBtnWhiteFramed(font: fontMontserrat14);
//
//        
//        let anotherButton = UIBarButtonItem.init(customView: button)
//        self.navigationItem.leftBarButtonItem = anotherButton

        let searchButtonItem = UIBarButtonItem.init(customView: searchButton)
        let filterButtonItem = UIBarButtonItem.init(customView: filterButton)
        self.navigationItem.rightBarButtonItems = [searchButtonItem, filterButtonItem];

        self.swipeViewContainer = UIView(frame: .zero)
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: self.swipeViewContainer!)
        self.style()

        self.view.addSubview(self.swipeViewContainer!)
        self.swipeViewContainer!.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }

        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if status == CLAuthorizationStatus.authorizedWhenInUse
                          || status == CLAuthorizationStatus.authorizedAlways {
            self.locationManager.startUpdatingLocation()
        } else {
            self.displayAlertView("kAlert_CannotGotLocation".localized);
        }
        
        self.navigationController?.navigationBar.isTranslucent = true;
        
        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        if(AVUser.current() != nil && AVUser.current()?.initialized == false){
            self.showStartSelectController();
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func style() {
        carbonTabSwipeNavigation.toolbar.isTranslucent = false
        carbonTabSwipeNavigation.setIndicatorColor(CL_GREEN_BG)
        carbonTabSwipeNavigation.setIndicatorHeight(2.0);
        carbonTabSwipeNavigation.setTabBarHeight(32)
        let width = self.view.frame.size.width / 2;
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(width, forSegmentAt: 0)
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(width, forSegmentAt: 1)

        carbonTabSwipeNavigation.setNormalColor(UIColor.black.withAlphaComponent(0.6), font: UIFont.boldSystemFont(ofSize: 12))
        carbonTabSwipeNavigation.setSelectedColor(CL_GREEN_DEFAULT, font: UIFont.boldSystemFont(ofSize: 12))
    }


    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {

        switch index {
        case 1:
            let newsfeedFriend = NewsFeedController(type: .friendStream)
            return newsfeedFriend;
        default:
            let recommendation = NewsFeedController(type: .recommandStream);
            return recommendation
        }

    }

    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
        NSLog("Did move at index: %ld", index)
    }

    func showLoginController() {
        let loginController = LoginController()
        let navController = UINavigationController(rootViewController: loginController)
        navController.setNavigationBarHidden(true, animated: false);
        self.present(navController, animated: true, completion: nil)
    }

    func showRegisterDetailController() {
        let registerDetailController = RegisterDetailController(style: .grouped);
        let navController = UINavigationController(rootViewController: registerDetailController)
        navController.setNavigationBarHidden(true, animated: false);
        self.present(navController, animated: true, completion: nil);
    }

    func showStartSelectController() {
        let flowLayout = UICollectionViewFlowLayout();
        let startBadgesController = StartBadgeSelectController(collectionViewLayout: flowLayout);
        let navController = UINavigationController(rootViewController: startBadgesController);
        self.present(navController, animated: true, completion: nil);
    }


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            self.displayAlertView("kAlert_CannotGotLocation".localized)
        } else {
            self.locationManager.startUpdatingLocation()
        }
    }

    //
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            self.locationManager.stopUpdatingLocation()
            DataModelManager.sharedInstance.updateLatestLocation(AVGeoPoint(location: locations.first!));
        }
    }


    func testBtnPressed() {
        // Create the dialog
        self.displayBadgeCongrats(badgeId: "58056db391e79b0062db98f9", grant: .grant);
    }

    func searchBtnPressed() {
        let searchController = SearchController();
        self.navigationController?.pushViewController(searchController, animated: true);
    }

    func filterBtnPressed() {
        let tabIndex = self.carbonTabSwipeNavigation.currentTabIndex
        let currentTabViewController = self.carbonTabSwipeNavigation.viewControllers[tabIndex] as! NewsFeedController

        if self.badgeFilterPanelController != nil {
            
            self.filterBtn!.isSelected = false;
            
            self.badgeFilterPanelController!.willMove(toParentViewController: nil)
            self.badgeFilterPanelController!.view.removeFromSuperview()
            self.badgeFilterPanelController!.removeFromParentViewController()
            self.badgeFilterPanelController = nil

            self.swipeViewContainer!.snp.remakeConstraints { (make) -> Void in
                make.width.equalTo(self.view)
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
                make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            }

            currentTabViewController.badgeIdArray = Array<String>()
            currentTabViewController.refresh(.loadDefault)

            return
        }

        let badgeFilterController = BadgeFilterController()
        badgeFilterController.hidesBottomBarWhenPushed = true
        let navController = UINavigationController.init(rootViewController: badgeFilterController);
        self.present(navController, animated: true, completion: nil);

//        self.navigationController?.pushViewController(badgeFilterController, animated: true)

        badgeFilterController.completionHandler = { [weak self] (array: Array<LPBadge>) -> Void in
            withExtendedLifetime(self) {
                self!.badgeFilterPanelController = BadgeFilterPanelController(badgeArray: array)
                self!.addChildViewController(self!.badgeFilterPanelController!)

                self!.view.addSubview(self!.badgeFilterPanelController!.view)
                self!.badgeFilterPanelController!.didMove(toParentViewController: self!)

                self!.badgeFilterPanelController!.view.snp.makeConstraints { (make) -> Void in
                    make.top.equalTo(self!.topLayoutGuide.snp.bottom)
                    make.width.equalTo(self!.view)
                    make.height.equalTo(60)
                }

                self!.swipeViewContainer!.snp.remakeConstraints { (make) -> Void in
                    make.width.equalTo(self!.view)
                    make.top.equalTo(self!.badgeFilterPanelController!.view.snp.bottom)
                    make.bottom.equalTo(self!.bottomLayoutGuide.snp.top)
                }

                currentTabViewController.badgeIdArray = Array(array.map {
                    $0.objectId!
                })
                
                self!.filterBtn!.isSelected = true;
                
                currentTabViewController.refresh(.loadDefault)
            }
        }
    }

}
