//
//  PostDisplay.swift
//  loop
//
//  Created by Yecol Hsu on 14/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

class LPPhoto: NSObject {
    var originURL: String = "";
    var thumbURL: String = "";

    convenience init(originURL: String, thumbURL: String) {
        self.init()
        self.originURL = originURL;
        self.thumbURL = thumbURL;
    }
}

class PostDisplay: NSObject {

    var username: String = "";
    var avatarUrl: String = "";
    var postTitle: String = "";
    var postContent: String = "";
    var postPhotos: NSArray = [];
    var postComment: NSArray = [];
    var likes: NSArray = [];
    var timestamp: NSDate = NSDate();

    override required init() {
        super.init();
    }
}
