//
//  ModuleFriendListMultiController.swift
//  loop
//
//  Created by Yecol Hsu on 28/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit

let kTaggedFriendLimit = 4;

protocol PostAttachFriendsDelegate : class {
    func attachFriends(_ friends:NSArray);
}

class PostAttachFriendsController: UITableViewController {
    
    var delegate:PostAttachFriendsDelegate?;
    
    var dataSource = NSMutableArray();
    var taggedFriend = NSMutableArray();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.backgroundColor = CL_GREY_BG_EC;
        
        let cancelButton = UIBarButtonItem.init(title: "kCancel".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancelBtnPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        let doneButton = UIBarButtonItem.init(title: "kDone".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doneBtnPressed))
        self.navigationItem.rightBarButtonItem = doneButton;
        
        self.navigationController?.navigationBar.tintColor = CL_GREEN_DEFAULT;
        self.tableView.allowsMultipleSelection = true;
        self.tableView.tintColor = CL_GREEN_DEFAULT;
        
        //self.tableView.style = UITableViewStyle.Grouped;
        self.refresh();
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func refresh(){
        self.showLoadingProgress()
        DataModelManager.sharedInstance.cloudGetUserList(UserRequestTypeFriends, limit: kGetAllInOnePage, skip: 0, specific: AVUser.current()!.objectId!, block: { (users: Array<Any>?, error: Error?) in
            self.hideProgress()
            if(self.filterError(error)) {
                self.dataSource = NSMutableArray.init(array: users!);
                self.tableView.dataSource = self;
//                print("new data source has ", self.dataSource.count)
                self.tableView.reloadData();
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFriendListCellHeight;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 12;
        }
        else {
            return 6;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12;
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: kFriendCellIdentifier)
        if(cell == nil){
            cell = FriendCell.init(style: .subtitle, reuseIdentifier: kFriendCellIdentifier)
        }

        let friend = self.dataSource.object(at: indexPath.row) as! AVUser;
        let details = String(format: "kFriendItemDetail_Holder".localized, friend.postCount, friend.badgeCount, friend.friendCount);
        
        (cell as! FriendCell).bindData(friend.displayName(), avatar: friend.avatar?.url ?? "", detail: details)
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        let cell =  tableView.cellForRow(at: indexPath)!;
        
        if (cell.accessoryType == .none && self.taggedFriend.count < kTaggedFriendLimit) {
            self.taggedFriend.add(self.dataSource[indexPath.row]);
            cell.accessoryType = .checkmark;
            
        }else{
            
            self.taggedFriend.remove(self.dataSource[indexPath.row]);
            cell.accessoryType = .none;
        }
        
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func cancelBtnPressed(){
        self.dismiss(animated: true, completion: nil);
    }
    
    func doneBtnPressed(){
        self.delegate?.attachFriends(self.taggedFriend);
        self.dismiss(animated: true, completion: nil);
    }

}
