//
//  BoardView.swift
//  Gobang
//
//  Created by Jiachen Ren on 8/7/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

@IBDesignable class BoardView: UIView {
    
    @IBInspectable var boardColor: UIColor = UIColor.orange
    @IBInspectable var boardCornerOffset: CGFloat = 5
    var dimension: Int = 19 { //since the rows and cols of the board are always going to be the same.
        didSet {
            //do stuff to update dimension of the view.
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        //draws the background for the board;
        boardColor.setFill()
        UIBezierPath(rect: self.bounds).fill()
    }
    

}
