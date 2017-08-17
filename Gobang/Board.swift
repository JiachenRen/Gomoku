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
    var intelligence: Intelligence? {
        didSet {
            //give the AI the chance to make a move if it needs to move first.
            if let intel = intelligence, intel.color == self.turn {
                intel.makeMove(breadth: searchBreadth, depth: searchDepth)
            }
        }
    }
    var delegate: BoardDelegate?
    var pieces: [[Piece?]]!
    var blackFirst: Bool = true
    var turn: Piece
    var searchBreadth = 10
    var searchDepth = 3
    var lastMoves = [Coordinate]()
    var reverted = [Coordinate]()
    
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
            lastMoves.append(coordinate)
            self.turn = turn.next()
            delegate?.boardDidUpdate()
            
            // give the AI the chance to make a move, if one exists.
            if let intel = intelligence, intel.color == self.turn {
                 intel.makeMove(breadth: searchBreadth, depth: searchDepth)
            }
            return
        }
    }
    
    public func revert() {
        if lastMoves.count == 0 {return}
        self.turn = self.turn.next()
        let co = lastMoves.removeLast()
        reverted.append(co)
        pieces[co.row][co.col] = nil
        delegate?.boardDidUpdate()
    }
    
    public func restore() {
        if reverted.count == 0 {return}
        let co = reverted.removeLast()
        put(co)
        delegate?.boardDidUpdate()
    }
    
    public func get(_ co: Coordinate) -> Piece? {
        return pieces[co.row][co.col]
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
