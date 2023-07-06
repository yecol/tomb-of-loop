//
//  LPPhoto.swift
//  loop
//
//  Created by Yecol Hsu on 20/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit

class LPPhoto: NSObject {

    var originURL: String = "";
    var thumbURL: String = "";

    convenience init(originURL: String, thumbURL: String) {
        self.init()
        self.originURL = originURL;
        self.thumbURL = thumbURL;
    }
}
