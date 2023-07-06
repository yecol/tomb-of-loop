//
//  Post.swift
//  loop
//
//  Created by Yecol Hsu on 14/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

let KEY_CLS = "cls";
let KEY_POST_TYPE = "postType"
let KEY_POST_CONTENT = "message"
let KEY_POST_PHOTOS = "imageList"
let KEY_LIKE_USERS = "likedUserList"
let KEY_TAGGED_FRIENDS = "taggedFriendList"
let KEY_COMMENTS = "commentList"
let KEY_COMMENT_PREVIEW_LIST = "commentPreviewList"
let KEY_IS_DEL = "isDel"
let KEY_CREATOR = "creator"
let KEY_BADGE = "badge"
let KEY_PLACE = "place"

class LPPost: AVObject, AVSubclassing {

    @NSManaged var creator: AVUser!; // 创建者
    @NSManaged var message: String? //分享内容
    @NSManaged var taggedFriendList: NSArray?; //taggedFriends _User Array
    @NSManaged var imageList: NSArray?; //分享照片 _File Array
    @NSManaged var likedUserList: NSArray?; //赞过的人 _User Array
    @NSManaged var commentPreviewList: NSArray?;
    @NSManaged var commentList:NSArray?;
    @NSManaged var badge: LPBadge?;// badge
    @NSManaged var place: LPPlace?;
    @NSManaged var hasLiked: Bool;
    @NSManaged var likeCount: NSNumber?;
    @NSManaged var commentCount: NSNumber?;
    @NSManaged var isDel: NSNumber?; //是否删除
    @NSManaged var type: NSNumber?; // post type
    @NSManaged var sharedBy: AVUser?;
    @NSManaged var sharedAt: Date?;

    static func parseClassName() -> String {
        return "Post"
    }

    // members and functions used locally.
    fileprivate var _displayType: PostType?;

    var displayType: PostType {
        get {
            if (_displayType == nil) {
                if(self.imageList == nil || self.imageList?.count == 0){
                    _displayType = PostType.textOnly;
                }
                else{
                    _displayType = PostType.textImage;
                }
            }
            return _displayType!;
        }
    }

}
