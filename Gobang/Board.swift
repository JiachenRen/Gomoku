//
//  Board.swift
//  Gobang
//
//  Created by Jiachen Ren on 8/7/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

public class Board: BoardProtocol {
    var dimension: Int
    var delegate: BoardDelegate?
    
    static var sharedInstance: Board {
        return Board(dimension: 19)
    }
    
    required public init(dimension: Int) {
        self.dimension = dimension
    }

}

protocol BoardDelegate {
    func boardDidUpdate() -> Void
}

protocol BoardProtocol {
    var dimension: Int {get set}
}
