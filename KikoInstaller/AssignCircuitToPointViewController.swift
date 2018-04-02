//
//  AssignCircuitToPointViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 4/13/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material
import DropDown
import DLRadioButton
import Crashlytics



class AssignCircuitToPointViewController: UIViewController,UITextFieldDelegate,UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
//    @IBOutlet weak var selectDeviceType: UILabel!
//    @IBOutlet weak var selectDeviceText: UILabel!
    
    @IBOutlet weak var radioButton1: DLRadioButton!
    @IBOutlet weak var radioButton2: DLRadioButton!
    
    @IBOutlet weak var assignDevicesToCircuitText: UILabel!
    
//    @IBOutlet weak var toggleSwitch: UISwitch!
    
//    @IBOutlet weak var selectDeviceTypeArrow: UIImageView!
//    @IBOutlet weak var selectDeviceArrow: UIImageView!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    var httpsClient = HttpsClient()
    
    let dropDown = DropDown()
    
    var jsonObj : JSON = JSON.null
    
    var radioButtonArray = [DLRadioButton]()
    
    var currentPointNo = 0
    var currentRoomNo = 0
    var pointStatusData : JSON = JSON.null
    
    var pointId = "0"
    var roomId = "0"
    var pointCircuitId = "CP1"
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingView: UIView = UIView()
    
    var currentAssignCircuitNo = 1
    
    var selectedRadioTag = 1
    
    let properties = GlobalClass.sharedInstance.propertiesJson()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
      
        
//        radioButton1.isSelected = true
        //radioButton1.deselectOtherButtons()
        
//        var radio1 = radioButton1.isSelected
//        var radio2 = radioButton2.isSelected
//        
//        print("radi \(radio1)  \(radio2)")
        
//        selectDeviceType.isUserInteractionEnabled = true
//        selectDeviceText.isUserInteractionEnabled = true
        
//        selectDeviceType.text = "High PowerDevices"
//        selectDeviceText.text = "Heater"

