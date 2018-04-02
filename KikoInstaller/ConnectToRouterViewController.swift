//
//  ConnectToRouterViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 4/26/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

var startTime = TimeInterval()
var isTimerRunning = Bool()

class ConnectToRouterViewController: UIViewController {
    
    var httpsClient = HttpsClient()
    var customUtil = CustomUtil()
   
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        
        isTimerRunning = true
        startTime = date.timeIntervalSince1970
        print("startTime \(startTime)")
        
        print("hour \(hour) \(minutes)")
        
        
        
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
    
    func sendInstallerDetails() {
        customUtil.activityIndicatorStart(view: view)
        
        let parameters: [String:Any] = [
            "installer_uid" : "77",
            "uname" : "John",
            "email_id" : "john@brightgreen.com",
            "first_name" : "John",
            "last_name" : "Carter"
        ]
        
        // let urlPath = "/installer-details?"
        
        let properties = GlobalClass.sharedInstance.propertiesJson()
        let urlPath = properties["Installer_Details"].stringValue
        print("URL Path",urlPath)
        
        httpsClient.postRequest(urlPath: urlPath, headers: [:], parameters: parameters, sucCompletionHandler: {response -> Void in
            
            print("sucCompletionHandler RESPONSE -->",response)
            self.customUtil.activityIndicatorStop(view: self.view)
            
            let message = response["message"].stringValue
            let success = response["success"].boolValue
            
            print("Response Message",message)
            print("RESPONSE SUCCESS",success)
            
            if(success == true){
               // self.customUtil.toast(view: self, title: "Success", message: message)
                //Delay perform Segue by 1.5 seconds
//                let timeToDissapear : DispatchTime = DispatchTime.now() + 1.5
//                let when = timeToDissapear
//                DispatchQueue.main.asyncAfter(deadline: when){
//                    self.performSegue(withIdentifier: "setupRouterSegue", sender: nil)
//                }
                self.performSegue(withIdentifier: "setupRouterSegue", sender: nil)
                
            }else if(success == false){
                print("Failure-----")
                self.customUtil.toast(view: self, title: "Failure", message: message)
            }else {
                print("RESPONSE SUCCESS FAILED")
            }
            
            
            
        }, failCompletionHandler: { response -> Void in
            
            print("failCompletionHandler RESPONSE -->",response)
            self.customUtil.activityIndicatorStop(view: self.view)
            //self.customUtil.toast(view: self, title: "Failure", message: "Check the Server Status")
            
            let message = response["msg"].stringValue
            
            self.customUtil.toast(view: self, title: "Failure", message: message)
            
        }, error: { error -> Void in
            
            print("error Response",error)
            self.customUtil.activityIndicatorStop(view: self.view)
            
            self.customUtil.toast(view: self, title: "Failure", message: error)
            
        })
    }
   
    

    @IBAction func nextBtnAction(_ sender: Any) {

        sendInstallerDetails()
        
//        sessionManager.request("https://byet.host/free-hosting").responseString { response in
//            print("All Response Info: \(response)")
//
//        }

        
//       customUtil.activityIndicatorStart(view: view)
//
//        let parameters: [String:Any] = [
//            "installer_uid" : "66",
//            "uname" : "kiko",
//            "email_id" : "kiko"
//        ]
//
//       // let urlPath = "/installer-details?"
//        
//        let properties = GlobalClass.sharedInstance.propertiesJson()
//        let urlPath = properties["Installer_Details"].stringValue
//        print("URL Path",urlPath)
//        
//        httpClient.postRequest(urlPath: urlPath, parameters: parameters, sucCompletionHandler: {response -> Void in
//            
//            print("sucCompletionHandler RESPONSE -->",response)
//            self.customUtil.activityIndicatorStop(view: self.view)
//            
//            let message = response["message"].stringValue
//            let success = response["success"].boolValue
//            
//            print("Response Message",message)
//            print("RESPONSE SUCCESS",success)
//
//            if(success == true){
//                self.customUtil.toast(view: self, title: "Success", message: message)
//                //Delay perform Segue by 1.5 seconds
//                let timeToDissapear : DispatchTime = DispatchTime.now() + 1.5
//                let when = timeToDissapear
//                DispatchQueue.main.asyncAfter(deadline: when){
//                    self.performSegue(withIdentifier: "setupRouterSegue", sender: nil)
//                }
//            }else if(success == false){
//                print("Failure-----")
//                self.customUtil.toast(view: self, title: "Failure", message: message)
//            }else {
//                print("RESPONSE SUCCESS FAILED")
//            }
//          
//           
//         
//        }, failCompletionHandler: { response -> Void in
//            
//            print("failCompletionHandler RESPONSE -->",response)
//            self.customUtil.activityIndicatorStop(view: self.view)
//            //self.customUtil.toast(view: self, title: "Failure", message: "Check the Server Status")
//            
//            let message = response["msg"].stringValue
//            
//            self.customUtil.toast(view: self, title: "Failure", message: message)
//           
//        }, error: { error -> Void in
//            
//            print("error Response",error)
//            self.customUtil.activityIndicatorStop(view: self.view)
//            
//            self.customUtil.toast(view: self, title: "Failure", message: error)
//            
//        })

        
        
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
           _ = self.navigationController?.popViewController(animated: true)
    }
}
