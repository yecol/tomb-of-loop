//
//  SubClasses.swift
//  loop
//
//  Created by Yecol Hsu on 12/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation
import UIKit

class BtmLinedUIView: UIView {
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     */
    override func draw(_ rect: CGRect) {
        
        self.backgroundColor = UIColor.white;
        let vPath = UIBezierPath(rect: CGRect(x: 0, y: rect.height-1, width: rect.width, height: 1))
        let vlayer = CAShapeLayer()
        vlayer.path = vPath.cgPath
        vlayer.fillColor = CL_GREY_BG_EC.cgColor
        self.layer.addSublayer(vlayer)
    }
}

class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSFontAttributeName: font],
                                                                    context: nil).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
}
