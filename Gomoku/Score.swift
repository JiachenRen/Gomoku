//
//  Score.swift
//  Gobang
//
//  Created by Jiachen Ren on 12/15/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

class Score {
    static let MAX = 100000
    static let FREE_FOUR = 10000
    static let FREE_THREE = 1000
    static let FREE_TWO = 100
    static let FREE_ONE = 10
    
    static let BLOCKED_FOUR = 1000
    static let BLOCKED_THREE = 100
    static let BLOCKED_TWO = 10

    static let BLOCKED_POKED_FOUR = 989
    static let BLOCKED_POKED_THREE = 99
    static let FREE_POKED_FOUR = 1000
    static let FREE_POKED_THREE = 999
    
    private static var board: Board {
        get {
            return Board.sharedInstance
        }
    }
    
    //evaluate the score at a particular coordinate.
    static func pointEvaluation(co: Coordinate, role: Piece) -> Int {
        var result = 0, count = 0, block = 0, secondCount = 0, empty = -1
        
        var len = board.dimension
        
        func reset() {
            count = 1
            block = 0
            empty = -1
            secondCount = 0  //另一个方向的count
        }
        
        
        reset()
        
        var i = co.col
        while true {
            i += 1
            if(i>=len) {
                block  += 1
                break
            }
            let t = board.pieces[co.row][i]
            if(t == nil) {
                if(empty == -1 && i < len - 1 && board.pieces[co.row][i + 1] == role) {
                    empty = count
                    continue
                } else {
                    break
                }
            }
            if(t == role) {
                count  += 1
            } else {
                block  += 1
                break
            }
        }
        
        
        i = co.col
        while true {
            i -= 1
            if(i<0) {
                block  += 1
                break
            }
            let t = board.pieces[co.row][i]
            if(t == nil) {
                if(empty == -1 && i>0 && board.pieces[co.row][i - 1] == role) {
                    empty = 0  //注意这里是0，因为是从右往左走的
                    continue
                } else {
                    break
                }
            }
            if(t == role) {
                secondCount  += 1
                if empty != -1 {empty += 1}  //注意这里，如果左边又多了己方棋子，那么empty的位置就变大了
            } else {
                block  += 1
                break
            }
        }
        
        count += secondCount
        
        
        result += getType(count, block, empty)
        
        //纵向
        reset()
        
        i = co.row
        while true {
            i += 1
            if(i>=len) {
                block  += 1
                break
            }
            let t = board.pieces[i][co.col]
            if(t == nil) {
                if(empty == -1 && i < len - 1 && board.pieces[i + 1][co.col] == role) {
                    empty = count
                    continue
                } else {
                    break
                }
            }
            if(t == role) {
                count  += 1
            } else {
                block  += 1
                break
            }
        }
        
        i = co.row
        while true {
            i -= 1
            if(i<0) {
                block  += 1
                break
            }
            let t = board.pieces[i][co.col]
            if(t == nil) {
                if(empty == -1 && i>0 && board.pieces[i - 1][co.col] == role) {
                    empty = 0
                    continue
                } else {
                    break
                }
            }
            if(t == role) {
                secondCount += 1
                if empty != -1 {empty += 1}  //注意这里，如果左边又多了己方棋子，那么empty的位置就变大了
            } else {
                block  += 1
                break
            }
        }
        
        count += secondCount
        result += getType(count, block, empty)
        
        
        // \\
        reset()
        
        i = 0
        while true {
            i += 1
            let x = co.row + i, y = co.col + i
            if(x>=len || y>=len) {
                block  += 1
                break
            }
            let t = board.pieces[x][y]
            if(t == nil) {
                if(empty == -1 && (x < len - 1 && y < len - 1) && board.pieces[x + 1][y + 1] == role) {
                    empty = count
                    continue
                } else {
                    break
                }
            }
            if(t == role) {
                count  += 1
            } else {
                block  += 1
                break
            }
        }
        
        i = 0
        while true {
            i += 1
            let x = co.row-i, y = co.col-i
            if(x<0||y<0) {
                block  += 1
                break
            }
            let t = board.pieces[x][y]
            if(t == nil) {
                if(empty == -1 && (x>0 && y>0) && board.pieces[x - 1][y - 1] == role) {
                    empty = 0
                    continue
                } else {
                    break
                }
            }
            if(t == role) {
                secondCount  += 1
                if empty != -1 {empty += 1}  //注意这里，如果左边又多了己方棋子，那么empty的位置就变大了
            } else {
                block  += 1
                break
            }
        }
        
        count += secondCount
        result += getType(count, block, empty)
        
        
        // \/
        reset()
        i = 0
        while true {
            i += 1
            let x = co.row + i, y = co.col - i
            if x < 0 || y < 1 || x >= len || y >= len {
                block += 1
                break
            }
            let t = board.pieces[x][y]
            if(t == nil) {
                if(empty == -1 && (x < len - 1 && y < len - 1) && board.pieces[x + 1][y - 1] == role) {
                    empty = count
                    continue
                } else {
                    break
                }
            }
            if(t == role) {
                count  += 1
            } else {
                block  += 1
                break
            }
        }
        
        i = 0
        while true {
            i += 1
            let x = co.row-i, y = co.col + i
            if(x<0 || y<0 || x >= len || y >= len - 1) {
                block += 1
                break
            }
            let t = board.pieces[x][y]
            if(t == nil) {
                if(empty == -1 && ( x > 0 && y > 0 ) && board.pieces[x - 1][y + 1] == role) {
                    empty = 0
                    continue
                } else {
                    break
                }
            }
            if(t == role) {
                secondCount += 1
                if empty != -1 {empty += 1}  //注意这里，如果左边又多了己方棋子，那么empty的位置就变大了
            } else {
                block  += 1
                break
            }
        }
        
        count += secondCount
        result += getType(count, block, empty)
        
        
        return typeToScore(result)
    }
    
