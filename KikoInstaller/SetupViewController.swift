//
//  SetupViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/27/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit


class SetupViewController: UIViewController {

    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
//        navTitle(text: "Configure")
        customUtil.navTitle(text: "Setup", view: self)
        self.view.backgroundColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        let backBtn = UIBarButtonItem(image: UIImage(named:"Leftx48"), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customUtil.removeNavTitle(view: self)
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        self.navigationController?.navigationBar.willRemoveSubview(label)
//    }
    
    func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func setupNewBtnAction(_ sender: Any) {
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let desController = mainStoryboard.instantiateViewController(withIdentifier: "InstallationViewController") as! InstallationViewController
        navigationController?.pushViewController(desController, animated: true)
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
