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
    typealias Move = (score: Int, co: Coordinate)
    let depth: Int
    
    static let terminalMax = 100000
    let TERMINAL_MAX = Intelligence.terminalMax
    
    //fives
    var fives = 0
    var pokedFives = 0
    
    //fours
    var blockedFour = 0
    var freeFour = 0
    var freePokedFour = 0
    var blockedPokedFour = 0
    
    //threes
    var blockedThree = 0
    var freeThree = 0
    var freePokedThree = 0
    var blockedPokedThree = 0
    
    //twos
    var freeTwo = 0
    var blockedTwo = 0
    
    var freeOne = 0
    
    var bestMove: Move?
    
    var opponent: Intelligence!
    
    required init(color: Piece, depth: Int) {
        self.color = color
        self.depth = depth
    }
    
    private func initOpponent() {
        opponent = Intelligence(color: self.color.next(), depth: self.depth)
    }
    
    public func makeMove() {
        self.initOpponent() //initialize virtual opponent
        opponent.initOpponent()
        if board.lastMoves.count == 0 {
            let ctr = board.dimension / 2
            board.put((ctr, ctr))
            return
        }
        if board.lastMoves.count == 1 {
            let offsets = [
                Coordinate(0, 1), Coordinate(0, -1), Coordinate(1, 0),
                Coordinate(-1, 0), Coordinate(1, 1), Coordinate(-1, -1),
                Coordinate(1, -1), Coordinate(-1, 1)
            ]
            let index = Int(CGFloat.random(min: 0, max: CGFloat(offsets.count)))
            board.put(board.lastMoves[0] + offsets[index])
        } else if depth == -1 {
            board.put(self.getBalancedMove().co)
        }  else {
            //extrapolate best move
            board.aiStatus = "extrapolating best move..."
            let _ = self.minimax(self.depth, maximizingPlayer: true, alpha: 0, beta: 0)
            if bestMove == nil {
                board.aiStatus = "You won. I quit!"
                return
            }
            if bestMove!.score <= -TERMINAL_MAX {
                board.put(self.getBalancedMove().co)
                board.aiStatus = "losing..."
                self.bestMove = nil
                return
            }
            board.put(self.bestMove!.co)
            board.aiStatus = "waiting..."
            self.bestMove = nil
        }
    }
    
    func getBalancedMove() -> Move  {
        let staticEvalScoreSelf = self.linearEval() - opponent.linearEval()
        let staticEvalScoreOpponent = -staticEvalScoreSelf
        
        board.turn = board.turn.next()
        let oppoBestMove = opponent.getBestMoves()[0]
        board.place(oppoBestMove.co)
        let oppoScoreChange = opponent.linearEval() - self.linearEval() - staticEvalScoreOpponent
        board.revert(notify: false)
        
        board.aiStatus = "opponent score: \(oppoBestMove.score)"
        board.turn = board.turn.next()
        
        let myBestMove = self.getBestMoves()[0]
        board.place(myBestMove.co)
        let selfScoreChange = self.linearEval() - opponent.linearEval() - staticEvalScoreSelf
        board.revert(notify: false)
        
        if myBestMove.score >= Intelligence.terminalMax {
            board.aiStatus = "winning..."
            return myBestMove
        }
        board.aiStatus = oppoScoreChange > selfScoreChange ? "defending..." : "attacking..."
        
        return oppoScoreChange > selfScoreChange ? oppoBestMove : myBestMove
    }
    
