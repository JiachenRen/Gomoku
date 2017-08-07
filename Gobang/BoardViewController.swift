//
//  ViewController.swift
//  Gobang
//
//  Created by Jiachen Ren on 8/7/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController, BoardDelegate {
    
    @IBOutlet weak var boardView: BoardView!
    
    var board: BoardProtocol {
        return Board.sharedInstance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Board.sharedInstance.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func boardDidUpdate() {
        boardView.dimension = self.board.dimension
    }


}

