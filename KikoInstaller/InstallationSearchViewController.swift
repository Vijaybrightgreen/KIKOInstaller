//
//  InstallationSearchViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 2/3/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Material

class InstallationSearchViewController: UIViewController {

    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var searchField: TextField!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //searchField
        searchField.placeholderNormalColor = themeColor.placeholderNormalColor
        searchField.placeholderActiveColor = themeColor.placeholderActiveColor
        searchField.dividerNormalColor = themeColor.dividerNormalColor
        searchField.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        searchField.clearIconButton?.tintColor = themeColor.clearBtnTintColor
        
        
        
        searchField.placeholderVerticalOffset = 10
        
        //        if (searchField.isFocused == true) {
        //            searchField.placeholderLabel.text = ""
        //        }else {
        //            searchField.placeholderLabel.text = "Search"
        //        }
        
        _ = searchField.becomeFirstResponder()
        
        backBtn.tintColor = themeColor.BarButtonColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        view.addGestureRecognizer(tapGesture)

    }
    
    //Tap gesture selector
    func tap(gesture: UITapGestureRecognizer){
        searchField.resignFirstResponder()
        
        //revealViewController().rightRevealToggle(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        themeColor.createGradientLayer(view: view)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
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
