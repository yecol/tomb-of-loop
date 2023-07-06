//
//  PostManeger.swift
//  loop
//
//  Created by Yecol Hsu on 14/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation
import SwiftyJSON

//import RealmSwift

let KEY_CREATED_AT = "createdAt"
let KEY_UPDATED_AT = "updatedAt"
let KEY_OBJECT_ID = "objectId"


let PostRequestTypeRecommended = 0;
let PostRequestTypeFriends = 1;
let PostRequestTypeSpecific = 2;

let UserRequestTypeRecommended = 0;
let UserRequestTypeFriends = 1;

let BadgeRequestTypeHot = 0;
let BadgeRequestTypeFeatured = 1;
let BadgeRequestTypeInterested = 2;
let BadgeRequestTypeFavourited = 3;
let BadgeRequestTypeSpecific = 4;
let BadgeRequestTypeStart = 5;

let UserRelationUnknown = 0;
let UserRelationStranger = 1;
let UserRelationFollower = 2;
let UserRelationFollowee = 3;
let UserRelationFriend = 4;

let kDefaultUserNumPerPage = 50;
let kDefaultBadgeNumPerPage = 50;
let kDefaultPostNumPerPage = 10;
let kDefaultCheckInNumPerPage = 30;
let kGetAllInOnePage = 100;

enum RefreshType {
    case loadLatest; // insert at head.
    case loadMore; //append to tail
    case loadDefault;
}


class DataModelManager: NSObject {

    var cachedUsers: NSMutableDictionary?;

    static let sharedInstance = DataModelManager()

    override required init() {
        super.init()
        self.cachedUsers = NSMutableDictionary();
    }

    // cloudFunctions

    func cloudGetPostList(_ type: Int, limit: Int, max: Date?, min: Date?, specifiedUserId: String, block: @escaping
            AVArrayResultBlock) {

        var param = [
                "type": type,
                "userId": AVUser.current()!.objectId!,
                "limit": limit,
                "specifiedUserId": specifiedUserId
        ] as [String: Any]

        if (max != nil) {
            param.updateValue(max!, forKey: "maxPostTime");
        }

        if (min != nil) {
            param.updateValue(min!, forKey: "minPostTime");
        }

        AVCloud.rpcFunction(inBackground: "getPostList", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(objects as? [Any], nil);
                    }
                });
    }

    func cloudGetPostList(type: Int, limit: Int, maxPostTime: Date?, minPostTime: Date?, specifiedUserId: String, badgeIdArray: Array<String>?, completion: @escaping AVArrayResultBlock) {
        var params = [
                "type": type,
                "userId": AVUser.current()!.objectId!,
                "limit": limit,
                "specifiedUserId": specifiedUserId,
        ] as [String: Any]

        if maxPostTime != nil {
            params["maxPostTime"] = maxPostTime!
        }

        if minPostTime != nil {
            params["minPostTime"] = minPostTime!
        }

        if badgeIdArray != nil && badgeIdArray!.count > 0 {
            params["badgeIdList"] = badgeIdArray!
        }

        AVCloud.rpcFunction(inBackground: "getPostList", withParameters: params, block: {
            (objects: Any?, error: Error?) in
            guard error == nil else {
                completion(nil, error)
                return
            }

            completion(objects as? [Any], nil)
        });
    }

    func cloudGetCommentList(postId: String?, completion: @escaping AVArrayResultBlock) {
        guard let postId = postId else {
            return
        }

        let param = [
                "userId": AVUser.current()!.objectId!,
                "postId": postId
        ]

        AVCloud.rpcFunction(inBackground: "getCommentList", withParameters: param, block: {
            (objects: Any?, error: Error?) in

            guard error == nil else {
                completion(nil, error)
                return
            }

            completion(objects as? [Any], nil)
        });
    }

    func cloudPostComment(postId: String?, content: String?, completion: @escaping AVObjectResultBlock) {
        guard let postId = postId, let content = content else {
            return
        }

        let param = [
                "userId": AVUser.current()!.objectId!,
                "postId": postId,
                "content": content
        ]

        AVCloud.rpcFunction(inBackground: "postComment", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }

                    completion(objects as! AVObject?, nil)
                });
    }

    func cloudGetUserBadgeList(completion: @escaping AVArrayResultBlock) {
        let param: [String: Any] = [
                "specifiedUserId": AVUser.current()!.objectId!,
                "type": 4
        ]

        AVCloud.rpcFunction(inBackground: "getBadgeList", withParameters: param, block: {
            (objects: Any?, error: Error?) in
            guard error == nil else {
                completion(nil, error)
                return
            }

            completion(objects as? [Any], nil)
        });
    }

    func cloudCreatePost(message: String, photos: [String], friends: [String], badge: LPBadge?, place: LPPlace?,
                         errorPtr: NSErrorPointer) {

        var param = [
                "userId": AVUser.current()!.objectId!,
                "message": message,
                "imageIdList": photos,
                "taggedFriendIdList": friends
        ] as [String: Any]

        if (badge != nil) {
            param.updateValue(badge!.objectId!, forKey: "badgeId")
        }

        if (place != nil) {
            param.updateValue(place!.placeId, forKey: "placeId");
        }

        AVCloud.callFunction("createPost", withParameters: param, error: errorPtr);
    }

    func cloudSharePost(postId: String?, completion: @escaping AVObjectResultBlock) {

        guard let postId = postId else {
            return
        }

        let param = [
                "userId": AVUser.current()!.objectId!,
                "postId": postId,
        ]

        AVCloud.rpcFunction(inBackground: "sharePost", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }

                    completion(objects as! AVObject?, nil)
                });
    }


    func cloudGetBadgeList(_ type: Int, limit: Int, skip: Int?, specific: String, block: @escaping AVArrayResultBlock) {

        var param = [
                "type": type,
                "userId": AVUser.current()!.objectId!,
                "limit": limit,
                "specifiedUserId": specific
        ] as [String: Any]

        if (skip != nil) {
            param.updateValue(skip!, forKey: "skip");
        }

        AVCloud.rpcFunction(inBackground: "getBadgeList", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(objects as? [Any], nil);
                    }
                });
    }

    func cloudGetPostDetail(_ postId: String, block: @escaping AVIdResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "postId": postId
        ]

        AVCloud.rpcFunction(inBackground: "getPostDetail", withParameters: param,
                block: { (object: Any?, error: Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(object, nil);
                    }
                });
    }

    func cloudGetBadgeDetail(_ badgeId: String, block: @escaping AVIdResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "badgeId": badgeId
        ]

        AVCloud.rpcFunction(inBackground: "getBadgeDetail", withParameters: param,
                block: { (object: Any?, error: Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(object, nil);
                    }
                });
    }


    func cloudGetNotificationList(block: @escaping AVArrayResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
        ]

        AVCloud.rpcFunction(inBackground: "getNotificationList", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(objects as? [Any], nil);
                    }
                });
    }


    func cloudUpdateUserRelation(_ friendID: String, curRelation: Int) -> Int {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "specifiedUserId": friendID,
                "currentRelationCode": curRelation
        ] as [String: Any]

        let returnVal = AVCloud.callFunction("updateUserRelation", withParameters: param) as? Int;
        return returnVal ?? 0;
    }


