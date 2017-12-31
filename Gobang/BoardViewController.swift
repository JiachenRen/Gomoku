//
//  ViewController.swift
//  Gobang
//
//  Created by Jiachen Ren on 8/7/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController, BoardDelegate {
    
    static var overlayLabelsVisible = false
    
    @IBOutlet var overlayLabels: [UILabel]!
    
    @IBOutlet weak var pleaseWaitButton: UIButton!
    
    @IBOutlet weak var aiStatusLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    
    @IBOutlet weak var boardView: BoardView!
    
    var board: Board {
        return Board.sharedInstance
    }
    
    func aiBrainActivity(thinking: Bool) {
        DispatchQueue.main.async {[unowned self] in
            self.boardView.isUserInteractionEnabled = !thinking
        }
    }
    
    func boardSettingsChanged() {
        DispatchQueue.main.async {[unowned self] in
            self.boardView.setNeedsDisplay()
        }
    }
    
    func aiStatusDidUpdate() {
        aiStatusLabel.text = board.aiStatus
    }
    
    @IBAction func revertButtonPressed(_ sender: UIBarButtonItem) {
        if board.aiIsThinking {
            self.flashPleaseWait()
            return
        }
        board.revert(notify: true)
    }

    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        if board.aiIsThinking {
            self.flashPleaseWait()
            return
        }
        board.restore()
    }
    
    @IBAction func restartButtonPressed(_ sender: UIBarButtonItem) {
        if board.aiIsThinking {
            self.flashPleaseWait()
            return
        }
        board.reset()
    }
    
    private func flashPleaseWait() {
        pleaseWaitButton.isHidden = false
        UIView.animate(withDuration: 1.5, animations: {[unowned self] in
            self.pleaseWaitButton.alpha = 0
            }, completion: {_ in
                self.pleaseWaitButton.alpha = 1.0
                self.pleaseWaitButton.isHidden = true
        })
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
//            print(board, "\nAvailable Coordinates:\n", "\n"+board.availableSpacesMap)
            fallthrough
        case .ended: boardView.dummyPiece = nil
        default: break
        }
        boardView.dummyPiece = isOnBoard(pos) ? (board.turn, pos) : .none
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.delegate = self
        
        //retrieve board settings from user default
        boardView.reloadBoardSettings()
        
        //this is for fixing an extremely wierd bug
        board.place((col: 0, row: 0))
        board.revert(notify: true)
        
        //this is for fixing another extremely wierd bug... I did a poor job with this class...
        
        if board.lastMoves.count == 0 && board.intelligence != nil && board.turn == board.intelligence!.color {
            try? board.intelligence!.makeMove()
        }
        
        //manage the visibility of the labels
        if let bool = retrieveFromUserDefualt(key: "overlayLabelsVisible") as? Bool {
            BoardViewController.overlayLabelsVisible = bool
        } else {
            BoardViewController.overlayLabelsVisible = false
            saveToUserDefault(obj: false, key: "overlayLabelsVisible")
        }
        overlayLabels.forEach {label in
            label.isHidden = !BoardViewController.overlayLabelsVisible
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func boardDidUpdate() {
        self.boardView.dimension = self.board.dimension
        self.boardView.pieces = self.board.pieces
        self.boardView.lastMoves = self.board.lastMoves
        DispatchQueue.main.async {[unowned self] in
            self.boardView.setNeedsDisplay()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? MenuViewController {
            viewController.boardVC = self
        }
    }
    
    func boardStatusUpdated(msg: String, data: Any?) {
        DispatchQueue.main.async {[unowned self] in
            self.gameStatusLabel.text = msg
            if data != nil {
                if let cos = data as? [Coordinate] {
                    self.boardView.highlightedCoordinates = cos
                    self.boardView.setNeedsDisplay()
                }
            }
        }
    }


}

