//
//  HomeMenuTableViewCell.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/23/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit

class HomeMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var homeMenuLabel: UILabel!
    
    var customUtil = CustomUtil()
    override func awakeFromNib() {
        super.awakeFromNib()
        homeMenuLabel.font = UIFont(name: homeMenuLabel.font.fontName, size: 17)
        homeMenuLabel.textColor = customUtil.hexStringToUIColor(hex: "4D5B65")
        imgIcon.tintColor = customUtil.hexStringToUIColor(hex: "4D5B65")
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