//    func cloudCheckIn(_ placeId: String, block: @escaping AVBooleanResultBlock) {
//
//        let param = [
//                "userId": AVUser.current()!.objectId!,
//                "placeId": placeId
//        ]
//
//        AVCloud.rpcFunction(inBackground: "checkIn", withParameters: param,
//                block: { (objects: Any?, error: Error?) in
//                    if (error != nil) {
//                        block(false, error);
//                    } else {
//                        block(true, nil);
//                    }
//                });
//    }


    func cloudCheckIn(_ placeId: String, block: @escaping AVBooleanResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "placeId": placeId
        ]

        AVCloud.rpcFunction(inBackground: "checkIn", withParameters: param,
                block: { (object: Any?, error: Error?) in
                    if (error != nil) {
                        block(false, error);
                    } else {
                        block(true, nil);

                        guard let jsonObject = object else {
                            return;
                        }

                        let dict = jsonObject as! NSDictionary;

                        if dict["upgradeBadge"] != nil {
                            let badgeId = (dict["upgradeBadge"] as! LPBadge).objectId!;
                            UIApplication.shared.keyWindow!.rootViewController!.displayBadgeCongrats(badgeId: badgeId, grant: .upgrade);
                        }

                        if dict["grantBadge"] != nil {
                            let badgeId = (dict["grantBadge"] as! LPBadge).objectId!;
                            UIApplication.shared.keyWindow!.rootViewController!.displayBadgeCongrats(badgeId: badgeId,
                                    grant: .grant);
                        }
                    }
                });
    }


    func cloudClockIn(_ block: @escaping AVBooleanResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!
        ]

        AVCloud.rpcFunction(inBackground: "clockIn", withParameters: param,
                block: { (object: Any?, error: Error?) in
                    if (error != nil) {
                        block(false, error);
                    } else {
                        block(true, nil);

                        guard let jsonObject = object else {
                            return;
                        }

                        let dict = jsonObject as! NSDictionary;

                        if dict["upgradeBadge"] != nil {
                            let badgeId = (dict["upgradeBadge"] as! LPBadge).objectId!;
                            UIApplication.shared.keyWindow!.rootViewController!.displayBadgeCongrats(badgeId: badgeId, grant: .upgrade);
                        }

                        if dict["grantBadge"] != nil {
                            let badgeId = (dict["grantBadge"] as! LPBadge).objectId!;
                            UIApplication.shared.keyWindow!.rootViewController!.displayBadgeCongrats(badgeId: badgeId,
                                    grant: .grant);
                        }
                    }
                });
    }


    func cloudGetUserList(_ type: Int, limit: Int, skip: Int?, specific: String, block: @escaping AVArrayResultBlock) {

        var param = [
                "type": type,
                "userId": AVUser.current()!.objectId!,
                "limit": limit,
                "specifiedUserId": specific
        ] as [String: Any]

        if (skip != nil) {
            param.updateValue(skip!, forKey: "skip");
        }

        AVCloud.rpcFunction(inBackground: "getUserList", withParameters: param,
                block: { (objects: Any?, error:
                        Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(objects as! [AnyObject], nil);
                    }
                });
    }

    func cloudGetBlockedUserList(limit: Int, skip: Int?, block: @escaping AVArrayResultBlock) {

        var param = [
                "userId": AVUser.current()!.objectId!,
                "limit": limit,
        ] as [String: Any]

        if (skip != nil) {
            param.updateValue(skip!, forKey: "skip");
        }

        AVCloud.rpcFunction(inBackground: "getBlockedUserList", withParameters: param,
                block: { (objects: Any?, error:
                        Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(objects as! [AnyObject], nil);
                    }
                });
    }


    func cloudGetUserDetail(specific: String, block: @escaping AVIdResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "specifiedUserId": specific
        ] as [String: Any]

        AVCloud.rpcFunction(inBackground: "getUserDetail", withParameters: param,
                block: { (object: Any?, error:
                        Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(object, nil);
                    }
                });
    }


    func cloudGetNearbyPlacesList(_ latlng: AVGeoPoint, limit: Int, radius: Int, block: @escaping AVArrayResultBlock) {

        var param = [
                "latLng": latlng,
                "limit": limit,
                "userId": AVUser.current()!.objectId!,
        ] as [String: Any]

        AVCloud.rpcFunction(inBackground: "getNearbyPlaceList", withParameters: param,
                block: { (objects: Any?, error:
                        Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(objects as! [AnyObject], nil);
                    }
                });
    }


    func cloudPerformSearch(_ key: String, block: @escaping  AVIdResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "queryString": key
        ]

        AVCloud.rpcFunction(inBackground: "search", withParameters: param,
                block: { (object: Any?, error: Error?) in
                    guard error == nil else {
                        block(nil, error)
                        return
                    }
                    block(object, nil)
                });
    }


    func updateLatestLocation(_ latlng: AVGeoPoint) {
        if (AVUser.current() != nil) {
            AVUser.current()!.lastKnownLocation = latlng;
            AVUser.current()!.saveInBackground();
        }
    }


    func cloudFlipPostLikeState(_ post: LPPost, block: @escaping AVBooleanResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "postId": post.objectId!
        ]

        AVCloud.rpcFunction(inBackground: "flipPostLikeState", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    if (error != nil) {
                        block(false, error);
                    } else {
                        block(true, nil);
                    }
                });
    }


    func cloudReportPost(_ post: LPPost, block: @escaping AVBooleanResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "postId": post.objectId!
        ]

        AVCloud.rpcFunction(inBackground: "reportPost", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    if (error != nil) {
                        block(false, error);
                    } else {
                        block(true, nil);
                    }
                });
    }

    func cloudBlockUser(_ user: AVUser, block: @escaping AVBooleanResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "userIdToBlock": user.objectId!
        ]

        AVCloud.rpcFunction(inBackground: "blockUser", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    if (error != nil) {
                        block(false, error);
                    } else {
                        block(true, nil);
                    }
                });
    }

    func cloudUnBlockUser(_ user: AVUser, block: @escaping AVBooleanResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "userIdToUnblock": user.objectId!
        ]

        AVCloud.rpcFunction(inBackground: "unblockUser", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    if (error != nil) {
                        block(false, error);
                    } else {
                        block(true, nil);
                    }
                });
    }


    func cloudFlipBadgeFavoriteState(_ badge: LPBadge, block: @escaping AVBooleanResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "badgeId": badge.objectId!
        ]

        AVCloud.rpcFunction(inBackground: "flipBadgeFavoriteState", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    if (error != nil) {
                        block(false, error);
                    } else {
                        block(true, nil);
                    }
                });
    }

    func cloudGetCheckInList(_ limit: Int, max: Date?, block: @escaping  AVArrayResultBlock) {

        var param = [
                "userId": AVUser.current()!.objectId!,
                "limit": limit,
        ] as [String: Any]

        if (max != nil) {
            param.updateValue(max!, forKey: "maxCheckinTime");
        }

        AVCloud.rpcFunction(inBackground: "getCheckinList", withParameters: param,
                block: { (objects: Any?, error:
                        Error?) in
                    if (error != nil) {
                        block(nil, error);
                    } else {
                        block(objects as! [AnyObject], nil);
                    }
                });
    }


    typealias AVUserHandleBlock = (AVUser) -> Void;

