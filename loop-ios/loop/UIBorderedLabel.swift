//
//  UIBorderedLabel.swift
//  standToMake
//
//  Created by Karl Oscar Weber on 9/13/14.
//  Copyright (c) 2014 Karl Oscar Weber. All rights reserved.
//
//  Thanks to: http://userflex.wordpress.com/2012/04/05/uilabel-custom-insets/
import UIKit

class UIBorderedLabel: UILabel {
    
    var topInset:       CGFloat = 0
    var rightInset:     CGFloat = 0
    var bottomInset:    CGFloat = 0
    var leftInset:      CGFloat = 0
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: self.topInset, left: self.leftInset, bottom: self.bottomInset, right: self.rightInset)
        self.setNeedsLayout()
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
}
