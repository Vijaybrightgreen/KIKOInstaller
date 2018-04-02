//
//  ForgotPasswordViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/3/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Material

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var emailText: TextField!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         //emailText
        emailText.textColor = UIColor.white
        emailText.placeholderNormalColor = themeColor.placeholderNormalColor
        emailText.placeholderActiveColor = themeColor.placeholderActiveColor
        emailText.dividerNormalColor = themeColor.dividerNormalColor
        emailText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        emailText.clearIconButton?.tintColor = themeColor.clearBtnTintColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        emailText.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        themeColor.createGradientLayer(view: view)
    }
    
    @IBAction func closeBtn(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
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
