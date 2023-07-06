//
//  LPPlace.swift
//  loop
//
//  Created by Yecol Hsu on 28/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

let KEY_FOURSQUARE_ID = "foursquareId"

class LPPlace: AVObject, AVSubclassing {

//    @NSManaged var creator:AVUser!; // 创建者
    @NSManaged var name: String? //地点名称
    @NSManaged var address: String? //显示地址
    @NSManaged var foursquareId: String? //fsID
    @NSManaged var iconUrl: String? //图标地址
    @NSManaged var latLng: AVGeoPoint? //地点坐标
    @NSManaged var foursquareCategoryId: String? //地点类型 fs
    @NSManaged var placeId: String

    static func parseClassName() -> String {
        return "Place"
    }
}
