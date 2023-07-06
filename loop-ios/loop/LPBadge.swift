//
//  Badge.swift
//  loop
//
//  Created by Yecol Hsu on 28/08/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

let KEY_ICON = "icon"

class LPBadge : AVObject, AVSubclassing{
    @NSManaged var definition: String?
    @NSManaged var name:String!
    @NSManaged var smallIcon:AVFile?
    @NSManaged var icon:AVFile?
    @NSManaged var background:AVFile?
    @NSManaged var tagline:String;
//    @NSManaged var preDescription:String;
//    @NSManaged var postDescription:String;
    @NSManaged var ownerCount:NSNumber;
//    @NSManaged var minGrade:NSNumber
//    @NSManaged var maxGrade:NSNumber;
    @NSManaged var rarity:Float;
    @NSManaged var hasFavorited:Bool;
    @NSManaged var owned:Bool;
    @NSManaged var ownerList:NSArray;
    @NSManaged var postList:NSArray;
    @NSManaged var level:Int;
    @NSManaged var levelUpPercent:Float;
    @NSManaged var grantDate:Date?;
    
    static func parseClassName() -> String {
        return "Badge"
    }
    
    func displayGrantDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: self.grantDate!)
    }
}
