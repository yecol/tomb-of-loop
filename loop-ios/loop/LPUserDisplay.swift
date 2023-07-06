//
//  LPUserDisplay.swift
//  loop
//
//  Created by Yecol Hsu on 23/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

class LPUserDisplay: NSObject {
    
    var displayName: NSString = "";
    var avatarUrl: NSString = "";
    var objectID: NSString = "";
    
    convenience init(name:String, avatar:String, id:String){
        self.init();
        displayName = name as NSString;
        avatarUrl = avatar as NSString;
        objectID = id as NSString;
    }
    
    convenience init(name:String, id:String){
        self.init();
        displayName = name as NSString;
        objectID = id as NSString;
    }
    
    static func initWithAVUserAvatar(_ user:AVUser) -> LPUserDisplay{
        let dpUser = LPUserDisplay(name: user.firstName! + " " + user.lastName!,
                                   avatar: user.avatar?.url ?? "", id: user.objectId!)
        return dpUser;
    }
    
    static func initWithAVUserNoAvatar(_ user:AVUser) -> LPUserDisplay{
        let dpUser = LPUserDisplay(name: user.firstName! + " " + user.lastName!,id: user.objectId!)
        return dpUser;
    }
}