    static func getType(_ count: Int, _ block: Int, _ empty: Int) -> Int {
        //没有空位
        if empty <= 0 {
            if count >= 5 {
                return Score.MAX
            }
            
            if block == 0 {
                switch count {
                    case 1: return Score.FREE_ONE
                    case 2: return Score.FREE_TWO
                    case 3: return Score.FREE_THREE
                    case 4: return Score.FREE_FOUR
                    default: break
                }
            }
            
            if(block == 1) {
                switch(count) {
                case 2: return Score.BLOCKED_TWO
                case 3: return Score.BLOCKED_THREE
                case 4: return Score.BLOCKED_FOUR
                default: break
                }
            }
        } else if(empty == 1 || empty == count - 1) {
            //第1个是空位
            if(count >= 6) {
            return Score.MAX
            }
            if block == 0 {
                switch(count) {
                case 2: return Score.FREE_TWO/2
                case 3: return Score.FREE_THREE
                case 4: return Score.BLOCKED_FOUR
                case 5: return Score.FREE_FOUR
                default: break
                }
            }
            
            if(block == 1) {
                switch(count) {
                case 2: return Score.BLOCKED_TWO
                case 3: return Score.BLOCKED_THREE
                case 4: return Score.BLOCKED_FOUR
                case 5: return Score.BLOCKED_FOUR
                default: break
                }
            }
        } else if(empty == 2 || empty == count - 2) {
            //第二个是空位
            if(count >= 7) {
                return Score.MAX
            }
            if(block == 0) {
                switch(count) {
                case 3: return Score.FREE_THREE
                case 5: return Score.BLOCKED_FOUR
                case 6: return Score.FREE_FOUR
                default: break
                }
            }
            
            if(block == 1) {
                switch(count) {
                case 3: return Score.BLOCKED_THREE
                case 4: return Score.BLOCKED_FOUR
                case 5: return Score.BLOCKED_FOUR
                case 6: return Score.FREE_FOUR
                default: break
                }
            }
            
            if(block == 2) {
                switch(count) {
                case 6: return Score.BLOCKED_FOUR
                default: break
                }
            }
        } else if(empty == 3 || empty == count - 3) {
            if(count >= 8) {
            return Score.MAX
            }
            if(block == 0) {
                switch(count) {
                case 5: return Score.FREE_THREE
                case 6: return Score.BLOCKED_FOUR
                case 7: return Score.FREE_FOUR
                default: break
                }
            }
            
            if(block == 1) {
                switch(count) {
                case 6: return Score.BLOCKED_FOUR
                case 7: return Score.FREE_FOUR
                default: break
                }
            }
            
            if(block == 2) {
                switch(count) {
                case 7: return Score.BLOCKED_FOUR
                default: break
                }
            }
        } else if(empty == 4 || empty == count - 4) {
            if(count >= 9) {
                return Score.MAX
            }
            if(block == 0) {
                switch(count) {
                case 8: return Score.FREE_FOUR
                default: break
                }
            }
            
            if(block == 1) {
                switch(count) {
                case 7: return Score.BLOCKED_FOUR
                case 8: return Score.FREE_FOUR
                default: break
                }
            }
            
            if(block == 2) {
                switch(count) {
                case 8: return Score.BLOCKED_FOUR
                default: break
                }
            }
        } else if(empty == 5 || empty == count - 5) {
            return Score.MAX
        }
        
        return 0
    }
    
    static func typeToScore(_ type: Int) -> Int {
        if type < Score.FREE_FOUR && type >= Score.BLOCKED_FOUR {
            if type >= Score.BLOCKED_FOUR && type < (Score.BLOCKED_FOUR + Score.FREE_THREE) {
                return Score.FREE_THREE; //单独冲四，意义不大
            } else if type >= Score.BLOCKED_FOUR + Score.FREE_THREE && type < Score.BLOCKED_FOUR * 2 {
                return Score.FREE_FOUR;  //冲四活三，比双三分高，相当于自己形成活四
            } else {
                //双冲四 比活四分数也高
                return Score.FREE_FOUR * 2;
            }
        }
        return type;
    }
}
