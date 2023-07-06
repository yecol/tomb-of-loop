//
//  SectionTitleView.swift
//  loop
//
//  Created by Yecol Hsu on 19/02/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit
import SnapKit

fileprivate let kPadding = 12;

class SectionTitleView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var titleLabel = UILabel();
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.titleLabel.textColor = CL_GREY_FONT;
        self.titleLabel.font = fontMontserrat12;
        self.addSubview(self.titleLabel);
        
        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.top).offset(kPadding)
            make.left.equalTo(self.snp.left).offset(kPadding)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(title: String){
        self.titleLabel.text = title;
    }
    
    
}
