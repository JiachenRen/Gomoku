//
//  Board.swift
//  Gobang
//
//  Created by Jiachen Ren on 8/7/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation
import UIKit

public class Board: BoardProtocol, CustomStringConvertible {
    public var description: String {
        get {
            var str = ""
            self.pieces.forEach { row in
                row.forEach {col in
                    switch col {
                    case .none: str += "- "
                    case .some(let color):
                        switch color {
                        case .black: str += "* "
                        case .white: str += "o "
                        }
                    }
                }
                str += "\n"
            }
            
            return str
        }
    }
    
    var availableSpacesMap: String {
        get {
            var str = ""
            for row in self.availableCos {
                for piece in row {
                    str += piece ? "x " : "- "
                }
                str += "\n"
            }
            return str
        }
    }
    
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
                intel.makeMove()
            }
        }
    }
    
    var aiStatus: String = "pending..." {
        didSet {
            delegate?.aiStatusDidUpdate()
        }
    }
    var delegate: BoardDelegate?
    var pieces: [[Piece?]]!
    var blackFirst: Bool = true
    var turn: Piece
    var lastMoves = [Coordinate]()
    var reverted = [Coordinate]()
    var availableCos: [[Bool]]!
    var coStack = [[(Coordinate, Bool)]]()
    var locked: Bool = false
    var displayDigits: Bool = false
    
    var dummyIntelligence = Intelligence(color: .black, depth: 0)
    
    let debugOn = false
    
    private func initPieces() {
        self.availableCos = [[Bool]](repeatElement([Bool](repeatElement(false, count: dimension)), count: dimension))
        self.pieces = Array<Array<Piece?>>(
            repeatElement([Piece?](
                repeatElement(nil, count: dimension)),
                          count: dimension))
    }
    
    public func reset() {
        initPieces()
        coStack = [[(Coordinate, Bool)]]()
        reverted = [Coordinate]()
        lastMoves = [Coordinate]()
        turn = blackFirst ? .black : .white
        self.locked = false
        if let intel = self.intelligence, intel.color == turn {
            intel.makeMove()
        } else {
            place((col: 0, row: 0))
            revert(notify: true)
        }
        clearBoardStatus()
        self.delegate?.boardDidUpdate()
    }
    
    public func spawnPseudoPieces() {
        self.initPieces()
        for row in 0..<dimension {
            for col in 0..<dimension {
                switch Int(CGFloat.random(min: 0, max: 3)) {
                case 0: pieces[row][col] = .black
                case 1: pieces[row][col] = .white
                default: break
                }
            }
        }
        
    }
    
    static var sharedInstance: Board = {
        let retrieved = retrieveFromUserDefualt(key: "dimension")
        return Board(dimension: retrieved == nil ? 19 : retrieved as! Int)
    }()
    
    required public init(dimension: Int) {
        self.dimension = dimension
        turn = blackFirst ? .black : .white
        initPieces()
    }
    
    //for placing an actual move
    public func put(_ coordinate: Coordinate) {
        if self.locked {return}
        guard let _ = pieces[coordinate.row][coordinate.col] else {
            pieces[coordinate.row][coordinate.col] = turn
            self.updateAvailableCos(coordinate)
            lastMoves.append(coordinate)
            self.turn = turn.next()
            delegate?.boardDidUpdate()
            updateBoardStatus()
            if (debugOn) {
                print(self, terminator: "\n")
                print(self.availableSpacesMap)
            }
            
            // give the AI the chance to make a move, if one exists.
            if let intel = intelligence, intel.color == self.turn {
                self.aiStatus = "thinking..."
                DispatchQueue.main.async {[unowned self] in
                    intel.makeMove()
                    self.updateBoardStatus()
                }
            }
            return
        }
    }
    
    private func updateBoardStatus() {
        dummyIntelligence.color = .black
        let blackScore = dummyIntelligence.linearEval()
        
        dummyIntelligence.color = .white
        let whiteScore = dummyIntelligence.linearEval()
        if blackScore >= Score.MAX {
            self.locked = true
            delegate?.boardStatusUpdated(msg: "black wins!", data: findWinningCos())
        } else if whiteScore >= Score.MAX {
            self.locked = true
            delegate?.boardStatusUpdated(msg: "white wins!", data: findWinningCos())
        } else if blackScore == whiteScore {
            delegate?.boardStatusUpdated(msg: "draw", data: nil)
        } else if blackScore > whiteScore {
            delegate?.boardStatusUpdated(msg: "black is up by \(blackScore - whiteScore) points", data: nil)
        } else {
            delegate?.boardStatusUpdated(msg: "white is up by \(whiteScore - blackScore) points", data: nil)
        }
    }
    
    public func findWinningCos() -> [Coordinate] {
        var winningCos = [Coordinate]()
        let row = lastMoves.last!.row, col = lastMoves.last!.col
        let color = pieces[row][col]
        (-4...0).forEach {
            var i = $0, buff = [Coordinate]()
            
            //vertical
            for q in i...(i+4) {
                let co = Coordinate(col: col + q, row: row)
                if !isValid(co: co) || pieces[co.row][co.col] == nil || pieces[co.row][co.col] != color {
                    buff.removeAll()
                    break
                }
                buff.append(co)
            }
            winningCos.append(contentsOf: buff)
            buff.removeAll()
            
            //horizontal
            for q in i...(i+4) {
                let co = Coordinate(col: col, row: row + q)
                if !isValid(co: co) || pieces[co.row][co.col] == nil || pieces[co.row][co.col] != color {
                    buff.removeAll()
                    break
                }
                buff.append(co)
            }
            winningCos.append(contentsOf: buff)
            buff.removeAll()
            
            //diagnol slope = 1
            for q in i...(i+4) {
                let co = Coordinate(col: col + q, row: row + q)
                if !isValid(co: co) || pieces[co.row][co.col] == nil || pieces[co.row][co.col] != color {
                    buff.removeAll()
                    break
                }
                buff.append(co)
            }
            winningCos.append(contentsOf: buff)
            buff.removeAll()
            
            //diagnol slope = -1
            for q in i...(i+4) {
                let co = Coordinate(col: col + q, row: row - q)
                if !isValid(co: co) || pieces[co.row][co.col] == nil || pieces[co.row][co.col] != color {
                    buff.removeAll()
                    break
                }
                buff.append(co)
            }
            winningCos.append(contentsOf: buff)
            buff.removeAll()
        }
        return winningCos
    }
    
    public func updateAvailableCos(_ co: Coordinate) {
        var stack = [(Coordinate, Bool)]()
        func apply(_ c: Coordinate, _ stack: inout [(Coordinate, Bool)]) {
            if isValid(co: c) {
                let empty = pieces[c.row][c.col] == .none
                if availableCos[c.row][c.col] != empty {
                    availableCos[c.row][c.col] = empty
                    stack.append((c, empty))
                }
            }
        }
        (-2...2).forEach { offset in
            apply(Coordinate(col: co.col + offset, row: co.row + offset), &stack)
            apply(Coordinate(col: co.col + offset, row: co.row - offset), &stack)
            apply(Coordinate(col: co.col + offset, row: co.row), &stack)
            apply(Coordinate(col: co.col, row: co.row + offset), &stack)
        }
        apply(co, &stack)
        coStack.append(stack)
    }
    
    public func refreshAvailabelCos() {
        self.availableCos = [[Bool]](repeatElement([Bool](repeatElement(false, count: dimension)), count: dimension))
        for row in 0..<self.pieces.count {
            for col in 0..<self.pieces[0].count {
                if self.pieces[row][col] != nil {
                    self.updateAvailableCos(Coordinate(col: col, row: row))
                }
            }
        }
    }
    
    public func isValid(co: Coordinate) -> Bool {
        return co.col >= 0 && co.row >= 0 && co.col < self.dimension && co.row < self.dimension
    }
    
    //for Intelligence
    public func place(_ coordinate: Coordinate) {
        guard let _ = pieces[coordinate.row][coordinate.col] else {
            pieces[coordinate.row][coordinate.col] = turn
            self.updateAvailableCos(coordinate)
            lastMoves.append(coordinate)
            self.turn = turn.next()
            return
        }
    }
    
    public func revert(notify: Bool) {
        if lastMoves.count == 0 {return}
        self.turn = self.turn.next()
        
        let co = lastMoves.removeLast()
        pieces[co.row][co.col] = nil
        
        //restore changes made to the coordinates map
        for (co, _) in coStack.removeLast() {
            availableCos[co.row][co.col] = !availableCos[co.row][co.col]
        }
        
        if notify {
            delegate?.boardDidUpdate()
            clearBoardStatus()
            reverted.append(co)
            self.locked = false
        }
    }
    
    public func clearBoardStatus() {
        delegate?.boardStatusUpdated(msg: "pending...", data: [Coordinate]())
    }
    
    public func restore() {
        if reverted.count == 0 {return}
        let co = reverted.removeLast()
        self.put(co)
        delegate?.boardDidUpdate()
    }
    
    public func clearReverted() {
        reverted.removeAll()
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
    func aiStatusDidUpdate() -> Void
    func boardStatusUpdated(msg: String, data: Any?) -> Void
}

protocol BoardProtocol {
    var dimension: Int {get set}
    var pieces: [[Piece?]]! {get}
    func put(_ : Coordinate)
}
