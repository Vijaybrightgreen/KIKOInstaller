//
//  HomeMenuViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/23/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import AWSAuthCore

class HomeMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    var homeLabelArr = [[String]]()
    var imgArr:Array = [[UIImage]]()
    
    let menu1 = ["Installation","Maintenance","Quotes","History"]
    let menu2 = ["Account","Help","Settings"]
    let menu3 = ["Logout"]
    
    let imgMenu1 = [UIImage(named: "PlusFilledx48")!,UIImage(named: "Maintenancex48")!,UIImage(named: "Quotesx48")!,UIImage(named: "historyx48")!]
    let imgMenu2 = [UIImage(named: "Userx48")!,UIImage(named: "HelpFilledx48")!,UIImage(named: "Settingsx48")!]
    let imgMenu3 = [UIImage(named: "MenuLogoutx48")!]
    
//    var sectionArr:Array = [String]()
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.textColor = UIColor.white
        
        homeLabelArr.append(menu1)
        homeLabelArr.append(menu2)
        homeLabelArr.append(menu3)
        print("array",homeLabelArr)
        
        imgArr.append(imgMenu1)
        imgArr.append(imgMenu2)
        imgArr.append(imgMenu3)
        
        let userStore:UserStore = GlobalClass.sharedInstance.getUserStore()
        let user = userStore.getAt(index: 0)

        print("userName -> \(user.userName)")
       
        userNameLabel.text = user.userName
        
        //        menuProfileImg.layer.borderColor = customUtil.hexStringToUIColor(hex: "171B1E").cgColor
        //        menuProfileImg.layer.borderWidth = 2
        //        menuProfileImg.layer.cornerRadius = menuProfileImg.width / 2
        //        menuProfileImg.layer.masksToBounds = false
        //        menuProfileImg.clipsToBounds = true
        
    }
    
    // Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("noRowsInSec \(menu1.count)")
        var rowCount = 0
        
        if section == 0{
            rowCount = menu1.count
        }else if section == 1 {
            rowCount = menu2.count
        }else{
            rowCount = menu3.count
        }
        
        return rowCount
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMenuTableViewCell") as! HomeMenuTableViewCell
        cell.imgIcon.image = imgArr[indexPath.section][indexPath.row]
        cell.homeMenuLabel.text = homeLabelArr[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let revealViewController:SWRevealViewController = self.revealViewController()
        
        let cell:HomeMenuTableViewCell = tableView.cellForRow(at: indexPath) as! HomeMenuTableViewCell
        
        if cell.homeMenuLabel.text! == "Installation"
        {

            print("Installation")
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "InstallationViewController") as! InstallationViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            //revealViewController.pushFrontViewController(newFrontViewController, animated: true)
            self.show(newFrontViewController, sender: nil)
            //self.present(newFrontViewController, animated: true, completion: nil)
            revealViewController.revealToggle(animated: true)
        }
        if cell.homeMenuLabel.text! == "Maintenance"
        {
            
            print("Maintenance")
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "MaintenanceViewController") as! MaintenanceViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            //revealViewController.pushFrontViewController(newFrontViewController, animated: true)
            self.show(newFrontViewController, sender: nil)
            revealViewController.revealToggle(animated: true)

            //self.present(newFrontViewController, animated: true, completion: nil)
        }
        if cell.homeMenuLabel.text! == "Quotes"
        {
            
            print("Quotes")
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "QuotesViewController") as! QuotesViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            //revealViewController.pushFrontViewController(newFrontViewController, animated: true)
            self.show(newFrontViewController, sender: nil)
            revealViewController.revealToggle(animated: true)
            
        }
        if cell.homeMenuLabel.text! == "History"
        {
            
            print("History")
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            //revealViewController.pushFrontViewController(newFrontViewController, animated: true)
            self.show(newFrontViewController, sender: nil)
            revealViewController.revealToggle(animated: true)
            
        }
//        if cell.homeMenuLabel.text! == "Home"
//        {
//            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let desController = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//            let newFrontViewController = UINavigationController.init(rootViewController:desController)
//            
//            revealViewController.pushFrontViewController(newFrontViewController, animated: true)
//        }
//        if cell.homeMenuLabel.text! == "Install"
//        {
//            let url = NSURL(string: "http://www.eoxys.com/")
//            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
//           
//        }
        if cell.homeMenuLabel.text! == "Account"
        {
            
            print("Account")
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
//            revealViewController.pushFrontViewController(newFrontViewController, animated: true)
//            self.show(newFrontViewController, sender: nil)
            revealViewController.revealToggle(animated: true)
            
            self.present(newFrontViewController, animated: true, completion: nil)
        }
        if cell.homeMenuLabel.text! == "Help"
        {
            
            print("Help")
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            //            revealViewController.pushFrontViewController(newFrontViewController, animated: true)
            //            self.show(newFrontViewController, sender: nil)
            revealViewController.revealToggle(animated: true)
            
            self.present(newFrontViewController, animated: true, completion: nil)
        }
        if cell.homeMenuLabel.text! == "Settings"
        {
            
            print("Settings")
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            //            revealViewController.pushFrontViewController(newFrontViewController, animated: true)
            //            self.show(newFrontViewController, sender: nil)
            revealViewController.revealToggle(animated: true)
            
            self.present(newFrontViewController, animated: true, completion: nil)
        }
        if cell.homeMenuLabel.text! == "Logout"
        {
            print("handleLogout")
            
            
            let refreshAlert = UIAlertController(title: "Logout", message: "Do you wish to logout?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle YES logic here")
                
                if (AWSSignInManager.sharedInstance().isLoggedIn) {
                    AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?,  error: Error?) in
                        DispatchQueue.main.async(execute: {
                            print("Logged Out")
                            self.dismiss(animated: true, completion: nil)
                        })
                        //SessionController.sharedInstance.resetSession()
                    })
                    // print("Logout Successful: \(signInProvider.getDisplayName)");
                } else {
                    assert(false)
                }
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle No Logic here")
                revealViewController.revealToggle(animated: true)
                //refreshAlert.dismiss(animated: true, completion: nil)
            }))
            present(refreshAlert, animated: true, completion: nil)
        }
//        {
//            //Alert to logout
//            let refreshAlert = UIAlertController(title: "Logout", message: "Do you wish to logout?", preferredStyle: UIAlertControllerStyle.alert)
//
//            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
//                print("Handle YES logic here")
//
//                //Clear authentication
//                UserDefaults.standard.set(nil, forKey: "userId")
//                UserDefaults.standard.set(nil, forKey: "userUid")
//                print("Authentication Clear")
//
//                 revealViewController.revealToggle(animated: false)
//
//                self.dismiss(animated: true, completion: nil)
//
//            }))
//
//            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
//                print("Handle No Logic here")
//                 revealViewController.revealToggle(animated: true)
//                //refreshAlert.dismiss(animated: true, completion: nil)
//            }))
//
//
//
//            present(refreshAlert, animated: true, completion: nil)
//
//
//        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //Table Footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
        footerView.backgroundColor = UIColor.black
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    

    override func viewWillAppear(_ animated: Bool) {
        themeColor.createGradientLayer(view: view)
    }
    
}
