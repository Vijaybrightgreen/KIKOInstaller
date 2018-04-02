//
//  SetupDeviceViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/9/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
//import SwiftyGif //Commented by Anand on 21Mar18

class TimeToAddDeviceViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        Commented by Anand on 21Mar18
//        let gifManager = SwiftyGifManager(memoryLimit:20)
//        let gif = UIImage(gifName: "point_selection_WT.gif")
//        self.imageView.setGifImage(gif, manager: gifManager)
        
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
    


    @IBAction func nextBtnAction(_ sender: Any) {
         self.performSegue(withIdentifier: "setupDeviceSegue", sender: nil)
    }

    @IBAction func backBtnAction(_ sender: Any) {
         _ = self.navigationController?.popViewController(animated: true)
    }
}
