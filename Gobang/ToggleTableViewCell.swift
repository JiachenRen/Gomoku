//
//  ToggleTableViewCell.swift
//  Gobang
//
//  Created by Jiachen Ren on 12/26/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class ToggleTableViewCell: UITableViewCell {

    @IBOutlet weak var toggleSwitch: UISwitch!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func toggleSwitchChanged(_ sender: UISwitch) {
        toggleClosure?()
    }
    
    var toggleClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
