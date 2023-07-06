//
//  SettingsController.swift
//  loop
//
//  Created by Yecol Hsu on 31/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Instabug

private let kCell = "kCell"
class SettingsController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = CL_GREY_BG_EC;
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCell);
        
        self.title = "Settings"
        
        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
        case 0: return 2;
        default: return 1;
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return FL_SEPARATOR_HEIGHT;
        }
        else {
            return FL_SEPARATOR_HEIGHT/2;
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 30))
        header.backgroundColor = CL_GREY_BG_EC;
        return header;
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 30))
        footer.backgroundColor = CL_GREY_BG_EC;
        return footer;
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FL_SEPARATOR_HEIGHT/2;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCell, for: indexPath);
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0: cell.textLabel?.text = "kSettingItemAbout".localized; break;
            default: cell.textLabel?.text = "kSettingItemFeedback".localized; break;
            }
        default: cell.textLabel?.text = "kSettingItemLogout".localized;
        }
        return cell;
    }
    
    func backAction() -> Void {
        self.dismiss(animated: true, completion: nil);
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                let controller = WebViewController();
                controller.setAsAbout();
                controller.title = "kSettingItemAbout".localized
                let navigationController = UINavigationController.init(rootViewController: controller);
                navigationController.navigationBar.tintColor = CL_GREEN_DEFAULT
                let cancelButton = UIBarButtonItem(title: "kCancel".localized, style: .plain, target: self, action: "backAction")
                controller.navigationItem.leftBarButtonItem = cancelButton;
                
                self.present(navigationController, animated: true, completion: nil)
                break;
            default: Instabug.invoke(); break;
            }
        default:
            LPChat.invokeThisMethod(beforeLogoutSuccess: {
                AVUser.logOut();
            }, failed: nil)
            
            AVUser.logOut();
            
            self.navigationController?.popViewController(animated: false);
            self.tabBarController?.selectedIndex = 0;
            let loginController = LoginController();
            let navController = UINavigationController(rootViewController: loginController)
            navController.setNavigationBarHidden(true, animated: false);
            self.present(navController, animated:true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true);
    }

}
