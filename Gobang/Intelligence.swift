//
//  Intelligence.swift
//  Gobang
//
//  Created by Jiachen Ren on 8/12/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation
import UIKit

class Intelligence {
    var color: Piece
    var board: Board {
        return Board.sharedInstance
    }
    typealias Move = (score: Double, co: Coordinate)
    
    required init(color: Piece) {
        self.color = color
    }
    
    public func makeMove(breadth: Int, depth: Int) {
        if board.lastMoves.count == 0 {
            board.put((9, 9))
            return
        }
        board.put(self.random())
    }
    
    private func random() -> Coordinate {
        let row = CGFloat.random(min: 0, max: CGFloat(board.pieces.count))
        let col = CGFloat.random(min: 0, max: CGFloat(board.pieces[0].count))
        return (col: Int(col), row: Int(row))
    }
}

public func +(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
    return (lhs.col + rhs.col, lhs.row + rhs.row)
}
