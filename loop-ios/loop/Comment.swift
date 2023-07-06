//
//  Comment.swift
//  loop
//
//  Created by Yecol Hsu on 14/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

let KEY_POST = "post"
let KEY_COMMENT_USER = "commentUser"
let KEY_COMMENT_USERNAME = "commentUsername"
let KEY_COMMENT_CONTENT = "commentContent"
let KEY_TO_USER = "toUser"

class LPComment : AVObject, AVSubclassing{
    
    @NSManaged var post:Post!;//关联分享
    @NSManaged var commentUser:AVUser!;//评论用户
    @NSManaged var commentContent:String!;//评论内容
    @NSManaged var toUser:AVUser?;//关联用户
    
    static func parseClassName() -> String! {
        return "Comment"
    }
}
