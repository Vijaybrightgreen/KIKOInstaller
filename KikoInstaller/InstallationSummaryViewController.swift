//
//  InstallationSummaryViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 7/6/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit

var endTime = TimeInterval()

class InstallationSummaryViewController: UIViewController {

    @IBOutlet weak var totalRooms: UILabel!
    @IBOutlet weak var totalDevices: UILabel!
    @IBOutlet weak var totalTimeTaken: UILabel!
   
    var httpsClient = HttpsClient()
    var customUtil = CustomUtil()
    
    var areaId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        
        endTime = date.timeIntervalSince1970

        if isTimerRunning == true {
            //isTimerRunning = false
            let timediff = endTime - startTime
            print("endTime \(endTime)  \(timediff)")
            
            let timeDiffString = timediff.stringTime
            print("timeDiffString \(timeDiffString)")
            
            totalTimeTaken.text = timeDiffString
        } else {
            print("Timer Not Running")
        }
    
        // Do any additional setup after loading the view.
    }
    
    func requestData() {
        
        print("InstallationSummaryViewController areaId \(areaId)")
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "area_uid" : areaId
        ]
        
        
        let properties = GlobalClass.sharedInstance.propertiesJson()
        let urlPath = properties["Installation_Summary"].stringValue
        
        httpsClient.postRequest(urlPath: urlPath, headers: headers , parameters: parameters, sucCompletionHandler: { response -> Void in
            print("sucCompletionHandler RESPONSE -->",response)
            self.totalRooms.text = response["No.of Rooms"].stringValue + " rooms"
            self.totalDevices.text = response["No.of Devices"].stringValue + " devices"
            
        }, failCompletionHandler: { response -> Void in
            
            print("failCompletionHandler RESPONSE -->",response)
            self.customUtil.toast(view: self, title: "Failure", message: " ")
            
            
        }, error: {  error -> Void in
            print("error Response",error)
            
            self.customUtil.toast(view: self, title: "Failure", message:error)
        })

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestData()
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

   
    @IBAction func finishBtnAction(_ sender: Any) {
        
        navigationController?.popToRootViewController(animated: true)
        
        mqttClient.disconnectMqtt()
        
    }
 

    @IBAction func backBtnAction(_ sender: Any) {
        
         _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}

extension TimeInterval{
    var milliseconds: Int{
        return Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
    }
    var seconds: Int{
        return Int(self.remainder(dividingBy: 60))
    }
    var minutes: Int{
        return Int((self/60).remainder(dividingBy: 60))
    }
    var hours: Int{
        return Int(self / (60*60))
    }
    var stringTime: String{
        if self.hours != 0{
            return "\(self.hours)h \(self.minutes)m"   //"\(self.hours)h \(self.minutes)m \(self.seconds)s"
        }else if self.minutes != 0{
            return "\(self.minutes)m \(self.seconds)s"
        }else if self.milliseconds != 0{
            return "\(self.seconds)s \(self.milliseconds)ms"
        }else{
            return "\(self.seconds)s"
        }
    }
}
