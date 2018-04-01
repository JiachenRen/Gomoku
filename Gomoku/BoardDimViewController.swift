//
//  BoardDimViewController.swift
//  Gobang
//
//  Created by Jiachen Ren on 12/20/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class BoardDimViewController: UIViewController {

    @IBOutlet weak var dimLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var marginLabel: UILabel!
    
    @IBOutlet weak var dimSlider: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var marginSlider: UISlider!
    
    @IBOutlet weak var boardView: BoardView!
    
    var board: Board {
        get {
            return Board.sharedInstance
        }
    }
    
    
    let numFormatter = NumberFormatter()
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        switch sender.restorationIdentifier! {
        case "dimension":
            let val = Int(sender.value)
            dimLabel.text = "\(val) x \(val)"
            saveToUserDefault(obj: Int(sender.value), key: "dimension")
        case "radius":
            let formatted = numFormatter.string(for: sender.value)!
            radiusLabel.text = "x \(formatted)"
            saveToUserDefault(obj: sender.value, key: "radius")
        case "margin":
            marginLabel.text = "\(numFormatter.string(for: sender.value)!) px"
            saveToUserDefault(obj: sender.value, key: "margin")
        default: break
        }
        boardView.reloadBoardSettings()
        if sender.restorationIdentifier! == "dimension" {
            board.spawnPseudoPieces()
            boardView.pieces = board.pieces
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //initialize number formatter
        numFormatter.usesSignificantDigits = true
        numFormatter.maximumSignificantDigits = 3
        
        if let dim = retrieveFromUserDefualt(key: "dimension") as? Int {
            dimLabel.text = "\(dim) x \(dim)"
            dimSlider.value = Float(dim)
        }
        if let radius = retrieveFromUserDefualt(key: "radius") as? Float {
            radiusLabel.text = "x \(numFormatter.string(for: radius)!)"
            radiusSlider.value = radius
        }
        if let margin = retrieveFromUserDefualt(key: "margin") as? Float {
            marginLabel.text = "\(numFormatter.string(for: margin)!) px"
            marginSlider.value = margin
        }
        
        boardView.reloadBoardSettings()
        
        board.spawnPseudoPieces()
        boardView.dimension = board.dimension
        boardView.pieces = board.pieces
        self.boardView.setNeedsDisplay()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        boardView.setNeedsDisplay()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