//        let selectDeviceTypeTap = UITapGestureRecognizer(target: self, action: #selector(selectDeviceTypeTap(gesture:)))
//        selectDeviceType.addGestureRecognizer(selectDeviceTypeTap)
//        
//        let selectDeviceTap = UITapGestureRecognizer(target: self, action: #selector(selectDeviceTap(gesture:)))
//        selectDeviceText.addGestureRecognizer(selectDeviceTap)
       
        //Mqtt receive observer
        let name = NSNotification.Name(rawValue: "mqttReceive")
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMessage(notification:)), name: name, object: nil)
        
    }

    func receivedMessage(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String: AnyObject]
        let message = userInfo["message"] as! String
        let topic = userInfo["topic"] as! String
        let name = notification.name.rawValue
        
        if name == "mqttReceive" {
            
            if let data = message.data(using: .utf8) {
                
                print("POINT MQTT MESSAGE:\(message) TOPIC: \(topic)")
                print("POINT Notification name if mqttReceive")
                
                let jsonData = JSON(data: data, options: .mutableContainers, error: nil)
                print("JsonObj", jsonData, "Topic", topic)
                
                let pointId = jsonData["point_id"].stringValue
                let pointCircuitUid = jsonData["point_circuit_uid"].stringValue
                let pointStatus = jsonData["point_status"].stringValue
                let success = jsonData["success"].stringValue
                
                print("pointId \(pointId) pointCircuitUid \(pointCircuitUid) pointStatus \(pointStatus) success \(success)")
                
                if success == "true" {
                    if pointCircuitUid == "CP1" {
                        if pointStatus == "ON" {
                            print("***** CP1 pointStatus ON +++++++++")
                            if (!radioButton1.isSelected) {
                                radioButton1.isSelected = true
                            }
                            print("+++if radioButton1.isSelected ",radioButton1.isSelected)
                        }else  if pointStatus == "OFF" {
                             print("***** CP1 pointStatus OFF +++++++++")
                            if (radioButton1.isSelected) {
                                radioButton1.isSelected = false
                            }
//                            radioButton1.isSelected = false
//                            radioButton1.isSelected = false
                            print("else if radioButton1.isSelected ",radioButton1.isSelected)
                        }else {
                            print("radioButton1 Live mqtt point status not on or off")
                        }
                    } else if pointCircuitUid == "CP2" {
                        if pointStatus == "ON" {
                            print("***** CP2 pointStatus ON +++++++++")
                            if (!radioButton2.isSelected) {
                                radioButton2.isSelected = true
                            }

                            print("+++if radioButton2.isSelected ",radioButton2.isSelected)
                        }else  if pointStatus == "OFF" {
                            print("***** CP2 pointStatus OFF +++++++++")
                            if (radioButton2.isSelected) {
                                radioButton2.isSelected = false
                            }
                            print("else if radioButton2.isSelected ",radioButton2.isSelected)
                        }else {
                            print("radioButton2 Live mqtt point status not on or off")
                        }
                    }
                }else {
                    print("Live mqtt sucess false")
                }
                
            }else {
                print("POINT Notification name else")
            }
            
        }else {
            print("Data is nil")
        }
    }

    
    func getDataFromObject() {
        
        jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        
//        let jsonRoomsCount = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"].count
       
//        selectDeviceType.text = "High PowerDevices"
        //jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][currentRoomNo]["display_name"].stringValue
        
//        selectDeviceText.text = "Heater"
        
//        let jsonPoint = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][currentRoomNo]["point"][currentPointNo]
        
        roomId = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["id"].stringValue
        pointId = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["point"][currentPointNo]["id"].stringValue
        
        print("RoomId \(roomId) PointId  \(pointId )")
        
    }
    
    func pointStatus() {
        print("PoINT STATUS --> \(pointStatusData)")
        
        let dataCount = pointStatusData["data"].count
        print("dataCount \(dataCount)")
        
        let pointCircuitNo = selectedRadioTag - 1
        print("Point circuit no \(pointCircuitNo)")

        if dataCount == 2 {
            
            let pointCircuit1 = pointStatusData["data"][0]["point_status"]["point_circuit_uid"].stringValue
            
            let pointCircuit2 = pointStatusData["data"][1]["point_status"]["point_circuit_uid"].stringValue
            
            let statusCP1 = pointStatusData["data"][0]["point_status"]["status"].stringValue
            
            let statusCP2 = pointStatusData["data"][1]["point_status"]["status"].stringValue
            
            
            print("pointCircuit1 \(pointCircuit1) pointCircuit2 \(pointCircuit2) statusCP1 \(statusCP1) statusCP2 \(statusCP2)")
//            radioButton1.isHidden = false
//            radioButton2.isHidden = false
//            
//            radioButton1.isMultipleSelectionEnabled = true
            
            if pointCircuit1 == "CP1" {
                if statusCP1 == "ON" {
                    radioButton1.isSelected = true
                    //radioButton1.isSelected = true
                    print("statusCP1 ON--' \(radioButton1.isSelected)")
                }else if statusCP1 == "OFF" {
                    radioButton1.isSelected = false
                    radioButton1.isSelected = false
                    print("statusCP1 OFF--' \(radioButton1.isSelected)")
                }else {
                    print("statusCP1 NO status")
                }
            }else {
                print("No CP1")
            }
            
            
            if pointCircuit2 == "CP2" {
                if statusCP2 == "ON" {
                    radioButton2.isSelected = true
                    //radioButton2.isSelected = true
                    print("statusCP2 ON--' \(radioButton2.isSelected)")
                }else if statusCP2 == "OFF" {
                    
                    radioButton2.isSelected = false
                    radioButton2.isSelected = false
                    print("statusCP2 OFF--' \(radioButton2.isSelected)")
                }else {
                    print("statusCP2 NO status")
                }

            }else {
                print("No CP2")
            }
        }else {
            
            print("Data Count not 2")
        }
        
        
//        for i in 0 ..< dataCount {
//            print("I \(i)")
//            
//            let pointCircuitUid = pointStatusData["data"][i]["point_status"]["point_circuit_uid"].stringValue
//            print("pointCircuitUid \(pointCircuitUid)")
//        
//            if pointCircuitUid == "CP1" {
//                let status = pointStatusData["data"][i]["point_status"]["status"].stringValue
//                print("status--> \(status)")
//                if status == "ON" {
//                    radioButton1.isSelected = true
//                    print("Status ON--'")
//                }else if status == "OFF" {
//                     radioButton1.isSelected = false
////                    toggleSwitch.isOn = false
//                    print("Status OFF--'")
//                }else {
//                    print("NO status")
//                }
//            }else if pointCircuitUid == "CP2" {
//                let status = pointStatusData["data"][i]["point_status"]["status"].stringValue
//                print("radioButton2 status--> \(status)")
//                if status == "ON" {
//                    radioButton2.isSelected = true
//                    //                    toggleSwitch.isOn = true
//                    print("radioButton2 Status ON--'")
//                }else if status == "OFF" {
//                    radioButton2.isSelected = false
//                    //                    toggleSwitch.isOn = false
//                    print("radioButton2 Status OFF--'")
//                }else {
//                    print("radioButton2 NO status")
//                }
//            }
//            else {
//                print("Not the current circuit")
//            }
//        }
   
    }

    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
        radioButtonArray = [radioButton1,radioButton2]
        
        radioButton1.otherButtons = [radioButton1,radioButton2]
        
        radioButton1.isMultipleSelectionEnabled = true
        
          pointStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        
        getDataFromObject()
    
        mqttClient.subscribeToTopic(topic: "point_live_status")
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mqttClient.unSubToTopic(topic: "point_live_status")
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

   
    @IBAction func backBtnAction(_ sender: Any) {
        
         _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func radioBtn1Action(_ sender: Any) {
        print("Radio 1")
        
        print("radioButton1.isSelected \(radioButton1.isSelected)")
        
        customUtil.activityIndicatorStart(view: self.view)
        
        if radioButton1.isSelected == true {
            print("radioButton1 is Selected")
            
            let ts = String(Date().timeIntervalSince1970)
            print("Time Stamp",ts)
            
            let headers: [String:String] =  [
                "installer_uid" : "77",
                "email_id" : "john@brightgreen.com"
            ]
            
                print("POINT ON IF  \(roomId)  \(pointId)  \(pointCircuitId) \(ts)")
                
                let parameters: [String:Any] = [
                    "room_uid" : roomId,
                    "point_uid" : pointId,
                    "point_circuit_uid" : "CP1",
                    "point_status" : "ON",
                    "time_stamp" : ts
                ]
                
                let urlPath = properties["Point_Status"].stringValue
                
                print("uuuu-> \(urlPath)")
                
                httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
                    
                    print("Sucess PLAN",response)
//                    self.toggleSwitch.isUserInteractionEnabled = true
                    self.customUtil.activityIndicatorStop(view: self.view)
                    
                    let message = response["msg"].stringValue
                    let success = response["success"].boolValue
                    
                    
                    if(success == true){
                        self.customUtil.toast(view: self, title: "Success", message: message)
                        
                    }else if(success == false){
                        self.customUtil.toast(view: self, title: "Failure", message: message)
//                        self.toggleSwitch.isOn = false
                        self.radioButton1.isSelected = false
                    }else {
                        print("RESPONSE SUCCESS FAILED")
                    }
                    
                    
                }, failCompletionHandler: { response -> Void in
                    
                    print("FAILURE PLAN",response)
//                    self.toggleSwitch.isUserInteractionEnabled = true
                    self.customUtil.activityIndicatorStop(view: self.view)
                    
                    let message = response["msg"].stringValue
                    let success = response["success"].boolValue
                    
                    if(success == false){
                        self.customUtil.toast(view: self, title: "Failure", message: message)
//                        self.toggleSwitch.isOn = false
                         self.radioButton1.isSelected = false
                    }else {
                        print("RESPONSE SUCCESS FAILED")
                    }
                    
                    
                }, error: { error -> Void in
                    print("ON responseString is NIL")
//                    self.toggleSwitch.isUserInteractionEnabled = true
                    self.customUtil.activityIndicatorStop(view: self.view)
                    self.customUtil.toast(view: self, title: "Failure", message: error)
                })
          //RadioButton 1 OFF
        }else {
             print("radioButton1 is DESelected")
            
            print("SWITCH OFF ELSE")
            
            let ts = String(Date().timeIntervalSince1970)
            print("Time Stamp",ts)
            
            let headers: [String:String] =  [
                "installer_uid" : "77",
                "email_id" : "john@brightgreen.com"
            ]
            
            let parameters: [String:Any] = [
                "room_uid" : roomId,
                "point_uid" : pointId,
                "point_circuit_uid" : "CP1",
                "point_status" : "OFF",
                "time_stamp" : ts
            ]
            
            
            let urlPath = properties["Point_Status"].stringValue
            
            httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
                
                print("Sucess RESPONSE",response)
                
//                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                print("Response Message",message)
                print("RESPONSE SUCCESS",success)
                
                if(success == true){
                    self.customUtil.toast(view: self, title: "Success", message: message)
                }else if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
//                    self.toggleSwitch.isOn = true
                     self.radioButton1.isSelected = false
                }else {
                    print("RESPONSE SUCCESS FAILED")
                }
                
                
            }, failCompletionHandler: { response -> Void in
                
                print("FAILURE RESPONSE",response)
                
//                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
//                    self.toggleSwitch.isOn = true
                    self.radioButton1.isSelected = false
                }else {
                    print("RESPONSE FAILED")
                }
                
                
            }, error: { error -> Void in
                print("OFF responseString is NIL")
//                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                self.customUtil.toast(view: self, title: "Failure", message: error)
                
            })

        }
    }
    
    @IBAction func radioBtn2Action(_ sender: Any) {
         print("Radio 2")
        customUtil.activityIndicatorStart(view: self.view)
        print("radioButton2.isSelected \(radioButton2.isSelected)")
        
        if radioButton2.isSelected == true {
            print("radioButton2 is Selected")
            
            let ts = String(Date().timeIntervalSince1970)
            print("Time Stamp",ts)
            
            let headers: [String:String] =  [
                "installer_uid" : "77",
                "email_id" : "john@brightgreen.com"
            ]
            
            print("POINT ON IF  \(roomId)  \(pointId)  \(pointCircuitId) \(ts)")
            
            let parameters: [String:Any] = [
                "room_uid" : roomId,
                "point_uid" : pointId,
                "point_circuit_uid" : "CP2",
                "point_status" : "ON",
                "time_stamp" : ts
            ]
            
            let urlPath = properties["Point_Status"].stringValue
            
            print("uuuu-> \(urlPath)")
            
            httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
                
                print("Sucess PLAN",response)
//                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                
                if(success == true){
                    self.customUtil.toast(view: self, title: "Success", message: message)
                    
                }else if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
//                    self.toggleSwitch.isOn = false
                     self.radioButton2.isSelected = false
                }else {
                    print("RESPONSE SUCCESS FAILED")
                }
                
                
            }, failCompletionHandler: { response -> Void in
                
                print("FAILURE PLAN",response)
//                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
//                    self.toggleSwitch.isOn = false
                    self.radioButton2.isSelected = false
                }else {
                    print("RESPONSE SUCCESS FAILED")
                }
                
                
            }, error: { error -> Void in
                print("ON responseString is NIL")
//                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                self.customUtil.toast(view: self, title: "Failure", message: error)
            })

            
        }else {
            
            print("radioButton2 is DESelected")
            
            print("SWITCH OFF ELSE")
            
            let ts = String(Date().timeIntervalSince1970)
            print("Time Stamp",ts)
            
            let headers: [String:String] =  [
                "installer_uid" : "77",
                "email_id" : "john@brightgreen.com"
            ]
            
            let parameters: [String:Any] = [
                "room_uid" : roomId,
                "point_uid" : pointId,
                "point_circuit_uid" : "CP2",
                "point_status" : "OFF",
                "time_stamp" : ts
            ]
            
            
            let urlPath = properties["Point_Status"].stringValue
            
            httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
                
                print("Sucess RESPONSE",response)
                
//                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                print("Response Message",message)
                print("RESPONSE SUCCESS",success)
                
                if(success == true){
                    self.customUtil.toast(view: self, title: "Success", message: message)
                }else if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
//                    self.toggleSwitch.isOn = true
                    self.radioButton2.isSelected = false
                }else {
                    print("RESPONSE SUCCESS FAILED")
                }
                
                
            }, failCompletionHandler: { response -> Void in
                
                print("FAILURE RESPONSE",response)
                
//                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
//                    self.toggleSwitch.isOn = true
                    self.radioButton2.isSelected = false
                }else {
                    print("RESPONSE FAILED")
                }
                
                
            }, error: { error -> Void in
                print("OFF responseString is NIL")
//                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                self.customUtil.toast(view: self, title: "Failure", message: error)
                
            })

        }

    }
    
    @IBAction func finishBtnAction(_ sender: Any) {
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "room_uid" : roomId,
            "point_uid" : pointId,
            "point_config_sts" : 1
        ]
        
        
        //Alert to configure switch
        let refreshAlert = UIAlertController(title: "Configure Point", message: "Do you wish to finish configuring this point?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle YES logic here")
            
            self.customUtil.activityIndicatorStart(view: self.view)
            
            let urlPath = self.properties["Point_Config"].stringValue
            
            self.httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: {  response -> Void in
                
                print("finishBtnAction Sucess",response)
                
                self.customUtil.activityIndicatorStop(view: self.view)
                
                // TODO: Track the user action that is important for you.
                Answers.logContentView(withName: "KIKO Point", contentType: "Success Point Configuration", contentId: self.pointId, customAttributes: ["room_uid":self.roomId, "point_uid":self.pointId, "res_message" : response.stringValue])
                
                let vc = self.navigationController?.viewControllers.filter({$0 is DeviceSetupViewController}).first
                print("vc",vc!)
                self.navigationController?.popToViewController(vc!, animated: true)
                
                //            //Delay perform Segue by 1.5 seconds
                //            let timeToDissapear : DispatchTime = DispatchTime.now() + 1.5
                //            let when = timeToDissapear
                //            DispatchQueue.main.asyncAfter(deadline: when){
                //
                //            }
                
                self.dismiss(animated: true, completion: nil)
                
                
            }, failCompletionHandler: { response -> Void in
                
                print("finishBtnAction FAILURE",response)
                self.customUtil.activityIndicatorStop(view: self.view)
                
                // TODO: Track the user action that is important for you.
                Answers.logContentView(withName: "KIKO Point", contentType: "Failure Point Configuration", contentId: self.pointId, customAttributes: ["room_uid":self.roomId, "point_uid":self.pointId, "res_message" : response.stringValue])
                
            },  error: {  error -> Void in
                
                print("finishBtnAction Error")
                self.customUtil.activityIndicatorStop(view: self.view)
                
                self.customUtil.toast(view: self, title: "Failure", message: error)
                
                // TODO: Track the user action that is important for you.
                Answers.logContentView(withName: "KIKO Point", contentType: "Error Point Configuration", contentId: self.pointId, customAttributes: ["room_uid":self.roomId, "point_uid":self.pointId, "res_message" : error])
                
            })
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
            //refreshAlert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
        
 
    }
}
