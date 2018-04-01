//
//  MenuIconView.swift
//  Gobang
//
//  Created by Jiachen Ren on 12/10/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

@IBDesignable class MenuIconView: UIView {

    @IBInspectable var iconColor: UIColor = UIColor.blue
    @IBInspectable var iconLineWidth: CGFloat = 5
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        iconColor.setStroke()
        pathForIcon().stroke()
        
    }
 
    private func pathForIcon() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.origin.x + iconLineWidth / 2, y: bounds.origin.y + iconLineWidth * 3 / 2 ))
        path.addLine(to: CGPoint(x: bounds.maxX - iconLineWidth / 2 - 5, y: bounds.origin.y + iconLineWidth * 3 / 2))

        path.move(to: CGPoint(x: bounds.origin.x + iconLineWidth / 2, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX - iconLineWidth / 2, y: bounds.midY))
        
        path.move(to: CGPoint(x: bounds.origin.x + iconLineWidth / 2, y: bounds.maxY - iconLineWidth * 3 / 2))
        path.addLine(to: CGPoint(x: bounds.maxX - iconLineWidth / 2 - 10, y: bounds.maxY - iconLineWidth * 3 / 2))
        
        path.lineWidth = iconLineWidth
        path.lineCapStyle = .round
        return path
    }

}
