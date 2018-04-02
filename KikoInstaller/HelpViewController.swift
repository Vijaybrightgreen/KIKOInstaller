//
//  HelpViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 12/4/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var closeBtn: UIBarButtonItem!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func isUIViewControllerPresentedAsModal() -> Bool {
        
        if(self.presentingViewController?.presentedViewController == self) {
            print("presentedViewController")
            return true
        }
        
        if(self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
            print("MODEL FROM MENU WITH NAV")
            
            return true
        }
        
        print("PUSH")
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Settings VIEWWILLAPPEAR")
        
        customUtil.navTitle(text: "Help", view: self)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBgColor)
        themeColor.createGradientLayer(view: view)
        closeBtn.tintColor = themeColor.BarButtonColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Account viewWillDisappear")
        customUtil.removeNavTitle(view: self)
    }

    @IBAction func closeBtnAction(_ sender: Any) {
        
        let res = isUIViewControllerPresentedAsModal()
        print("RESULT \(res)")
        if res == true {
            print("123 if")
            self.dismiss(animated: true, completion: nil)
        }
        else{
            print("456 else ")
            
            //Close Push Segue with animation
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionReveal
            transition.subtype = kCATransitionFromBottom
            navigationController?.view.layer.add(transition, forKey: nil)
            _ = navigationController?.popViewController(animated: false)
            
        }
        
    }

}
