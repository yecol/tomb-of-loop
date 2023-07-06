//
//  AVUser+Loop.swift
//  loop
//
//  Created by Yecol Hsu on 15/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

let KEY_AVATAR = "avatar";

public extension AVUser {

    @NSManaged var avatar: AVFile?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var introduction: String?
    @NSManaged var birth: Date?
    @NSManaged var city: String?
    @NSManaged var gender:Int
    @NSManaged var postCount:Int
    @NSManaged var checkinCount: Int
    @NSManaged var favoriteBadgeCount: Int
    @NSManaged var badgeCount: Int
    @NSManaged var friendCount: Int
    @NSManaged var notificationCount: Int
    @NSManaged var relationCode: Int
    @NSManaged var badgeList: NSArray
    @NSManaged var lastKnownLocation: AVGeoPoint?;
    @NSManaged var initialized: Bool;
    @NSManaged var isBlocked: Bool;
    
    func displayName() -> NSString{
        return ((firstName ?? "") + " " + (lastName ?? "")) as NSString
    }
}
