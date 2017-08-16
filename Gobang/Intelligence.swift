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
    
    lazy var patterns: [Pattern] = {
        var patterns = [Pattern]()
        patterns.append(Pattern(
            name: "freeFour",
            configs: [(
                pieces: [.empty, .same, .same, .same, .same, .empty],
                coordinates: [(0, 0), (1, 1), (2, 2), (3, 3), (4, 4), (5, 5)]
                ), (
                    pieces: [.empty, .same, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3), (-4, -4), (-5, -5)]
                ), (
                    pieces: [.empty, .same, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4), (0, 5)]
                ), (
                    pieces: [.empty, .same, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0)]
                )],
            weight: 12
        ))
        patterns.append(Pattern(
            name: "five",
            configs: [(
                pieces: [.same, .same, .same, .same, .same],
                coordinates: [(0, 0), (1, 1), (2, 2), (3, 3), (4, 4)]
                ), (
                    pieces: [.same, .same, .same, .same, .same],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3), (-4, -4)]
                ), (
                    pieces: [.same, .same, .same, .same, .same],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4)]
                ), (
                    pieces: [.same, .same, .same, .same, .same],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]
                )],
            weight: 99
        ))
        patterns.append(Pattern(
            name: "freeThree",
            configs: [(
                pieces: [.empty, .same, .same, .same, .empty],
                coordinates: [(0, 0), (1, 1), (2, 2), (3, 3), (4, 4)]
                ), (
                    pieces: [.empty, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3), (-4, -4)]
                ), (
                    pieces: [.empty, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4)]
                ), (
                    pieces: [.empty, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]
                )],
            weight: 11
        ))
        patterns.append(Pattern(
            name: "blockedFour",
            configs: [(
                pieces: [.opposite, .same, .same, .same, .same, .empty],
                coordinates: [(0, 0), (1, 1), (2, 2), (3, 3), (4, 4), (5, 5)]
                ), (
                    pieces: [.opposite, .same, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3), (-4, -4), (-5, -5)]
                ), (
                    pieces: [.opposite, .same, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4), (0, 5)]
                ), (
                    pieces: [.opposite, .same, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0)]
                ),(
                    pieces: [.empty, .same, .same, .same, .same, .opposite],
                    coordinates: [(0, 0), (1, 1), (2, 2), (3, 3), (4, 4), (5, 5)]
                ), (
                    pieces: [.empty, .same, .same, .same, .same, .opposite],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3), (-4, -4), (-5, -5)]
                ), (
                    pieces: [.empty, .same, .same, .same, .same, .opposite],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4), (0, 5)]
                ), (
                    pieces: [.empty, .same, .same, .same, .same, .opposite],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0)]
                )],
            weight: 8
        ))
        patterns.append(Pattern(
            name: "blockedThree",
            configs: [(
                pieces: [.opposite, .same, .same, .same, .empty],
                coordinates: [(0, 0), (1, 1), (2, 2), (3, 3), (4, 4)]
                ), (
                    pieces: [.opposite, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3), (-4, -4)]
                ), (
                    pieces: [.opposite, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4)]
                ), (
                    pieces: [.opposite, .same, .same, .same, .empty],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]
                ),(
                    pieces: [.empty, .same, .same, .same, .opposite],
                    coordinates: [(0, 0), (1, 1), (2, 2), (3, 3), (4, 4)]
                ), (
                    pieces: [.empty, .same, .same, .same, .opposite],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3), (-4, -4)]
                ), (
                    pieces: [.empty, .same, .same, .same, .opposite],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4)]
                ), (
                    pieces: [.empty, .same, .same, .same, .opposite],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]
                )],
            weight: 6
        ))
        patterns.append(Pattern(
            name: "freeTwo",
            configs: [(
                pieces: [.empty, .same, .same, .empty],
                coordinates: [(0, 0), (1, 1), (2, 2), (3, 3)]
                ), (
                    pieces: [.empty, .same, .same, .empty],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3)]
                ), (
                    pieces: [.empty, .same, .same, .empty],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3)]
                ), (
                    pieces: [.empty, .same, .same, .empty],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0)]
                )],
            weight: 2
        ))
        patterns.append(Pattern(
            name: "blockedTwo",
            configs: [(
                pieces: [.opposite, .same, .same, .empty],
                coordinates: [(0, 0), (1, 1), (2, 2), (3, 3)]
                ), (
                    pieces: [.opposite, .same, .same, .empty],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3)]
                ), (
                    pieces: [.opposite, .same, .same, .empty],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3)]
                ), (
                    pieces: [.opposite, .same, .same, .empty],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0)]
                ),(
                    pieces: [.empty, .same, .same, .opposite],
                    coordinates: [(0, 0), (1, 1), (2, 2), (3, 3)]
                ), (
                    pieces: [.empty, .same, .same, .opposite],
                    coordinates: [(0, 0), (-1, -1), (-2, -2), (-3, -3)]
                ), (
                    pieces: [.empty, .same, .same, .opposite],
                    coordinates: [(0, 0), (0, 1), (0, 2), (0, 3)]
                ), (
                    pieces: [.empty, .same, .same, .opposite],
                    coordinates: [(0, 0), (1, 0), (2, 0), (3, 0)]
                )],
            weight: 1
        ))
        return patterns
    }()
    
    struct Pattern {
        let name: String
        let configs: [(pieces: [Config], coordinates: [Coordinate])]
        var weight: Double
        
        public func numMatches(_ target: Intelligence,_ pieces: inout [[Piece?]], _ coordinate: Coordinate) -> Int {
            return configs.reduce(0) { (num, config) in
                let maxCo = config.coordinates[config.pieces.count - 1] + coordinate
                if maxCo.row >= pieces.count
                    || maxCo.row < 0
                    || maxCo.col >= pieces.count
                    || maxCo.col < 0 {
                    return num
                }
                for i in 0..<config.pieces.count {
                    let co = config.coordinates[i] + coordinate
                    let piece = pieces[co.row][co.col]
                    switch config.pieces[i] {
                    case .empty: if piece != nil {return num}
                    case .all: if piece == nil {return num}
                    case .same: if piece == nil
                        || piece != target.color {
                        return num
                        }
                    case .opposite: if piece == nil
                        || piece == target.color {
                        return num
                        }
                    }
                }
                return num + 1
            }
        }
    }
    
//    //seg stands for segmented
//    struct Weights {
//        var segFour = 10
//        var halfFour = 9
//        var blockedSegFour = 7
//        var blockedHalfFour = 4
//    }

    
    enum Config {
        case empty
        case all
        case same
        case opposite
    }
    
    required init(color: Piece) {
        self.color = color
    }
    
    private func linearEval( pieces: inout [[Piece?]]) -> Double {
        var score: Double = 0.0
        for row in 0..<pieces.count {
            for col in 0..<pieces[row].count {
                patterns.forEach {pattern in
                    let num = pattern.numMatches(self, &pieces, (col, row))
                    score += Double(num) * pattern.weight
                }
            }
        }
        return score
    }
    
    public func makeMove() {
        var maxScore: Double = 0.0, co: Coordinate?, pieces = board.pieces!
        for row in 0..<board.pieces.count {
            for col in 0..<board.pieces[row].count {
                if board.pieces[row][col] != nil {
                    continue
                }
                pieces[row][col] = self.color
                let score = linearEval(pieces: &pieces)
                if score > maxScore {
                    maxScore = score
                    co = (col: col, row: row)
                }
                pieces[row][col] = nil
            }
        }
        if maxScore != 0.0 && co != nil {
            board.put(co!)
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
