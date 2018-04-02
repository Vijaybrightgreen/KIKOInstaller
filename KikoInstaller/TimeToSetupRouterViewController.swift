//
//  SetupRouterViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/3/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class TimeToSetupRouterViewController: UIViewController {
    
    var planJsonObj : JSON = JSON.null
    var customUtil = CustomUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
  

//        getPlanFromGlobal()
        
        // Do any additional setup after loading the view.
    }
    
    func getPlanFromGlobal() {
        planJsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        print("planJsonObj",planJsonObj)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getPlanFromGlobal()
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.backBarButtonItem = nil
      
    }
    
    @IBAction func nextBtnAction(_ sender: Any) {
        
        self.customUtil.activityIndicatorStart(view: self.view)
        
        let jsonString = planJsonObj.rawString()
        print("jsonString-->",jsonString!)
        let jsonData = jsonString?.data(using: String.Encoding.utf8)
        
        print("jsonDATA-->",jsonData!)
        
        let headers: HTTPHeaders =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let properties = GlobalClass.sharedInstance.propertiesJson()
        let host = properties["Host"].stringValue
        let urlPath = properties["House_Plan"].stringValue
        let url = host + urlPath
        print("URL Path",host+urlPath)
        
        sessionManager.upload(multipartFormData: { (multipartFormData) in
            
            //            for (key, value) in parameters {
            //                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            //            }
            
            multipartFormData.append(jsonData!, withName: "plan_orig_json", fileName: "plan_orig_json", mimeType: "application/json")
            
        }, to: url, method:.post, headers:headers)
        { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                    print("Progress",progress)
                })
                
                upload.responseJSON { response in
                    print("sucCompletionHandler RESPONSE -->",response)
                    
                    if response.result.value != nil {
                        
                        let jsonResponse = JSON(response.result.value!)
                        print("jsonRes->",jsonResponse)
                        
                        let success = jsonResponse["success"].boolValue
                        print("STATUS",success)
                        
                        let message = jsonResponse["message"].stringValue
                        print("MESSAGE->",message)
                        
                        if (success == true) {
                            print("SUCCESS TRUE")
                            self.customUtil.activityIndicatorStop(view: self.view)
                            
                            //self.customUtil.toast(view: self, title: "Success", message: message)
                            
                            //Delay perform Segue by 1.5 seconds
//                            let timeToDissapear : DispatchTime = DispatchTime.now() + 1.5
//                            let when = timeToDissapear
//                            DispatchQueue.main.asyncAfter(deadline: when){
//                                self.performSegue(withIdentifier: "routerLocationSegue", sender: nil)
//                            }
                            
                            self.performSegue(withIdentifier: "routerLocationSegue", sender: nil)
                            
                        }else if (success == false) {
                            print("SUCCESS False")
                            self.customUtil.activityIndicatorStop(view: self.view)
                            
                            self.customUtil.toast(view: self, title: "Failure", message: message)
                            
                        }else {
                            print("Exception Status value is not true or false")
                            self.customUtil.activityIndicatorStop(view: self.view)
                        }
                        
                    }else{
                        
                        print("Response is NIL")
                        let jsonResponse = response.error?.localizedDescription
                        print("jsonRes->",jsonResponse!)
                        
                        self.customUtil.activityIndicatorStop(view: self.view)
                        
                        self.customUtil.toast(view: self, title: "Failure", message: jsonResponse!)
                    }
                }
                
            case .failure(let encodingError):
                //print encodingError.description
                print("ERROR:",encodingError.localizedDescription)
                //print("failCompletionHandler RESPONSE -->",response)
                
                self.customUtil.activityIndicatorStop(view: self.view)
                self.customUtil.toast(view: self, title: "Failure", message: "Check the Server Status")
            }
        }
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }


}
