//
//  MenuViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/6/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var LabelArr:Array = [String]()
    var imgArr:Array = [UIImage]()
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LabelArr = ["Home","Design","Install","Help"]
        imgArr = [UIImage(named: "Home")!,UIImage(named: "Editx30")!,UIImage(named: "Thumbx48")!,UIImage(named: "HelpFilledx48")!]
        
//        menuProfileImg.layer.borderColor = customUtil.hexStringToUIColor(hex: "171B1E").cgColor
//        menuProfileImg.layer.borderWidth = 2
//        menuProfileImg.layer.cornerRadius = menuProfileImg.width / 2
//        menuProfileImg.layer.masksToBounds = false
//        menuProfileImg.clipsToBounds = true
        
    }

    // Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LabelArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        cell.imgIcon.image = imgArr[indexPath.row]
        cell.menuLabel.text = LabelArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let revealViewController:SWRevealViewController = self.revealViewController()
        
        let cell:MenuTableViewCell = tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        
        if cell.menuLabel.text! == "Home"
        {
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            
            revealViewController.pushFrontViewController(newFrontViewController, animated: true)
        }
        if cell.menuLabel.text! == "Design"
        {
            let url = NSURL(string: "http://www.eoxys.com/")
            UIApplication.shared.open(url as! URL, options: [:], completionHandler: nil)
            //revealViewController.frontViewController
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        themeColor.createGradientLayer(view: view)
    }
    
    @IBAction func loginSignInBtn(_ sender: Any) {
        
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let newFrontViewController = UINavigationController.init(rootViewController:desController)
        
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
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
