//
//  MenuTableViewCell.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/6/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    var customUtil = CustomUtil()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        menuLabel.font = UIFont(name: menuLabel.font.fontName, size: 17)
        menuLabel.textColor = customUtil.hexStringToUIColor(hex: "4D5B65")
        imgIcon.tintColor = customUtil.hexStringToUIColor(hex: "4D5B65")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
