//
//  ActivateSwitchSensorsViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 10/12/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit

class ActivateSwitchSensorsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func backBtnAction(_ sender: Any) {
          _ = self.navigationController?.popViewController(animated: true)
    }

}
