//
//  ModelSelectionViewController.swift
//  Gobang
//
//  Created by Jiachen Ren on 12/10/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class ModelSelectionViewController: UIViewController {

    @IBAction func humanVsHumanButtonTouched(_ sender: UIButton) {
        self.performSegue(withIdentifier: "human.vs.human", sender: "human.vs.human")
    }
    
    @IBAction func humanVsAIButtonTouched(_ sender: UIButton) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let content = sender as? String {
            switch (content) {
            case "human.vs.human": break
            default: break
            }
        }
    }
    

}
