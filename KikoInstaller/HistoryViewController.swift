//
//  HistoryViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 12/4/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var sortBtn: UIBarButtonItem!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }


    func isUIViewControllerPresentedAsModal() -> Bool {
        //        if((self.presentingViewController) != nil) {
        //            print("presentingViewController")
        //            return true
        //        }
        
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
        
        
        customUtil.navTitle(text: "History", view: self)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
        themeColor.createGradientLayer(view: view)
        
        searchBtn.tintColor = themeColor.BarButtonColor
        sortBtn.tintColor = themeColor.BarButtonColor
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        customUtil.removeNavTitle(view: self)
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        
        print("History Back Button")
    
        let res = isUIViewControllerPresentedAsModal()
        print("RESULT \(res)")
        if res == true {
            self.dismiss(animated: true, completion: nil)
        }
        else{
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
}
