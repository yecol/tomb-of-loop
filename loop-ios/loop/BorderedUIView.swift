//
//  BtmBorderUIView.swift
//  loop
//
//  Created by Yecol Hsu on 07/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit

class BorderedUIView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
     */
    override func draw(_ rect: CGRect) {
        
        self.backgroundColor = UIColor.white;
        
        let vPath = UIBezierPath(rect: CGRect(x: 0, y: rect.height-1, width: rect.width, height: 1))
        let vlayer = CAShapeLayer()
        vlayer.path = vPath.cgPath
        vlayer.fillColor = CL_GREY_BORDER_6C.cgColor
        self.layer.addSublayer(vlayer)
        
        
        let uPath = UIBezierPath(rect: CGRect(x: 0 , y: 0, width: rect.width, height: 1))
        let ulayer = CAShapeLayer()
        ulayer.path = uPath.cgPath
        ulayer.fillColor = CL_GREY_BORDER_6C.cgColor
        self.layer.addSublayer(ulayer)
    }
}