/*!
 *  找出 Album 里相关的所有 User，这些 User只有 objectId，没有 username 等数据
 */
    func iterateUsersInPosts(_ posts: NSArray, block: AVUserHandleBlock) {

        for post in posts as! [LPPost] {

            if ((post.creator) != nil) {
                block(post.creator);
            }
            if (post.likedUserList != nil) {
                for likeUser in post.likedUserList as! [AVUser] {
                    block(likeUser);
                }
            }
            if (post.commentPreviewList != nil) {
                for comment in post.commentPreviewList! as! [LPComment] {
                    block(comment.user);
                }
            }
        }
    }

//
/*!
 *  填充 username,createdAt 等数据
 */

    func fillPointerUser(_ pointerUser: AVUser) {

        let fullUser = self.lookUpUserById(pointerUser.objectId!);
        if (fullUser != nil) {
            let o: [NSObject: AnyObject] = fullUser!.dictionaryForObject() as [NSObject: AnyObject];
            pointerUser.object(from: o);
        }
    }

//#pragma mark - User Cache
//
    func lookUpUserById(_ objectId: String) -> AVUser? {
        return self.cachedUsers?[objectId] as? AVUser;
    }


    func addUserToCache(_ user: AVUser) {
        self.cachedUsers?[user.objectId!] = user;
    }


    func getObjectIds(_ avObjects: NSArray) -> NSArray {
        let objectIds = NSMutableArray();
        for object in avObjects as! [AVObject] {
            objectIds.add(object.objectId!)
        }
        return objectIds;
    }


    func commentToUser(_ toUser: AVUser?, post: LPPost, content: String, block: @escaping AVBooleanResultBlock) {
        let comment = LPComment();
        comment.content = content;
        comment.user = AVUser.current()!;
//        comment.toUser = toUser;
        comment.post = post;

        comment.saveInBackground { succeeded, error in
            if (error != nil) {
                block(false, error);
            } else {
                post.add(comment, forKey: KEY_COMMENTS);
                block(true, nil);
//                post.saveInBackgroundWithBlock(block)
            }
        }
    }


    func savePlaceIfNotExist(_ place: LPPlace) -> LPPlace {

        let placeQuery = LPPlace.query();
        placeQuery.whereKey(KEY_FOURSQUARE_ID, equalTo: place.foursquareId!);
        var savedPlace = placeQuery.getFirstObject() as? LPPlace
        if (savedPlace == nil) {
            savedPlace = LPPlace();
            savedPlace!.name = place.name;
            savedPlace!.address = place.address;
            savedPlace!.foursquareId = place.foursquareId;
            savedPlace!.foursquareCategoryId = place.foursquareCategoryId;
            savedPlace!.iconUrl = place.iconUrl;
            savedPlace!.latLng = place.latLng;
            savedPlace!.save();
        }
        return savedPlace!
    }

    func localStoreNotification(_ userInfo: NSDictionary) {
//        let notification = JSON(userInfo);
//        let lpNotification = notification["aps"]["alert"]
//        print(notification);
    }

    func cloudSetupStarterBadgeList(_ badgeIdList: NSArray, block: @escaping AVBooleanResultBlock) {

        let param = [
                "userId": AVUser.current()!.objectId!,
                "badgeIdList": badgeIdList
        ] as [String: Any]

        AVCloud.rpcFunction(inBackground: "setUpStarterBadgeList", withParameters: param,
                block: { (objects: Any?, error: Error?) in
                    if (error != nil) {
                        block(false, error);
                    } else {
                        block(true, nil);
                    }
                });
    }

}
