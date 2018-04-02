//
//  ViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 12/28/16.
//  Copyright © 2016 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as UIViewController
//        self.present(vc, animated: true, completion: nil)
        
        
       // self.performSegue(withIdentifier:"revealSegue", sender: self)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        // Do any additional setup after loading the view, typically from a nib.
     
    }
    
    func getUserId() -> String? {
        let userId = UserDefaults.standard.string(forKey: "userId")
        print("userId \(String(describing: userId))")
        return userId
    }
    
    func checkUserId(userId:String) {
        
        if let path = Bundle.main.path(forResource: "checkUserId", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = JSON(data: data)
                
                let userId = jsonObj["param"]["userId"].string
                let userUid = jsonObj["param"]["userUid"].string
                let userName = jsonObj["user"]["username"].string
                let act = jsonObj["act"].string
            
                print("User Uid:\(String(describing: userUid))")
                print("User Id:\(String(describing: userId))")
                print("User Name: \(String(describing: userName))")
                print("act: \(String(describing: act))")
                
                if userId != nil && userUid != nil && userName != nil{
                    let user = UserStore()
                    user.add(userUid: userUid!, userId: userId!, userName: userName!)
                    GlobalClass.sharedInstance.setUserStore(user: user)
                    UserDefaults.standard.set(userUid!, forKey: "userUid")
                    UserDefaults.standard.set(userId, forKey: "userId")
                    UserDefaults.standard.set(userName, forKey: "userName")
                    
                    
                    self.performSegue(withIdentifier: "alreadyLoggedinSegue", sender: self)
//                    let desCont = storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
//                    self.show(desCont!, sender: nil)

                }else{
                    print("Segue to Login")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as UIViewController
                    self.present(vc, animated: true, completion: nil)
                }
                
                
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Splash View Did Appear")
        let userId = getUserId()
        if userId != nil{
            checkUserId(userId: userId!)
        }else {
            print("Check userId Failed")
            
            self.performSegue(withIdentifier: "revealSegue", sender: nil)
            
            //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //            let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as UIViewController
            //            self.present(vc, animated: true, completion: nil)
        }
        
    }
    


}

