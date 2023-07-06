//
//  MainTabBarController.swift
//  sctong
//
//  Created by   himi on 15/12/19.
//  Copyright © 2015年 mmmm. All rights reserved.
//

import UIKit
import CYLTabBarController
import IQKeyboardManagerSwift

class MainTabBarController: CYLTabBarController  {
    
    let controllers = [NewsFeedNavController(), DiscoveryNavController(), LCCKConversationListViewController(), ProfileSelfController()];
    
    //标题
    let Title = ["kTabFeed".localized,
                 "kTabDiscovery".localized,
                 "kTabMessage".localized,
                 "kTabProfile".localized];
    //选中时的图片
    let SelectedImage = ["tab-feeds-h","tab-discovery-h","tab-messages-h","tab-profile-h"]
    //未选中时的图片
    let Image = ["tab-feeds","tab-discovery","tab-messages","tab-profile"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tabBarItemsAttributes: [AnyObject] = []
        var viewControllers:[AnyObject] = []
        
        for i in 0 ... Title.count - 1 {
            let dict: [AnyHashable: Any] = [
                CYLTabBarItemTitle: Title[i],
                CYLTabBarItemImage: Image[i],
                CYLTabBarItemSelectedImage: SelectedImage[i]
            ]
            let vc = UINavigationController.init(rootViewController: controllers[i]);
            vc.setLoopThemeGreenNav();
            tabBarItemsAttributes.append(dict as AnyObject)
            viewControllers.append(vc)
        }
        
        self.tabBar.backgroundColor = UIColor.white;
        self.tabBarItemsAttributes = tabBarItemsAttributes as! [[AnyHashable: Any]]
        self.viewControllers = viewControllers as! [UIViewController]
        self.view.tintColor = CL_GREEN_DEFAULT;
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item.title!)
        if(item.title! == "Message"){
            IQKeyboardManager.sharedManager().enableAutoToolbar = false;
            IQKeyboardManager.sharedManager().enable = false;
        }
        else{
            IQKeyboardManager.sharedManager().enableAutoToolbar = true;
            IQKeyboardManager.sharedManager().enable = true;
        }
    }
}


class PlusButtonSubclass : CYLPlusButton,CYLPlusButtonSubclassing{
    
    public static func plusButton() -> Any! {
        let button:PlusButtonSubclass =  PlusButtonSubclass()
        button.setImage(UIImage(named: "tab-addbtn"), for: UIControlState())
        //        button.backgroundColor = CL_GREEN_DEFAULT;
        button.bounds = CGRect(x: 0, y: 0, width: 50, height: 50);
        //        button.titleLabel!.textAlignment = NSTextAlignment.Center;
        button.adjustsImageWhenHighlighted = false;
        button.addTarget(button, action: #selector(self.buttonClicked(_:)), for: UIControlEvents.touchUpInside)
        return  button
    }
    
    //点击事件
    func buttonClicked(_ sender:CYLPlusButton)
    {
        let plusController = PlusController();
        plusController.modalPresentationStyle = .overCurrentContext
        self.cyl_tabBarController?.present(plusController, animated: true, completion: nil);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let centerOfView    = self.bounds.size.width * 0.5;
        self.imageView!.bounds = CGRect(x: 0, y: 0, width: 50, height: 50);
        self.imageView!.center = CGPoint(x: centerOfView, y: 20)//centerOfImageView * 2 );
    }
}
