//
//  MenuViewController.swift
//  Gobang
//
//  Created by Jiachen Ren on 12/10/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    var boardVC: BoardViewController!
    var board: Board {
        get {
            return Board.sharedInstance
        }
    }
    
    @IBOutlet weak var showStepsButton: UIButton!
    
    @IBAction func showStepsButtonPressed(_ sender: UIButton) {
        board.displayDigits = !board.displayDigits
        board.delegate?.boardDidUpdate()
        updateShowStepsButton()
        self.dismiss(animated: true, completion: nil)
    }
    
    //This bug took me a while to find...
    private func updateShowStepsButton() {
        showStepsButton.setTitle(board.displayDigits ? "Hide Steps" : "Show Steps", for: .normal)
//        showStepsButton.titleLabel?.text = board.displayDigits ? "Hide Steps" : "Show Steps"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateShowStepsButton()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTouched(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        Board.sharedInstance.reset()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func mainMenuPressed(_ sender: UIButton) {
        Board.sharedInstance.intelligence = nil
        Board.sharedInstance.reset()
        performSegue(withIdentifier: "back.to.main", sender: nil)
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
