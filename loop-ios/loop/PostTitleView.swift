//
//  PostTitleView.swift
//  loop
//
//  Created by Yecol Hsu on 31/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

extension TTTAttributedLabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    static func calculateHeight(post: LPPost, width: CGFloat) -> CGFloat {
//        let plainText = NSMutableString();
        let friends = post.taggedFriendList
        let clickableRanges = NSMutableArray();

        var posterRange = NSMakeRange(NSNotFound, 0);
        posterRange.location = 0;
        posterRange.length = post.creator!.displayName().length;
        clickableRanges.add(posterRange);

        let plainText = NSMutableString();
        plainText.append(post.creator!.displayName() as String);

        if (friends != nil) {
            var count = friends!.count;
            for friend in friends! as! [AVUser] {
                count -= 1;
                if (count == friends!.count - 1) {
                    plainText.append("kFeedPostWithFriends_Piece".localized);
                }
                if (friends!.count > 1 && count == 0) {
                    plainText.append("kAnd_Piece".localized)
                } else if (count != friends!.count - 1) {
                    plainText.append(", ")
                }
                var friendRange = NSMakeRange(NSNotFound, 0);
                friendRange.location = plainText.length;
                friendRange.length = friend.displayName().length;
                clickableRanges.add(friendRange);
                plainText.append(friend.displayName() as String);
            }
        }
//        print("plain text = ", plainText);

        let attributedText = NSMutableAttributedString(string: plainText as String);

        for index in 0...clickableRanges.count - 1 {
            let aRange = clickableRanges.object(at: index) as! NSRange;
            attributedText.setAttributes([NSForegroundColorAttributeName: CL_LINK_COLOR], range: aRange);
        }

        let attributedLabel = TTTAttributedLabel.init(frame: CGRect.init(x: 0, y: 0, width: width, height: 1000));

        attributedLabel.textColor = UIColor.darkGray;
        attributedLabel.font = fontSystem14;
        let attr = [NSUnderlineStyleAttributeName: false,
                    kCTForegroundColorAttributeName as AnyHashable: CL_LINK_COLOR,
                    NSFontAttributeName: fontSystem14Bold] as [AnyHashable : Any];

        attributedLabel.linkAttributes = attr;
        attributedLabel.activeLinkAttributes = attr;
        attributedLabel.lineBreakMode = .byWordWrapping;
        attributedLabel.numberOfLines = 0;

        attributedLabel.setText(attributedText, afterInheritingLabelAttributesAndConfiguringWith: { attrString in
            return attrString
        })

        for index in 0...clickableRanges.count - 1 {
            let aRange = clickableRanges.object(at: index) as! NSRange;
            var user: AVUser;
            if (index == 0) {
                user = post.creator!;
            } else {
                user = friends![index - 1] as! AVUser;
            }
            attributedLabel.addLink(to: URL(string: (user.objectId! as String)), with: aRange);
        }

        return attributedLabel.sizeThatFits(CGSize(width: width, height: 1000)).height;
    }


    func setUserWithFriends(poster: AVUser, friends: NSArray?) {

        self.numberOfLines = 0;

        let clickableRanges = NSMutableArray();

        var posterRange = NSMakeRange(NSNotFound, 0);
        posterRange.location = 0;
        posterRange.length = poster.displayName().length;
        clickableRanges.add(posterRange);

        let plainText = NSMutableString();
        plainText.append(poster.displayName() as String);

        if (friends != nil) {
            var count = friends!.count;
            for friend in friends! as! [AVUser] {
                count -= 1;
                if (count == friends!.count - 1) {
                    plainText.append("kFeedPostWithFriends_Piece".localized);
                }
                if (friends!.count > 1 && count == 0) {
                    plainText.append("kAnd_Piece".localized)
                } else if (count != friends!.count - 1) {
                    plainText.append(", ")
                }
                var friendRange = NSMakeRange(NSNotFound, 0);
                friendRange.location = plainText.length;
                friendRange.length = friend.displayName().length;
                clickableRanges.add(friendRange);
                plainText.append(friend.displayName() as String);
            }
        }

        let attributedText = NSMutableAttributedString(string: plainText as String);

        for index in 0...clickableRanges.count - 1 {
            let aRange = clickableRanges.object(at: index) as! NSRange;
            attributedText.setAttributes([NSForegroundColorAttributeName: CL_LINK_COLOR], range: aRange);
        }

        self.setText(attributedText, afterInheritingLabelAttributesAndConfiguringWith: { attrString in
            return attrString
        })

        for index in 0...clickableRanges.count - 1 {
            let aRange = clickableRanges.object(at: index) as! NSRange;
            var user: AVUser;
            if (index == 0) {
                user = poster;
            } else {
                user = friends![index - 1] as! AVUser;
            }
            self.addLink(to: URL(string: (user.objectId! as String)), with: aRange);
        }
    }


    func calculateHeight(_ width: CGFloat) -> CGFloat {
        return self.sizeThatFits(CGSize(width: width, height: 1000)).height;
    }
}
