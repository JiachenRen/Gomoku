//
//  ViewController.swift
//  Gobang
//
//  Created by Jiachen Ren on 8/7/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController, BoardDelegate {
    
    @IBAction func revertButtonPressed(_ sender: UIButton) {
        board.revert()
    }
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        board.restore()
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let pos = sender.location(in: self.boardView)
        let coordinate = self.boardView.onBoard(pos)
        board.put(coordinate) //make the move
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let pos = sender.location(in: boardView)
        func isOnBoard(_ pos: CGPoint) -> Bool {
            return pos.x <= boardView.bounds.width
                && pos.y <= boardView.bounds.height
                && pos.x >= 0
                && pos.y >= 0
        }
        switch sender.state {
        case .ended where isOnBoard(pos):
            board.put(boardView.onBoard(pos))
            fallthrough
        case .ended: boardView.dummyPiece = nil
        default: break
        }
        boardView.dummyPiece = isOnBoard(pos) ? (board.turn, pos) : .none
        
    }
    
    @IBOutlet weak var boardView: BoardView!
    
    var board: Board {
        return Board.sharedInstance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.delegate = self
        // Assign an artificial intelligence to the current board.
        board.intelligence = Intelligence(color: .black)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func boardDidUpdate() {
        boardView.dimension = self.board.dimension
        boardView.pieces = board.pieces
    }


}

