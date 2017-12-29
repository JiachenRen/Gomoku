//
//  IntelConfigViewController.swift
//  Gobang
//
//  Created by Jiachen Ren on 12/10/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class IntelConfigViewController: UIViewController {

    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var simpleButton: UIButton!
    
    @IBOutlet weak var playerFirstButton: UIButton!
    @IBOutlet weak var aiFirstButton: UIButton!
    
    @IBOutlet weak var beginButton: UIButton!
    
    let highlightColor: UIColor = UIColor.orange.withAlphaComponent(0.75)
    var orgBgrdColor: UIColor!
    
    @IBAction func levelButtonTouched(_ sender: UIButton) {
        if self.levelSelected == nil && self.ruleSelected == nil {
            self.orgBgrdColor = hardButton.backgroundColor
        }
        self.levelSelected = Level(rawValue: sender.titleLabel!.text!)
        print(self.levelSelected!.rawValue)
        switch self.levelSelected! {
        case .hard:
            hardButton.backgroundColor = highlightColor
            mediumButton.backgroundColor = orgBgrdColor
            simpleButton.backgroundColor = orgBgrdColor
        case .medium:
            hardButton.backgroundColor = orgBgrdColor
            mediumButton.backgroundColor = highlightColor
            simpleButton.backgroundColor = orgBgrdColor
        case .simple:
            hardButton.backgroundColor = orgBgrdColor
            mediumButton.backgroundColor = orgBgrdColor
            simpleButton.backgroundColor = highlightColor
        }
        updateBeginButton()
    }
    
    @IBAction func ruleButtonPressed(_ sender: UIButton) {
        if self.levelSelected == nil && self.ruleSelected == nil {
            self.orgBgrdColor = hardButton.backgroundColor
        }
        self.ruleSelected = Rule(rawValue: sender.titleLabel!.text!)
        switch ruleSelected! {
        case .aiFirst:
            aiFirstButton.backgroundColor = highlightColor
            playerFirstButton.backgroundColor = orgBgrdColor
        default:
            aiFirstButton.backgroundColor = orgBgrdColor
            playerFirstButton.backgroundColor = highlightColor
        }
        updateBeginButton()
    }
    
    func updateBeginButton() {
        if levelSelected != nil && ruleSelected != nil {
            beginButton.backgroundColor = UIColor(red: 0.2647, green: 0.6961, blue: 0.9765, alpha: 0.75)
            beginButton.isUserInteractionEnabled = true
        }
    }
    
    var levelSelected: Level?
    var ruleSelected: Rule?
    
    enum Level: String {
        case hard = "Hard"
        case medium = "Medium"
        case simple = "Simple"
    }
    
    enum Rule: String {
        case aiFirst = "AI First"
        case playerFirst = "Player First"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beginButton.isUserInteractionEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let boardVC = segue.destination as? BoardViewController {
            switch levelSelected! {
            case .simple: boardVC.board.intelligence = Intelligence(color:
                ruleSelected! == .aiFirst ? .black : .white, depth: -1)
            case .medium: boardVC.board.intelligence = Intelligence(color:
                ruleSelected! == .aiFirst ? .black : .white, depth: 2)
            case .hard: boardVC.board.intelligence = Intelligence(color:
                ruleSelected! == .aiFirst ? .black : .white, depth: 3)
            }
            Board.sharedInstance.reset()
        }
    }
    

}
