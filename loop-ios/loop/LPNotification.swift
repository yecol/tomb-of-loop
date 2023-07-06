//
//  LPNotification.swift
//  loop
//
//  Created by Yecol Hsu on 30/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

let kNotificationTypeFriendship = 1;

class LPNotification: AVObject, AVSubclassing {
    
    @NSManaged var from: AVUser; // 创建者
    @NSManaged var to: AVUser; // 创建者
    @NSManaged var type: Int; // post type
    @NSManaged var relationCodeWithFromUser:Int
    
    static func parseClassName() -> String {
        return "LoopNotification"
    }
}
