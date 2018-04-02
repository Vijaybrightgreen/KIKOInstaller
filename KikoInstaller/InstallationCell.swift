//
//  InstallationCell.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/28/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit

class InstallationCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareIconImage: UIImageView!
    @IBOutlet weak var confirmIconImage: UIImageView!
        
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
