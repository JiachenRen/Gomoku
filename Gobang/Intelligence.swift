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
    var depth: Int
    
    let TERMINAL_MAX = Score.MAX
    
    
    
    var bestMove: Move?
    var opponent: Intelligence!
    var counter = Counter()
    var unpredictable = false
    
    //debug section
    var alphaCut = 0, betaCut = 0
    
    required init(color: Piece, depth: Int) {
        self.color = color
        self.depth = depth
    }
    
    private func initOpponent() {
        opponent = Intelligence(color: self.color.next(), depth: self.depth)
    }
    
    public func makeMove() throws {
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
        } else if depth == 0 {
            board.put(self.getBalancedMove().co)
        } else if depth == 1 {
//            board.aiStatus = "eva"
            board.aiStatus = "evaluating offensive possibilities..."
            self.depth = 2 //----------------------
            self.opponent.depth = 2
            let myScore = self.minimax(2, maximizingPlayer: true, alpha: -TERMINAL_MAX * 10, beta: TERMINAL_MAX * 10)
            let myMove = self.bestMove
            self.bestMove = nil
            
            board.aiStatus = "quantifying potential threats..."
            board.turn = board.turn.next()
            let oppoScore = opponent.minimax(2, maximizingPlayer: true, alpha: -TERMINAL_MAX * 10, beta: TERMINAL_MAX * 10)
            let oppoMove = opponent.bestMove
            opponent.bestMove = nil
            board.turn = board.turn.next()
            self.depth = 1 //----------------------
            self.opponent.depth = 1
            
            if myScore > TERMINAL_MAX {
                board.put(myMove!.co)
            } else if oppoScore > TERMINAL_MAX {
                board.put(oppoMove!.co)
            }
            
            if myMove == nil {
                board.put(oppoMove!.co)
                return
            } else if oppoMove == nil {
                board.put(myMove!.co)
                return
            }
            
            board.aiStatus = "waiting..."
            board.put(myScore > oppoScore ? myMove!.co : oppoMove!.co)
        } else {
            let curMillis = NSDate() //debug
            //extrapolate best move
            board.aiStatus = "extrapolating best move..."
            let _ = self.minimax(self.depth, maximizingPlayer: true, alpha: -TERMINAL_MAX * 10, beta: TERMINAL_MAX * 10)
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
            print(NSDate().timeIntervalSince(curMillis as Date)) //debug
        }
        
        //alfred
        if self.unpredictable {
            let seed = Int(CGFloat.random(min: 0, max: 4))
            switch seed {
            case 3:
                self.depth = 4
                board.aiStatus = "your move is my command"
            default:
                self.depth = seed
                switch depth {
                case 0: board.aiStatus = "Alfred is distracted..."
                case 1: board.aiStatus = "Alfred is meditating..."
                case 2: board.aiStatus = "Alfred is thinking: \"ha ha ha\""
                default: break
                }
            }
        }
    }
    
    func getBalancedMove() -> Move  {
        let staticEvalScoreSelf = self.linearEval() - opponent.linearEval()
        let staticEvalScoreOpponent = -staticEvalScoreSelf
        
        board.aiStatus = "extrapolating..."
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
        
        if myBestMove.score >= Score.MAX {
            board.aiStatus = "winning..."
            return myBestMove
        }
        board.aiStatus = oppoScoreChange > selfScoreChange ? "defending..." : "attacking..."
        
        return oppoScoreChange > selfScoreChange ? oppoBestMove : myBestMove
    }
    
    ///evaluate each possible move and rank them according to their corresponding score.
    func getSortedMoves() -> [Move] {
        var bestMoves = [Move]()
        let role = board.turn
        for row in 0..<board.dimension {
            for col in 0..<board.dimension {
                if board.availableCos[row][col] {
                    let co = Coordinate(col: col, row: row)
                    board.place(co)
                    let score = Score.pointEvaluation(co: co, role: role)
                    let currentMove = Move(score: score, co)
                    bestMoves.append(currentMove)
                    board.revert(notify: false)
                }
            }
        }
        
        return bestMoves.sorted {$0.score > $1.score}
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
        var alpha = alpha, beta = beta
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
            for (_, co) in getSortedMoves() {
                
                if self.bestMove == nil {
                    bestMove = Move(score: -TERMINAL_MAX * 10, co)
                }
                board.place(co)
                let value = minimax(d - 1, maximizingPlayer: false, alpha: alpha, beta: beta)
                alpha = max(alpha, bestMove!.score)
                
                if value > bestMove!.score || value >= TERMINAL_MAX {
                    print("best score updated: \(value)")
                    board.aiStatus = "current best: \(value)"
                    bestMove = Move(score: value, co)
                }
                if self.linearEval() >= TERMINAL_MAX || bestMove!.score >= TERMINAL_MAX {
                    self.bestMove = Move(score: TERMINAL_MAX, co)
                    board.revert(notify: false)
                    return TERMINAL_MAX
                }
                board.revert(notify: false)
            }
            
            print("alpha cut: \(alphaCut)","beta cut: \(betaCut)")
            return bestMove!.score
        }
        
        if maximizingPlayer {
//            print("max \(d)")
            var bestValue = -TERMINAL_MAX * 10
            for (_, co) in getSortedMoves() {
                board.place(co)
                bestValue = max(bestValue, minimax(d - 1, maximizingPlayer: false, alpha: alpha, beta: beta))
                alpha = max(alpha, bestValue)
                if bestValue >= TERMINAL_MAX {
                    board.revert(notify: false)
                    return TERMINAL_MAX
                }
                board.revert(notify: false)
                if beta <= alpha {
                    alphaCut += 1
                    return alpha
                }
            }
            return bestValue
        } else {
//            print("min \(d)")
            var bestValue = TERMINAL_MAX * 10
            for (_, co) in getSortedMoves() {
                board.place(co)
                let value = minimax(d - 1, maximizingPlayer: true, alpha: alpha, beta: beta)
                bestValue = min(bestValue, value)
                beta = min(beta, bestValue)
                if bestValue <= -TERMINAL_MAX {
                    board.revert(notify: false)
                    return -TERMINAL_MAX
                }
                board.revert(notify: false)
                if beta <= alpha {
                    betaCut += 1
                    return beta
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
                    
                    var score: Int = 0, terminal = Score.MAX
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
    
    func findMoves(for role: Piece, threshold: Int) -> [Move] {
        var result = [Move]();
        for i in 0..<board.dimension {
            for j in 0..<board.dimension {
                if board.availableCos[i][j] {
                    let co = (row: i, col: j)
                    board.place(co)
                    let score = Score.pointEvaluation(co: co, role: role)
                    board.revert(notify: false)
                    if(score >= threshold) {
                        result.append(Move(score: score, co))
                    }
                }
            }
        }
        return result.sorted {$0.score > $1.score};
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
//                    let curMillis = NSDate() //debug
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
//                    print(NSDate().timeIntervalSince(curMillis as Date))
                    if gaps <= 1 {
                        if same != 5 {col += i - 1}
                        counter.interpret(leftBlocked, rightBlocked, i, same, gaps)
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
                        counter.interpret(topBlocked, bottomBlocked, i, same, gaps)
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
                        counter.interpret(headBlocked, tailBlocked, i, same, gaps)
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
                        counter.interpret(headBlocked, tailBlocked, i, same, gaps)
                    }
                }
                col -= 1
            }
            row -= 1
        }
    }
    
    public func linearEval() -> Int {
        counter = Counter() //reset scoring
        
        self.horizontalInspection() //horizontal inspection
        self.verticalInspection() //vertical inspection
        self.diagnalInspectionULLR() //diagnal inspection upper left to lower right
        self.diagnalInspectionURLL() //diagnal inspection upper right to lower left
        
        return counter.fives * Score.MAX
        + counter.freeFour * Score.FREE_FOUR
        + counter.freeThree * Score.FREE_THREE
        + counter.freeTwo * Score.FREE_TWO
        + counter.freeOne * Score.FREE_ONE
        
        + counter.blockedFour * Score.BLOCKED_FOUR
        + counter.blockedThree * Score.BLOCKED_THREE
        + counter.blockedTwo * Score.BLOCKED_TWO
            
        + counter.blockedPokedFour * Score.BLOCKED_POKED_FOUR
        + counter.freePokedFour * Score.BLOCKED_POKED_FOUR
        + counter.freePokedThree * Score.FREE_POKED_THREE
        + counter.blockedPokedThree * Score.BLOCKED_POKED_THREE
        
    }
    
    public func printDiagnosis() {
        print("fives: \(counter.fives)\n" +
            "poked fives: \(counter.pokedFives)\n" +
            "blocked four: \(counter.blockedFour)\n" +
            "free poked four: \(counter.freePokedFour)\n" +
            "blocked poked four: \(counter.blockedPokedFour)\n" +
            "free four: \(counter.freeFour)\n" +
            "blocked three: \(counter.blockedThree)\n" +
            "free three: \(counter.freeThree)\n" +
            "blocked poked three: \(counter.blockedPokedThree)\n" +
            "free poked three: \(counter.freePokedThree)\n" +
            "blocked two: \(counter.blockedTwo)\n" +
            "free two: \(counter.freeTwo)")
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
