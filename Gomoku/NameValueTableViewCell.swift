//
//  NameValueTableViewCell.swift
//  Gobang
//
//  Created by Jiachen Ren on 12/20/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class NameValueTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    var segueIdentifier: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
