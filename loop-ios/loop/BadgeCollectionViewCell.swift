//
//  BadgeCollectionViewCell.swift
//  loop
//
//  Created by Yecol Hsu on 07/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import Cartography

let kBadgeCell = "badgecell";
let kBadgeCellHeight:CGFloat = 100;
let kBadgeCellBadgeSize:CGFloat = 60;
let kBadgeCellInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

class BadgeCell: UICollectionViewCell {
    
    var nameLabel: UILabel?
    var detailLabel: UILabel?
    var badgeImageView: UIImageView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.nameLabel = UILabel();
        self.nameLabel!.textColor = CL_BLACK_GRACE;
        self.nameLabel!.font = fontSystem14Bold;
        self.detailLabel = UILabel();
        self.detailLabel!.textColor = CL_GREY_FONT;
        self.detailLabel!.font = fontSystem12;
        self.badgeImageView = UIImageView(image: UIImage(named: "badge-ph"));
        self.badgeImageView!.contentMode = .scaleAspectFill;
        
        self.contentView.addSubview(self.badgeImageView!);
        self.contentView.addSubview(self.nameLabel!);
        self.contentView.addSubview(self.detailLabel!);
        //self.contentView.backgroundColor = UIColor.yellowColor();
    }
    
    func setData(_ badgeName: String, badgeImageURL: String, badgeDetail: String){
        self.nameLabel!.text = badgeName;
        self.badgeImageView!.sd_setImage(with: URL(string: badgeImageURL), placeholderImage: UIImage(named: "badge-ph"));
        self.detailLabel!.text = badgeDetail;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        constrain(self.nameLabel!, self.badgeImageView!, self.detailLabel!, block: {
        name, image, detail in
            image.width == kBadgeCellBadgeSize;
            image.height == kBadgeCellBadgeSize;
            image.centerX == image.superview!.centerX;
            image.centerY == image.superview!.centerY - 20;
            
            name.centerX == image.centerX;
            name.top == image.bottom + 10;
            
            detail.centerX == image.centerX;
            detail.top == name.bottom + 4;
        })
    }
}
