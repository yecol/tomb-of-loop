//
//  DiscoveryNavController.swift
//  loop
//
//  Created by Yecol Hsu on 03/09/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import CarbonKit

class DiscoveryNavController: UIViewController, CarbonTabSwipeNavigationDelegate {

    var items = ["kDiscoveryTabBadge".localized, "kDiscoveryTabPeople".localized];
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation = CarbonTabSwipeNavigation()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "kTabDiscovery".localized

        self.view.backgroundColor = CL_GREY_BG_EC;
//        self.title = "Discovery"

        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)

        self.navigationController?.navigationBar.isTranslucent = true;
        self.style()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    func style() {
        carbonTabSwipeNavigation.toolbar.isTranslucent = false
        carbonTabSwipeNavigation.setIndicatorColor(CL_GREEN_BG)
        carbonTabSwipeNavigation.setIndicatorHeight(2.0);
        carbonTabSwipeNavigation.setTabBarHeight(32)
        //carbonTabSwipeNavigation.setTabExtraWidth(100)
        let width = self.view.frame.size.width / 2;
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(width, forSegmentAt: 0)
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(width, forSegmentAt: 1)

        carbonTabSwipeNavigation.setNormalColor(UIColor.black.withAlphaComponent(0.6), font:fontSystem12Bold)
        carbonTabSwipeNavigation.setSelectedColor(CL_GREEN_DEFAULT, font: fontSystem12Bold)

    }


    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt)
                    -> UIViewController {

        switch index {
        case 1:
            let discoveryPeopleController = DiscoveryPeopleController(style: .grouped);
            return discoveryPeopleController;


        default:
            let discoveryBadgeController = DiscoveryBadgesController();
            return discoveryBadgeController;

        }

    }

    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
    }
}
