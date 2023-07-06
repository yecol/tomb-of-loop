//
//  const.swift
//  loop
//
//  Created by Yecol Hsu on 26/08/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation
import UIKit

// Device Constants
let kScreenW = UIScreen.main.bounds.size.width;
let kScreenH = UIScreen.main.bounds.size.height;


// UI Colors
let CL_GREEN_BG = UIColor(red: 5.0 / 255, green: 203.0 / 255, blue: 149.0 / 255, alpha: 1)
let CL_GREEN_DEFAULT = UIColor(red: 4.0 / 255, green: 177.0 / 255, blue: 120.0 / 255, alpha: 1)
let CL_GREEN_LIGHT = UIColor(red: 244.0 / 255, green: 252.0 / 255, blue: 234.0 / 255, alpha: 1)
let CL_GREEN_ASSISTANCE = UIColor(red: 137.0 / 255, green: 209.0 / 255, blue: 146.0 / 255, alpha: 1)

let CL_GREY_BORDER_6C = UIColor(red: 204.0 / 255, green: 204.0 / 255, blue: 204.0 / 255, alpha: 1)
let CL_GREY_BG_EC = UIColor(red: 236.0 / 255, green: 236.0 / 255, blue: 236.0 / 255, alpha: 1)

let CL_BLACK_GRACE = UIColor(red: 74.0 / 255, green: 74.0 / 255, blue: 74.0 / 255, alpha: 1)
let CL_LINK_COLOR = UIColor(red: 0.0 / 255, green: 0.0 / 255, blue: 0.0 / 255, alpha: 1)


let CL_GREY_NAVIBAR = UIColor(red: 250.0 / 255, green: 250.0 / 255, blue: 250.0 / 255, alpha: 0.9)
let CL_GREY_SHADOW = UIColor(red: 170.0 / 255, green: 170.0 / 255, blue: 170.0 / 255, alpha: 0.4)
let CL_GREY_FONT = UIColor(red: 153.0 / 255, green: 153.0 / 255, blue: 153.0 / 255, alpha: 1.0)
let CL_GREY_CARDBG = UIColor(red: 248.0 / 255, green: 248.0 / 255, blue: 248.0 / 255, alpha: 1.0)

let CL_LIKE_SELECT = UIColor(red: 252.0 / 255, green: 132.0 / 255, blue: 106.0 / 255, alpha: 1)
let CL_BADGE_LIKE_SELECT = UIColor(red: 244.0 / 255, green: 169.0 / 255, blue: 30.0 / 255, alpha: 1)
let CL_BADGEFAV_SELECT = UIColor(red: 215.0 / 255, green: 240.0 / 255, blue: 192.0 / 255, alpha: 0.6)


let FL_CONNER_RADIUS: CGFloat = 5.0;
let FL_SEPARATOR_HEIGHT: CGFloat = 12.0;
let FL_PADDING: CGFloat = 12;


// Data quality
let kPostPhotoMaxWidth: CGFloat = 1000.0;
let kAvatarMaxWidth: CGFloat = 600.0;
let kPostPhotoJPEGQuality: CGFloat = 0.6;

let kSchemeProfile = "scheme://profile&id=";
let kSchemeBadge = "scheme://badge&id=";


// Fonts
let fontSystem12 = UIFont.systemFont(ofSize: 12);
let fontSystem14 = UIFont.systemFont(ofSize: 14);
let fontSystem16 = UIFont.systemFont(ofSize: 16);
let fontSystem12Bold = UIFont.boldSystemFont(ofSize: 12);
let fontSystem14Bold = UIFont.boldSystemFont(ofSize: 14);
let fontSystem16Bold = UIFont.boldSystemFont(ofSize: 16);
let fontSystem18Bold = UIFont.boldSystemFont(ofSize: 18);
let fontSystem16SemiBold = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold);

let fontMontserrat12 = UIFont(name: "Montserrat", size: 12)!
let fontMontserrat14 = UIFont(name: "Montserrat", size: 14)!
let fontMontserrat16 = UIFont(name: "Montserrat", size: 16)!
let fontMontserrat18 = UIFont(name: "Montserrat", size: 18)!
let fontMontserrat21 = UIFont(name: "Montserrat", size: 21)!
let fontMontserrat24 = UIFont(name: "Montserrat", size: 24)!
let fontMontserrat24Bold = UIFont(name:"Montserrat", size: 24)!

let fontHelveticaNeueThin48 = UIFont(name: "HelveticaNeue-Thin", size: 48)!
let fontHelveticaNeueThin36 = UIFont(name: "HelveticaNeue-Thin", size: 36)!
let fontHelveticaNeueThin24 = UIFont(name: "HelveticaNeue-Thin", size: 24)!
let fontHelveticaNeueThin18 = UIFont(name: "HelveticaNeue-Thin", size: 18)!


enum PostType {
    case textOnly
    case textImage
    case shared
}
