//
//  swift
//  Gobang
//
//  Created by Jiachen Ren on 12/15/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

class Counter {
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
    
    func interpret(_ leftBlocked: Bool, _ rightBlocked: Bool, _ i: Int, _ same: Int, _ gaps: Int) {
        if (leftBlocked && rightBlocked && i <= 4) { //no potential
            return
        }
        switch gaps {
        case 0:
            switch same {
            case 5: fives += 1
            case 4 where leftBlocked && i >= 5: blockedFour += 1
            case 4 where rightBlocked && i >= 5: freeFour += 1
            case 4 where i >= 4: blockedFour += 1
            case 4: freeFour += 1
            case 3 where leftBlocked && i >= 4: blockedThree += 1
            case 3 where rightBlocked && i >= 4: freeThree += 1
            case 3 where rightBlocked && i >= 3: blockedThree += 1
            case 3: freeThree += 1
            case 2 where (leftBlocked || rightBlocked): blockedTwo += 1
            case 2: freeTwo += 1
            case 1 where !leftBlocked && !rightBlocked: freeOne += 1
            default: break
            }
        case 1:
            switch same {
            case 5: pokedFives += 1
            case 4 where (leftBlocked || rightBlocked): blockedPokedFour += 1
            case 4: freePokedFour += 1
            case 3 where (leftBlocked || rightBlocked): blockedPokedThree += 1
            case 3: freePokedThree += 1
            default: break
            }
        default: break
        }
    }
}
