//
//  LPCheckIn.swift
//  loop
//
//  Created by Yecol Hsu on 28/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

class LPCheckin: AVObject, AVSubclassing {
    
    //    @NSManaged var creator:AVUser!; // 创建者
    @NSManaged var user: AVUser? //用户
    @NSManaged var place: LPPlace? //地点
    
    static func parseClassName() -> String {
        return "Checkin"
    }
    
    func displayCheckinDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: self.createdAt!)
    }
    
    
}
