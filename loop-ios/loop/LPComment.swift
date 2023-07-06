//
//  Comment.swift
//  loop
//
//  Created by Yecol Hsu on 14/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation

let KEY_POST = "post"
//let KEY_COMMENT_USER = "commentUser"
//let KEY_COMMENT_USERNAME = "commentUsername"
//let KEY_COMMENT_CONTENT = "commentContent"
//let KEY_TO_USER = "toUser"

class LPComment: AVObject, AVSubclassing {

    @NSManaged var post: LPPost;//关联分享
    @NSManaged var user: AVUser;//评论用户
    @NSManaged var content: String;//评论内容
//    @NSManaged var toUser:AVUser!;//关联用户

    static func parseClassName() -> String {
        return "Comment"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    var postTime: String {
        get {
            guard let time = self.createdAt else {
                return ""
            }
            
            return LPComment.dateFormatter.string(from: time)
        }
    }
    

    //local use
//    var fromUsername: NSString = "";
//    var toUsername: NSString = "";

    fileprivate var _fromUserRange: NSRange?;
//    private var _toUserRange: NSRange?;
    fileprivate var _fullText: NSString?

    var fromUserRange: NSRange {
        get {
            if(_fromUserRange == nil) {
                self.buildComment()
            }
            return _fromUserRange!
        }
    }

//    var toUserRange: NSRange {
//        get {
//            if(_toUserRange == nil) {
//                self.buildComment()
//            }
//            return _toUserRange!
//        }
//    }

    var fullText: NSString {
        get {
            if(_fullText == nil) {
                self.buildComment();
            }
            return _fullText!;
        }
    }

    fileprivate func buildComment() {

        let text = NSMutableString();

        var fromRange = NSMakeRange(NSNotFound, 0);
//        if (self.fromUsername != "") 
        text.append(self.user.displayName() as String);
        fromRange.location = 0;
        fromRange.length = self.user.displayName().length;

//        var toRange = NSMakeRange(NSNotFound, 0);
//        if (self.toUsername != "") {
//            text.appendString("Reply");
//            toRange.location = text.length;
//            toRange.length = self.toUsername.length;
//            text.appendString(self.toUsername as String);
//        }
        if (self.content != "") {
            text.append(": ");
            text.append(content);
        }

        _fromUserRange = fromRange;
//        _toUserRange = toRange;
        _fullText = text;

    }

}
