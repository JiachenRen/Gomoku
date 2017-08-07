//
//  Board.swift
//  Gobang
//
//  Created by Jiachen Ren on 8/7/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation
import UIKit

public class Board: BoardProtocol {
    var dimension: Int {
        didSet {
            self.initPieces()
            delegate?.boardDidUpdate()
        }
    }
    var delegate: BoardDelegate?
    var pieces: [[Piece?]]!
    var blackFirst: Bool = true
    var turn: Piece
    
    private func initPieces() {
        self.pieces = Array<Array<Piece?>>(
            repeatElement([Piece?](
                repeatElement(nil, count: dimension)),
                          count: dimension))
    }
    
    static var sharedInstance: Board = {
        return Board(dimension: 19)
    }()
    
    required public init(dimension: Int) {
        self.dimension = dimension
        turn = blackFirst ? .black : .white
        initPieces()
    }
    
    public func put(_ coordinate: Coordinate) {
        guard let _ = pieces[coordinate.row][coordinate.col] else {
            pieces[coordinate.row][coordinate.col] = turn
            self.turn = turn.next()
            delegate?.boardDidUpdate()
            return
        }
    }

}

public enum Piece: Int {
    case black = 0
    case white = 1
    
    func next() -> Piece {
        switch self {
        case .black: return .white
        default: return .black
        }
    }
}

protocol BoardDelegate {
    func boardDidUpdate() -> Void
}

protocol BoardProtocol {
    var dimension: Int {get set}
    var pieces: [[Piece?]]! {get}
    func put(_ : Coordinate)
}
