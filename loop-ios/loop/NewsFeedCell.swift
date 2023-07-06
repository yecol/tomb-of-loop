//
//  NewsFeedCell.swift
//  loop
//
//  Created by Yecol Hsu on 14/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit

class NewsFeedCell: UITableViewCell {

    var post4Display:PostDisplay?

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    static func calculateCellHeightWithPost(post:PostDisplay) -> CGFloat{
        return 1.0;
    }
    
    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
    }
    
    required init?(coder: NSCoder){
        super.init(coder: coder);
    }

}