//    function minimax(node, depth, maximizingPlayer)
//    02     if depth = 0 or node is a terminal node
//    03         return the heuristic value of node
//
//    04     if maximizingPlayer
//    05         bestValue := −∞
//    06         for each child of node
//    07             v := minimax(child, depth − 1, FALSE)
//    08             bestValue := max(bestValue, v)
//    09         return bestValue
//
//    10     else    (* minimizing player *)
//    11         bestValue := +∞
//    12         for each child of node
//    13             v := minimax(child, depth − 1, TRUE)
//    14             bestValue := min(bestValue, v)
//    15         return bestValue
    func minimax(_ d: Int, maximizingPlayer: Bool, alpha: Int, beta: Int) -> Int {
        let selfScore = self.linearEval(), opponentScore = opponent.linearEval()
        if selfScore >= TERMINAL_MAX && !maximizingPlayer {
            return TERMINAL_MAX
        } else if opponentScore >= TERMINAL_MAX && maximizingPlayer {
            return -TERMINAL_MAX
        }
        if d == 0 { //bottom level
            return selfScore - opponentScore
        }
        
        if d == self.depth { //top level
            for row in 0..<(board.dimension - 1) {
                for col in 0..<(board.dimension - 1) {
                    if board.availableCos[row][col] {
                        let co = Coordinate(col: col, row: row)
                        if self.bestMove == nil {
                            bestMove = Move(score: -TERMINAL_MAX * 10, co)
                        }
                        board.place(co)
                        let value = minimax(d - 1, maximizingPlayer: false, alpha: -TERMINAL_MAX * 10, beta: TERMINAL_MAX * 10)
                        
                        if value > bestMove!.score {
                            bestMove = Move(score: value, co)
                        }
                        if self.linearEval() >= TERMINAL_MAX || bestMove!.score >= TERMINAL_MAX {
                            self.bestMove = Move(score: TERMINAL_MAX, co)
                            board.revert(notify: false)
                            return TERMINAL_MAX
                        }
                        board.revert(notify: false)
                    }
                }
            }
            return bestMove!.score
        }
        
        if maximizingPlayer {
            var bestValue = -TERMINAL_MAX * 10, a = alpha
            for row in 0..<(board.dimension - 1) {
                for col in 0..<(board.dimension - 1) {
                    if board.availableCos[row][col] {
                        let co = Coordinate(col: col, row: row)
                        board.place(co)
                        bestValue = max(bestValue, minimax(d - 1, maximizingPlayer: false, alpha: alpha, beta: beta))
                        a = max(a, bestValue)
                        if bestValue >= TERMINAL_MAX {
                            board.revert(notify: false)
                            return TERMINAL_MAX
                        }
                        board.revert(notify: false)
                        if beta <= alpha {
                            return bestValue
                        }
                    }
                }
            }
            return bestValue
        } else {
            var bestValue = TERMINAL_MAX * 10, b = beta
            for row in 0..<(board.dimension - 1) {
                for col in 0..<(board.dimension - 1) {
                    if board.availableCos[row][col] {
                        let co = Coordinate(col: col, row: row)
                        board.place(co)
                        bestValue = min(bestValue, minimax(d - 1, maximizingPlayer: true, alpha: alpha, beta: beta))
                        b = min(b, bestValue)
                        if bestValue <= -TERMINAL_MAX {
                            board.revert(notify: false)
                            return -TERMINAL_MAX
                        }
                        board.revert(notify: false)
                        if beta <= alpha {
                            return bestValue
                        }
                    }
                }
            }
            return bestValue
        }
    }
    
    func getBestMoves() -> [Move] {
        var bestMoves = [Move]()
        for row in 0..<board.dimension {
            for col in 0..<board.dimension {
                if board.availableCos[row][col] {
                    let co = Coordinate(col: col, row: row)
                    board.place(co)
                    let myScore = self.linearEval(), oppoScore = opponent.linearEval()
                    
                    var score: Int = 0, terminal = Intelligence.terminalMax
                    if myScore >= terminal { //
                        return [Move(score: terminal, co)]
                    } else if oppoScore >= terminal {
                        score = terminal
                    } else {
                        score = myScore - oppoScore
                    }
                    
                    let currentMove = Move(score: score, co)
                    
                    //this algorithm might be slow when working on small sets of data
                    let movesCount = bestMoves.count
                    if movesCount == 0 {
                        bestMoves.append(currentMove)
                    } else if score > bestMoves[0].score  {
                        var begin = 0, end = movesCount
                        var i = (begin + end) / 2
                        while true {
                            if i == begin || i == end {
                                let index = score < bestMoves[i].score ? i : i + 1
                                bestMoves.insert(currentMove, at: index)
                                break
                            } else {
                                let sampleScore = bestMoves[i].score
                                if score > sampleScore {
                                    begin = i
                                } else if score == sampleScore {
                                    bestMoves.insert(currentMove, at: i)
                                    break
                                } else {
                                    end = i
                                }
                                i = (begin + end) / 2
                            }
                        }//debug!!! 2 should be breadth
                        if movesCount == 2 {
                            bestMoves.removeFirst()
                        }
                    }
                    board.revert(notify: false)
                }
            }
        }
        
        return bestMoves.reversed()
    }
    
    private func clearCount() {
        //fives
        fives = 0
        pokedFives = 0
        
        //fours
        blockedFour = 0
        freeFour = 0
        freePokedFour = 0
        blockedPokedFour = 0
        
        //threes
        freeThree = 0
        blockedPokedThree = 0
        blockedThree = 0
        freePokedThree = 0
        
        //twos
        freeTwo = 0
        blockedTwo = 0
        
        //ones
        freeOne = 0
    }
    
    func interpret(_ leftBlocked: Bool, _ rightBlocked: Bool, _ i: Int, _ same: Int, _ gaps: Int) {
        if (leftBlocked && rightBlocked && i <= 4) { //no potential
            return
        }
        switch gaps {
        case 0:
            switch same {
            case 5: fives += 1
            case 4:
                if leftBlocked {
                    if i >= 5  {
                        blockedFour += 1
                    }
                } else if rightBlocked {
                    if i >= 5  {
                        freeFour += 1
                    } else if i >= 4 {
                        blockedFour += 1
                    }
                } else {
                    freeFour += 1
                }
            case 3:
                if leftBlocked {
                    if i >= 4  {
                        blockedThree += 1
                    }
                } else if rightBlocked {
                    if i >= 4  {
                        freeThree += 1
                    } else if i >= 3 {
                        blockedThree += 1
                    }
                } else {
                    freeThree += 1
                }
            case 2: //debug
                if leftBlocked || rightBlocked {
                    blockedTwo += 1
                } else {
                    freeTwo += 1
                }
            case 1 where !leftBlocked && !rightBlocked: freeOne += 1
            default: break
            }
        case 1:
            switch same {
            case 5: pokedFives += 1
            case 4:
                if leftBlocked || rightBlocked {
                    blockedPokedFour += 1
                } else {
                    freePokedFour += 1
                }
            case 3:
                if leftBlocked || rightBlocked {
                    blockedPokedThree += 1
                } else {
                    freePokedThree += 1
                }
            default: break
            }
            
        default: break
        }
    
    }
    
    private func horizontalInspection() {
        var row = 0
        while row < board.dimension {
            var col = 0
            while col < board.dimension {
                if let currentPiece = board.pieces[row][col], currentPiece == self.color {
                    let leftCo = Coordinate(col: col - 1, row)
                    var leftBlocked: Bool
                    if board.isValid(co: leftCo) {
                        leftBlocked = board.pieces[leftCo.row][leftCo.col] != nil
                    } else {
                        leftBlocked = true
                    }
                    
                    var gaps = 0, gapsBuff = 0, same = 1, rightBlocked = false, i = 1
                    while(i <= 5) {
                        let nextCo = Coordinate(col: col + i, row: row)
                        if board.isValid(co: nextCo) {
                            if let next = board.pieces[nextCo.row][nextCo.col] {
                                if next == currentPiece {
                                    gaps += gapsBuff
                                    same += 1
                                    gapsBuff = 0
                                } else {
                                    rightBlocked = true
                                    break
                                }
                            } else {
                                gapsBuff += 1
                            }
                        } else {
                            rightBlocked = true
                            break
                        }
                        i += 1
                    }
                    if gaps <= 1 {
                        if same != 5 {col += i - 1}
                        interpret(leftBlocked, rightBlocked, i, same, gaps)
                    }
                }
                col += 1
            }
            row += 1
        }
    }
    
    private func verticalInspection() {
        var col = 0
        while col < board.dimension {
            var row = 0
            while row < board.dimension {
                if let currentPiece = board.pieces[row][col], currentPiece == self.color {
                    let upperCo = Coordinate(col: col, row - 1)
                    var topBlocked: Bool
                    if board.isValid(co: upperCo) {
                        topBlocked = board.pieces[upperCo.row][upperCo.col] != nil
                    } else {
                        topBlocked = true
                    }
                    
                    var gaps = 0, gapsBuff = 0, same = 1, bottomBlocked = false, i = 1
                    while(i <= 5) {
                        let nextCo = Coordinate(col: col, row: row + i)
                        if board.isValid(co: nextCo) {
                            if let next = board.pieces[nextCo.row][nextCo.col] {
                                if next == currentPiece {
                                    gaps += gapsBuff
                                    same += 1
                                    gapsBuff = 0
                                } else {
                                    bottomBlocked = true
                                    break
                                }
                            } else {
                                gapsBuff += 1
                            }
                        } else {
                            bottomBlocked = true
                            break
                        }
                        i += 1
                    }
                    if (gaps <= 1) {
                        if same != 5 {row += i - 1}
                        interpret(topBlocked, bottomBlocked, i, same, gaps)
                    }
                }
                row += 1
            }
            col += 1
        }
    }
    
    private func diagnalInspectionULLR() {
        var row = 0
        while row <= board.dimension - 5 {
            var col = 0
            while col <= board.dimension - 5 {
                if let currentPiece = board.pieces[row][col], currentPiece == self.color {
                    let prevCo = Coordinate(col: col - 1, row: row - 1)
                    var headBlocked: Bool = false, repetitive = false //dummy initialization
                    if board.isValid(co: prevCo) {
                        if let prevPiece = board.pieces[prevCo.row][prevCo.col] {
                            if self.color == prevPiece {
                                col += 1
                                continue
                            } else {
                                headBlocked = true
                            }
                        } else {
                            let prev2Co = Coordinate(col: prevCo.col - 1, prevCo.row - 1)
                            if board.isValid(co: prev2Co) && board.pieces[prev2Co.row][prev2Co.col] == self.color {
                                repetitive = true
                            }
                            headBlocked = false
                        }
                    }
                    
                    var gaps = 0, gapsBuff = 0, same = 1, tailBlocked = false, i = 1
                    while(i <= 5) {
                        let nextCo = Coordinate(col: col + i, row: row + i)
                        if board.isValid(co: nextCo) {
                            if let next = board.pieces[nextCo.row][nextCo.col] {
                                if next == currentPiece {
                                    gaps += gapsBuff
                                    same += 1
                                    gapsBuff = 0
                                } else {
                                    tailBlocked = true
                                    break
                                }
                            } else {
                                gapsBuff += 1
                            }
                        } else {
                            tailBlocked = true
                            break
                        }
                        i += 1
                    }
                    
                    if !repetitive || (same == 5 && gaps == 0) {
                        interpret(headBlocked, tailBlocked, i, same, gaps)
                    }
                }
                col += 1
            }
            row += 1
        }
    }
    
    private func diagnalInspectionURLL() {
        var row = board.dimension - 5
        while row >= 0 {
            var col = board.dimension - 1
            while col >= 4 {
                if let currentPiece = board.pieces[row][col], currentPiece == self.color {
                    let prevCo = Coordinate(col: col + 1, row: row - 1)
                    var headBlocked: Bool = false, repetitive = false // special case
                    if board.isValid(co: prevCo) {
                        if let prevPiece = board.pieces[prevCo.row][prevCo.col] {
                            if self.color == prevPiece {
                                col -= 1
                                continue
                            } else {
                                headBlocked = true
                            }
                        } else {
                            let prev2Co = Coordinate(col: prevCo.col + 1, prevCo.row - 1)
                            if board.isValid(co: prev2Co) && board.pieces[prev2Co.row][prev2Co.col] == self.color {
                                repetitive = true
                            }
                            headBlocked = false
                        }
                    }
                    
                    var gaps = 0, gapsBuff = 0, same = 1, tailBlocked = false, i = 1
                    while(i <= 5) {
                        let nextCo = Coordinate(col: col - i, row: row + i)
                        if board.isValid(co: nextCo) {
                            if let next = board.pieces[nextCo.row][nextCo.col] {
                                if next == currentPiece {
                                    gaps += gapsBuff
                                    same += 1
                                    gapsBuff = 0
                                } else {
                                    tailBlocked = true
                                    break
                                }
                            } else {
                                gapsBuff += 1
                            }
                        } else {
                            tailBlocked = true
                            break
                        }
                        i += 1
                    }
                    if !repetitive || (same == 5 && gaps == 0) {
                        interpret(headBlocked, tailBlocked, i, same, gaps)
                    }
                }
                col -= 1
            }
            row -= 1
        }
    }
    
    public func linearEval() -> Int {
        self.clearCount() //reset scoring
        self.horizontalInspection() //horizontal inspection
        self.verticalInspection() //vertical inspection
        self.diagnalInspectionULLR() //diagnal inspection upper left to lower right
        self.diagnalInspectionURLL() //diagnal inspection upper right to lower left
        
        return fives * Intelligence.terminalMax
        + self.freeFour * 10000
        + self.freeThree * 1000
        + self.freeTwo * 100
        + self.freeOne * 10
        
        + self.blockedFour * 1000
        + self.blockedThree * 100
        + self.blockedTwo * 10
            
//        + self.pokedFives * 9000
        
        
        + self.blockedPokedFour * 999
        + self.freePokedFour * 1000
        + self.freePokedThree * 999
        + self.blockedPokedThree * 99
        
        
    }
    
    public func printDiagnosis() {
        print("fives: \(fives)\n" +
            "poked fives: \(pokedFives)\n" +
            "blocked four: \(blockedFour)\n" +
            "free poked four: \(freePokedFour)\n" +
            "blocked poked four: \(blockedPokedFour)\n" +
            "free four: \(freeFour)\n" +
            "blocked three: \(blockedThree)\n" +
            "free three: \(freeThree)\n" +
            "blocked poked three: \(blockedPokedThree)\n" +
            "free poked three: \(freePokedThree)\n" +
            "blocked two: \(self.blockedTwo)\n" +
            "free two: \(self.freeTwo)")
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
