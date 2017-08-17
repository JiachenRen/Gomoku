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
    
    enum Config {
        case empty
        case end
        case same
        case opposite
    }
    
    required init(color: Piece) {
        self.color = color
    }
    
    private func linearEval() -> Double {
        var score: Double = 0.0
        func resolveConfig(_ piece: Piece?, _ configs: inout [Config]) {
            if let p = piece {
                configs.append(p == self.color ? .same: .opposite)
            } else {
                configs.append(.empty)
            }
        }
        
        func interpretConfigs(_ configs: [Config]..., score: inout Double) {
            func evaluate(_ group: [Config], _ numInvalid: Int) -> (hole: Int, same: Int, noPotential: Bool) {
                var hole: Int = 0, same: Int = 0, noPotential = false
                var acc = 0
                loop: for i in 1..<group.count {
                    switch group[i] {
                    case .empty: acc += 1
                    case .same:
                        same += 1
                        hole += acc
                        acc = 0
                    case .end, .opposite:
                        if i <= numInvalid {
                            noPotential = true
                        }
                        break loop
                    }
                }
                return (hole, same, noPotential)
            }
            configs.forEach {group in
                if group.count > 0 {
                    switch group[0] {
                    case .empty:
                        let (hole, same, noPotential) = evaluate(group, 0)
                        if same == 5 {
                            score += Double.infinity
                            return
                        }
                        if same > 1 {
                            var base = pow(10, Double(same))
                            if !noPotential {
                                if hole > 0 {
                                    base = pow(base, 1 / (Double(hole) + 0.5))
                                }
                                score += base
                            }
                        }
                    case .end, .opposite:
                        let (hole, same, noPotential) = evaluate(group, 0)
                        if same == 5 {
                            score += Double.infinity
                            return
                        }
                        if same > 1 {
                            var base = pow(5, Double(same))
                            if !noPotential {
                                if hole > 0 {
                                    base = pow(base, 1 / (Double(hole) + 0.5))
                                }
                                score += base
                            }
                        }
                    default: break
                    }
                }
            }
        }
        
        for row in 0..<board.pieces.count {
            for col in 0..<board.pieces[row].count {
                if board.pieces[row][col] != self.color{
                    continue
                }
                
                let range = 0...4
                var hor = [Config](), ver = [Config](), diag_up = [Config](), diag_down = [Config]()
                
                // horizontal
                if col - 1 < 0 {
                    hor.append(.end)
                }
                if hor.count > 0 || board.pieces[row][col - 1] != self.color {
                    if hor.count == 0 {
                        resolveConfig(board.pieces[row][col - 1], &hor)
                    }
                    for i in range.map({$0+col}) {
                        if i >= board.dimension {
                            hor.append(.end)
                            break
                        }
                        resolveConfig(board.pieces[row][i], &hor)
                    }
                }
                
                // vertical
                if row - 1 < 0 {
                    ver.append(.end)
                }
                if ver.count > 0 || board.pieces[row - 1][col] != self.color {
                    if ver.count == 0 {
                        resolveConfig(board.pieces[row - 1][col], &ver)
                    }
                    for i in range.map({$0+row}) {
                        if i >= board.dimension {
                            ver.append(.end)
                            break
                        }
                        resolveConfig(board.pieces[i][col], &ver)
                    }
                }
                
                // diagnal up
                if row - 1 < 0 || col - 1 < 0 {
                    diag_up.append(.end)
                }
                if diag_up.count > 0 || board.pieces[row - 1][col - 1] != self.color {
                    if diag_up.count == 0 {
                        resolveConfig(board.pieces[row - 1][col - 1], &diag_up)
                    }
                    for (c, r) in range.map({($0+col, $0+row)}) {
                        if c >= board.pieces.count || r >= board.dimension {
                            diag_up.append(.end)
                            break
                        }
                        resolveConfig(board.pieces[r][c], &diag_up)
                    }
                }
                
                // diagnal down
                if row - 1 < 0 || col + 1 >= board.dimension {
                    diag_down.append(.end)
                }
                if diag_down.count > 0 || board.pieces[row - 1][col + 1] != self.color {
                    if diag_down.count == 0 {
                        resolveConfig(board.pieces[row - 1][col + 1], &diag_down)
                    }
                    for (c, r) in range.map({(col-$0, $0+row)}) {
                        if c < 0 || r >= board.dimension {
                            diag_down.append(.end)
                            break
                        }
                        resolveConfig(board.pieces[r][c], &diag_down)
                    }
                }
                interpretConfigs(hor, ver, diag_up, diag_down, score: &score)
            }
        }
        
        return score
    }
    
    private func bestMoves(num: Int) -> (offensive: [Move], defensive: [Move]) {
        var myMaxScore: Double = -Double.infinity, myCo: Coordinate?
        var oppMaxScore: Double = -Double.infinity, oppCo: Coordinate?
        var offensive = [Move]()
        var defensive = [Move]()
        
        for row in 0..<board.pieces.count {
            for col in 0..<board.pieces[row].count {
                if board.pieces[row][col] != nil {
                    continue
                }
                board.pieces[row][col] = self.color
                let myScore = linearEval()
                
                self.color = self.color.next()
                board.pieces[row][col] = self.color
                let oppScore = linearEval()
                self.color = self.color.next()
                
                if myScore > myMaxScore {
                    myMaxScore = myScore
                    myCo = (col: col, row: row)
                    offensive.append((myMaxScore, myCo!))
                    if offensive.count > num {
                        offensive.remove(at: 0)
                    }
                }
                
                if oppScore > oppMaxScore {
                    oppMaxScore = oppScore
                    oppCo = (col: col, row: row)
                    defensive.append((oppMaxScore, oppCo!))
                    if defensive.count > num {
                        defensive.remove(at: 0)
                    }
                }
                
                board.pieces[row][col] = nil
            }
        }
        
        return (offensive, defensive)
    }
    
    public func makeMove(breadth: Int, depth: Int) {
        
        let (offensive, defensive) = bestMoves(num: breadth)
        
        print("offensive moves: \n\(offensive)")
        print("defensive moves: \n\(defensive)")
        
        if offensive.count > 0 && offensive.last!.score != 0.0 {
            if defensive.count > 0 && defensive.last!.score > offensive.last!.score {
                board.put(defensive.last!.co)
            } else {
                board.put(offensive.last!.co)
            }
        } else {
            board.put((9,9))
        }
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
