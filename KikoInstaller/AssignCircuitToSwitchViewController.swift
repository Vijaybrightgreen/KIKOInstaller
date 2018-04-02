//
//  AssignCircuitToSwitchViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/20/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material
import DropDown
import DLRadioButton
import Crashlytics


class AssignCircuitToSwitchViewController: UIViewController,UITextFieldDelegate,UIScrollViewDelegate {

    @IBOutlet weak var toggleSwitch: UISwitch!

    @IBOutlet weak var assignCircuitToSwitchLabel: UILabel!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var endDeviceLabel: UILabel!
    @IBOutlet weak var roomNameArrow: UIImageView!
    @IBOutlet weak var devicesArrow: UIImageView!
    
    @IBOutlet weak var radioSwitch1: DLRadioButton!
    @IBOutlet weak var radioSwitch2: DLRadioButton!
    @IBOutlet weak var radioSwitch3: DLRadioButton!
    @IBOutlet weak var radioSwitch4: DLRadioButton!
    @IBOutlet weak var radioSwitch5: DLRadioButton!
    @IBOutlet weak var radioSwitch6: DLRadioButton!
    @IBOutlet weak var radioSwitch7: DLRadioButton!
    @IBOutlet weak var radioSwitch8: DLRadioButton!
    @IBOutlet weak var radioSwitch9: DLRadioButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var editCircuitBtn: FlatButton!

    
    let snackbar = Snackbar()
    
    var radioButtonArray = [DLRadioButton]()
    
    let customView = UIView()
   
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    var httpsClient = HttpsClient()

    
    let dropDown = DropDown()
    
    var jsonObj : JSON = JSON.null
    
    var roomsNameArray = [String]()
    
    var circuitArray = [String]()
  
    
    var currentswitchNo = 0
    var currentRoomNo = 0
    var switchStatusData : JSON = JSON.null
    

    
    var areaId = ""
    var switchId = "0"
    var roomId = "0"
    var circuitId = ""
    
    var switchCircuitId = "CS1"
    
    var currentAssignCircuitNo = 1
    
    var selectedRadioTag = 1
    
    let properties = GlobalClass.sharedInstance.propertiesJson()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        
        getDataFromObject()
        
//        dropDown.cellNib = UINib(nibName: "CustomDropDown", bundle: nil)
//       // let cell = DropdownCell() as? DropdownCell
//        
//        dropDown.customCellConfiguration = { (index: Int, item: String, cell: DropDownCell) -> Void in
//            guard let cell = cell as? CustomDropDown else { return }
//            print("index \(index)")
//            
//            let selectedIndex = self.dropDown.indexForSelectedRow
//            //print("selectedIndex",selectedIndex!)
//            if index == selectedIndex {
//                print("selected if")
//                cell.tickImg.isHidden = false
//            }else {
//                print("selected else")
//            }
//            
//            // Setup your custom UI components
//        }
        
        radioButtonArray = [radioSwitch1,radioSwitch2,radioSwitch3,radioSwitch4,radioSwitch5,radioSwitch6,radioSwitch7,radioSwitch8,radioSwitch9]
        
//        for i in 0 ..< radioButtonArray.count {
//            
//            
//            if radioButtonArray[i].isSelected == true {
//                print("IF COLOR RADIO")
//                radioButtonArray[i].iconColor = customUtil.hexStringToUIColor(hex: "F9356B")
//                radioButtonArray[i].indicatorColor = customUtil.hexStringToUIColor(hex: "F9356B")
//            }
//        }
//        
//        
//        print("ARRAY",radioButtonArray[0])
        
        radioSwitch1.otherButtons = [radioSwitch2,radioSwitch3,radioSwitch4,radioSwitch5,radioSwitch6,radioSwitch7,radioSwitch8,radioSwitch9]
    
        radioSwitch1.isSelected = true
        radioSwitch1.deselectOtherButtons()
        
        roomNameLabel.isUserInteractionEnabled = true
        endDeviceLabel.isUserInteractionEnabled = true
        
//        roomNameLabel.borderColor = customUtil.hexStringToUIColor(hex: "686868")
//        roomNameLabel.borderWidth = 0.5
        
        let roomTap = UITapGestureRecognizer(target: self, action: #selector(roomLabelTap(gesture:)))
        roomNameLabel.addGestureRecognizer(roomTap)
        
        let endDeviceTap = UITapGestureRecognizer(target: self, action: #selector(endDeviceTap(gesture:)))
        endDeviceLabel.addGestureRecognizer(endDeviceTap)
        
        circuitId = endDeviceLabel.text!
        


    }
    
    func receivedMessage(notification: NSNotification) {
        
        let name = notification.name.rawValue
        //let sender = topic.replacingOccurrences(of: "chat/room/animals/client/", with: "")
        
        
        if name == "mqttReceive" {
            
            let userInfo = notification.userInfo as! [String: AnyObject]
            let message = userInfo["message"] as! String
            let topic = userInfo["topic"] as! String
            print("SWITCH MQTT MESSAGE:\(message) TOPIC: \(topic)")
            
            print("SWITCH Notification name if mqttReceive")
            
            if let data = message.data(using: .utf8) {
                
                print("SWITCH MQTT MESSAGE:\(message) TOPIC: \(topic)")
                print("SWITCH Notification name if mqttReceive")
                
                let jsonData = JSON(data: data, options: .mutableContainers, error: nil)
                print("JsonObj", jsonData, "Topic", topic)
                
                let switchId = jsonData["switch_id"].stringValue
                let switchCircuitUid = jsonData["switch_circuit_uid"].stringValue
                let switchStatus = jsonData["switch_status"].stringValue
                let success = jsonData["success"].stringValue
                
                print("switchId \(switchId) switchCircuitUid \(switchCircuitUid) switchStatus \(switchStatus) success \(success)")
                
                if success == "true" {
                    if switchCircuitId == switchCircuitUid {
                        if switchStatus == "ON" {
                            toggleSwitch.isOn = true
                        }else  if switchStatus == "OFF" {
                            toggleSwitch.isOn = false
                        }else {
                            print("radioButton1 Live mqtt point status not on or off")
                        }
                    }
                }else {
                    print("Live mqtt sucess false")
                }
                
            }else {
                print("Data is nil")
            }
            
        }else {
            print("SWITCH Notification name else")
        }
        
    }

   
    func getDataFromObject() {
        
        jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
 
        let jsonRoomsCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"].count
        
        roomNameLabel.text = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["display_name"].stringValue
        
//        endDeviceLabel.text = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["light_switches"][currentswitchNo]["circuits"][0].stringValue
        endDeviceLabel.text = "Select Circuits"
        
        print("Rooms Count \(jsonRoomsCount)")
        
        for i in 0 ..< jsonRoomsCount {
            
            let roomsArrayValues = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][i]["display_name"].stringValue
            print("roomsArrayValues",roomsArrayValues)
            
            roomsNameArray.append(roomsArrayValues)
           
           // roomsNameArray = roomsArrayValues as! [String]
           // print("rooms NAME ARRAY",roomsNameArray)
        }
        print("ROOMS ARRAY NAME",roomsNameArray)
        
        parseSwitchCircuit()
    }
    
    func switchStatus() {
        print("Switch STATUS --> \(switchStatusData)")
        
        let dataCount = switchStatusData["data"].count
        print("dataCount \(dataCount)")
        
        
        let switchCircuitNo = selectedRadioTag - 1
        print("switch circuit no \(switchCircuitNo)")
        
        for i in 0 ..< dataCount {
            print("I \(i)")
            
            let switchCircuitUid = switchStatusData["data"][i]["switch_status"]["switch_circuit_uid"].stringValue
            print("switchCircuitUid \(switchCircuitUid)")
            
            if switchCircuitUid == "CS\(selectedRadioTag)" {
                let status = switchStatusData["data"][i]["switch_status"]["status"].stringValue
                print("status--> \(status)")
                
                if status == "ON" {
                    toggleSwitch.isOn = true
                    print("Status ON--'")
                }else if status == "OFF" {
                    toggleSwitch.isOn = false
                    print("Status OFF--'")
                }else {
                    print("NO status")
                }
            } else {
                print("Not the current circuit")
            }
        }
       
        
    }

    
    func parseSwitchCircuit() {
        let jsonSwitch = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["light_switches"][currentswitchNo]
        
        roomId = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["id"].stringValue
        switchId = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["light_switches"][currentswitchNo]["id"].stringValue
        
        print("RoomId \(roomId) SwitchId  \(switchId )")
        
        //print("Switch Count",switchCount)
        
        let switchCircuitCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["light_switches"][currentswitchNo]["circuits"].count
        print("switchCircuitCount",switchCircuitCount)
        
        for i in 0 ..< switchCircuitCount {
            let switchCircuitUid = jsonSwitch["circuits"][i].stringValue
            print("switch_circuit_uid",switchCircuitUid)
            
            circuitArray.append(switchCircuitUid)
        }
        
        
    }

    
    func roomLabelTap(gesture: UITapGestureRecognizer) {
        
        print("roomLabelTap")
        
        roomNameArrow.image = UIImage(named: "dropDownx48")
        
        roomNameLabel.dividerColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        roomNameLabel.dividerThickness = 2
        
        dropDown.topOffset = CGPoint(x: 0, y: (-roomNameLabel.bounds.height-5))
        
        dropDown.anchorView = roomNameLabel
        dropDown.direction = .top
        dropDown.textColor = customUtil.hexStringToUIColor(hex: "686868")
        dropDown.dataSource = roomsNameArray
        
    
        
        dropDown.selectionAction = {(index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.roomNameLabel.text = item
            
            self.roomNameArrow.image = UIImage(named: "dropDown_Up-48")
            
            self.roomNameLabel.dividerColor = self.customUtil.hexStringToUIColor(hex: "686868")
            self.roomNameLabel.dividerThickness = 0.5
        }
        
        dropDown.show()
        
        dropDown.cancelAction = { [unowned self] in
          	// You could for example deselect the selected item
            
            self.roomNameArrow.image = UIImage(named: "dropDown_Up-48")
            
            self.roomNameLabel.dividerColor = self.customUtil.hexStringToUIColor(hex: "686868")
            self.roomNameLabel.dividerThickness = 0.5
    
        }
        
        print("DropDOwn Height: ",dropDown.heightAnchor)
        //self.scrollView.setContentOffset(CGPoint(x: 0,y: dropDown.bottomOffset), animated: true)
    }
    
    func endDeviceTap(gesture: UITapGestureRecognizer) {
        
        areaId = jsonObj["designs"][0]["areas"][currentAreaIndex]["id"].stringValue
        
        customUtil.activityIndicatorStart(view: self.view)
        
        print("++= endDeviceTap \(areaId)  -- \(roomId) -- \(switchId)")
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "area_uid" : areaId,
            "room_uid" : roomId,
            "switch_uid": switchId
        ]
        
        print("circuit_uid  \(circuitId)")
        
        let urlPath = properties["Circuit_List"].stringValue
        
        httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: {  response -> Void in
            
            print("editCircuitBtnAction Sucess",response)
            self.customUtil.activityIndicatorStop(view: self.view)
            
            print("endDeviceTap")
            self.devicesArrow.image = UIImage(named: "dropDownx48")
            
            self.dropDown.topOffset = CGPoint(x: 0, y: (-self.roomNameLabel.bounds.height-5))
            
            self.endDeviceLabel.dividerColor = self.customUtil.hexStringToUIColor(hex: self.themeColor.dividerActiveColor)
            self.endDeviceLabel.dividerThickness = 2
            
            let circuitArr = response["circuit_dropdown"].arrayObject as! [String]
            
            let filterCircuitArr = circuitArr.filter { $0 != "null"}
            print("filtercircuitArr \(filterCircuitArr)")
            
            if filterCircuitArr.count == 0{
                self.customUtil.toast(view: self, title: "Circuit Dropdown", message: "No circuits available")
                self.endDeviceLabel.text = "No circuits available"
                
                self.devicesArrow.image = UIImage(named: "dropDown_Up-48")
                
                self.endDeviceLabel.dividerColor = self.customUtil.hexStringToUIColor(hex: "686868")
                self.endDeviceLabel.dividerThickness = 0.5
                
            }else {
                self.dropDown.anchorView = self.endDeviceLabel
                self.dropDown.direction = .top
                self.dropDown.textColor = self.customUtil.hexStringToUIColor(hex: "686868")
                self.dropDown.dataSource = filterCircuitArr
                self.dropDown.selectionAction = {(index: Int, item: String) in
                    print("Selected item: \(item) at index: \(index)")
                    self.endDeviceLabel.text = item
                    
                    self.circuitId = item
                    
                    self.devicesArrow.image = UIImage(named: "dropDown_Up-48")
                    
                    self.endDeviceLabel.dividerColor = self.customUtil.hexStringToUIColor(hex: "686868")
                    self.endDeviceLabel.dividerThickness = 0.5
                    
                    self.editCircuitBtn.alpha = 1
                }
                
                self.dropDown.show()
            }

            
            self.dropDown.cancelAction = { [unowned self] in
                // You could for example deselect the selected item
                
                self.devicesArrow.image = UIImage(named: "dropDown_Up-48")
                
                self.endDeviceLabel.dividerColor = self.customUtil.hexStringToUIColor(hex: "686868")
                self.endDeviceLabel.dividerThickness = 0.5
                
            }
            
            print("DropDOwn Height: ",self.dropDown.heightAnchor)
            
            
        }, failCompletionHandler: { response -> Void in
            
            print("editCircuitBtnAction FAILURE",response)
            self.customUtil.activityIndicatorStop(view: self.view)
            
        },  error: {  error -> Void in
            
            print("editCircuitBtnAction Error")
            
            self.customUtil.activityIndicatorStop(view: self.view)
            self.customUtil.toast(view: self, title: "Failure", message: error)
            
        })
 
        
        //self.scrollView.setContentOffset(CGPoint(x: 0,y: dropDown.bottomOffset), animated: true)

    }
    
    func switchCircuitConfigCheck() {
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "switch_uid": switchId
        ]
        
        print("switchId---> \(switchId)")
        
        let urlPath = properties["Switch_Circuit_Config_Check"].stringValue
        
        httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: {  response -> Void in
            
            print("switchCircuitConfigCheck Sucess",response)
            self.customUtil.activityIndicatorStop(view: self.view)
            
            let success = response["success"].boolValue
            
            if success == true {
                
                let switchCircuitsArr = response["switch_circuits"].arrayValue
                
                for switchCircuit in switchCircuitsArr {
                    
                    let switchCircuitUid = switchCircuit["switch_circuit_uid"].stringValue
                    
                    switch switchCircuitUid {
            
                    case "CS1":
                        print("CS1-->")
                        
                        let switchCircuitConfigStatus = switchCircuit["switch_circuit_config_status"].intValue
                        
                        if switchCircuitConfigStatus == 1 {
                            print("CS1 configured")
                            self.radioSwitch1.isUserInteractionEnabled = false
                            self.radioSwitch1.icon = UIImage(named: "radio_selected")!
                        }else {
                             print("CS1 not configured")
                        }
                        
                    case "CS2":
                        print("CS2-->")
                        
                        let switchCircuitConfigStatus = switchCircuit["switch_circuit_config_status"].intValue
                        
                        if switchCircuitConfigStatus == 1 {
                            print("CS2 configured")
                            self.radioSwitch2.isUserInteractionEnabled = false
                            self.radioSwitch2.icon = UIImage(named: "radio_selected")!
                        }else {
                            print("CS2 not configured")
                        }
                        
                    case "CS3":
                        print("CS3-->")
                        
                        let switchCircuitConfigStatus = switchCircuit["switch_circuit_config_status"].intValue
                        
                        if switchCircuitConfigStatus == 1 {
                            print("CS3 configured")
                            self.radioSwitch3.isUserInteractionEnabled = false
                            self.radioSwitch3.icon = UIImage(named: "radio_selected")!
                        }else {
                            print("CS3 not configured")
                        }
                        
                    case "CS4":
                        print("CS4-->")
                        
                        let switchCircuitConfigStatus = switchCircuit["switch_circuit_config_status"].intValue
                        
                        if switchCircuitConfigStatus == 1 {
                            print("CS4 configured")
                            self.radioSwitch4.isUserInteractionEnabled = false
                            self.radioSwitch4.icon = UIImage(named: "radio_selected")!
                        }else {
                            print("CS4 not configured")
                        }
                        
                    case "CS5":
                        print("CS5-->")
                        
                        let switchCircuitConfigStatus = switchCircuit["switch_circuit_config_status"].intValue
                        
                        if switchCircuitConfigStatus == 1 {
                            print("CS5 configured")
                            self.radioSwitch5.isUserInteractionEnabled = false
                            self.radioSwitch5.icon = UIImage(named: "radio_selected")!
                        }else {
                            print("CS5 not configured")
                        }
                        
                    case "CS6":
                        print("CS6-->")
                        
                        let switchCircuitConfigStatus = switchCircuit["switch_circuit_config_status"].intValue
                        
                        if switchCircuitConfigStatus == 1 {
                            print("CS6 configured")
                            self.radioSwitch6.isUserInteractionEnabled = false
                            self.radioSwitch6.icon = UIImage(named: "radio_selected")!
                        }else {
                            print("CS6 not configured")
                        }
                        
                    case "CS7":
                        print("CS7-->")
                        
                        let switchCircuitConfigStatus = switchCircuit["switch_circuit_config_status"].intValue
                        
                        if switchCircuitConfigStatus == 1 {
                            print("CS7 configured")
                            self.radioSwitch7.isUserInteractionEnabled = false
                            self.radioSwitch7.icon = UIImage(named: "radio_selected")!
                        }else {
                            print("CS7 not configured")
                        }
                        
                    case "CS8":
                        print("CS8-->")
                        
                        let switchCircuitConfigStatus = switchCircuit["switch_circuit_config_status"].intValue
                        
                        if switchCircuitConfigStatus == 1 {
                            print("CS8 configured")
                            self.radioSwitch8.isUserInteractionEnabled = false
                            self.radioSwitch8.icon = UIImage(named: "radio_selected")!
                        }else {
                            print("CS8 not configured")
                        }
                        
                    case "CS9":
                        print("CS9-->")
                        
                        let switchCircuitConfigStatus = switchCircuit["switch_circuit_config_status"].intValue
                        
                        if switchCircuitConfigStatus == 1 {
                            print("CS9 configured")
                            self.radioSwitch9.isUserInteractionEnabled = false
                            self.radioSwitch9.icon = UIImage(named: "radio_selected")!
                        }else {
                            print("CS9 not configured")
                        }
                        
                    default:
                        print("switch circuit id failed")

                    }
                }
                
            }
            
        }, failCompletionHandler: { response -> Void in
            
            print("switchCircuitConfigCheck FAILURE",response)
            self.customUtil.activityIndicatorStop(view: self.view)
            
        },  error: {  error -> Void in
            
            print("switchCircuitConfigCheck Error")
            
            self.customUtil.activityIndicatorStop(view: self.view)
            self.customUtil.toast(view: self, title: "Error", message: error)
            
        })

        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switchStatus()
        
//        switchCircuitConfigCheck()
        
        mqttClient.subscribeToTopic(topic: "switch_live_status")

        //Mqtt receive observer
        let name = NSNotification.Name(rawValue: "mqttReceive")
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMessage(notification:)), name: name, object: nil)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "mqttReceive"), object: nil)
        
        mqttClient.unSubToTopic(topic: "switch_live_status")
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)    
    }
 
    
    @IBAction func backBtnAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func editCircuitBtnAction(_ sender: Any) {
        
        if editCircuitBtn.alpha == 1 {
            customUtil.activityIndicatorStart(view: view)
            
            let headers: [String:String] =  [
                "installer_uid" : "77",
                "email_id" : "john@brightgreen.com"
            ]
            
            let parameters: [String:Any] = [
                "room_uid" : roomId,
                "circuits_uid": circuitId
            ]
            
            print("circuit_uid  \(circuitId)")
            
            let urlPath = properties["Edit_Circuit"].stringValue
            
            httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: {  response -> Void in
                
                print("editCircuitBtnAction Sucess",response)
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let  mainStory = UIStoryboard(name: "Home", bundle: nil)
                let destination = mainStory.instantiateViewController(withIdentifier: "EditCircuitsViewController") as! EditCircuitsViewController
                destination.currentRoomNo = self.currentRoomNo
                destination.currentswitchNo = self.currentswitchNo
                
                destination.currentCircuitId = response["circuits_uid"].stringValue
                let transition = CATransition()
                transition.duration = 0.5
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromTop;
                self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                self.navigationController?.pushViewController(destination, animated: false)
                
                
            }, failCompletionHandler: { response -> Void in
                
                print("editCircuitBtnAction FAILURE",response)
                self.customUtil.activityIndicatorStop(view: self.view)
                
            },  error: {  error -> Void in
                
                print("editCircuitBtnAction Error")
                
                self.customUtil.activityIndicatorStop(view: self.view)
                self.customUtil.toast(view: self, title: "Failure", message: error)
                
            })
        }else {
            print("Edit Btn Not enabled")
             self.customUtil.toast(view: self, title: "Circuits", message: "Select circuit from list")
        }
        
        
    }
    
    @IBAction func assignBtnAction(_ sender: Any) {
        
            
        if editCircuitBtn.alpha == 1 {
            
            editCircuitBtn.alpha = 0.4
            endDeviceLabel.text = "Select Circuits"
            
            print("roomId \(roomId) switchId \(switchId) switchCircuitId \(switchCircuitId)")
            
            print("Selected Tag",selectedRadioTag)
            
            self.customUtil.activityIndicatorStart(view: self.view)
        
            let headers: [String:String] =  [
                "installer_uid" : "77",
                "email_id" : "john@brightgreen.com"
            ]
            
            let parameters: [String:Any] = [
                "room_uid" : roomId,
                "switch_uid" : switchId,
                "switch_circuit_uid" : switchCircuitId,
                "circuit_uid": circuitId,
                "switch_ckt_config_sts" : 1
            ]
            
            
            let urlPath = properties["Swich_Circuit_Config"].stringValue
            
            httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: {  response -> Void in
                
                print("Sucess PLAN",response)
                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                
                if(success == true){
                    self.customUtil.toast(view: self, title: "Success", message: message)
                }else if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
                    //                self.toggleSwitch.isOn = false
                }else {
                    print("RESPONSE SUCCESS FAILED")
                }
                
                if self.currentAssignCircuitNo <= 3 {
                    
                    print("currentAssignCircuitNo",self.currentAssignCircuitNo)
                    
                    self.currentAssignCircuitNo = self.currentAssignCircuitNo + 1
                    
                    print("currentAssignCircuitNo AFTER INCREMENT",self.currentAssignCircuitNo)
                    
                    self.assignCircuitToSwitchLabel.text = "Assign Circuit \(self.currentAssignCircuitNo) to Switch"
                    //self.endDeviceLabel.text = "Circuit \(self.currentAssignCircuitNo)"
                    
                    
                    for i in 0 ..< self.radioButtonArray.count {
                        
                        
                        if self.radioButtonArray[i].isSelected == true {
                            
                            print("radio",self.radioButtonArray[i])
                            
                            
                            self.radioButtonArray[i].icon = UIImage(named: "radio_selected")!
                            self.radioButtonArray[i].isUserInteractionEnabled = false
                            
                            
                            self.selectedRadioTag = self.radioButtonArray[i].tag + 1
                            self.toggleSwitch.isOn = false
                            
                            if(self.selectedRadioTag <= 3){
                                self.switchCircuitId = "CS\(self.selectedRadioTag)"
                                
                            }
                            
                            
                            print("switchCircuitId",self.switchCircuitId)
                            
                            print("selectedRadioTag",self.selectedRadioTag)
                            
                            if self.selectedRadioTag <= 9 {
                                
                                self.radioButtonArray[self.selectedRadioTag-1].isSelected = true
                                print("Radio Tag",self.radioButtonArray[i].tag)
                                
                            }else {
                                print("SWITCH CIRCUIT COUNT EXCEEDS")
                                self.radioButtonArray[0].isSelected = true
                            }
                            
                            break
                            
                        }else {
                            print("RADIO NOT SELECTED")
                        }
                        
                    }
                    
                    
                }
                else {
                    print("3 physical circuits are done")
                    //self.nextBtn.title = "FINISH"
                    
                    //                //Delay perform Segue by 1.5 seconds
                    //                let timeToDissapear : DispatchTime = DispatchTime.now() + 1.5
                    //                let when = timeToDissapear
                    //                DispatchQueue.main.asyncAfter(deadline: when){
                    //                    let vc = self.navigationController?.viewControllers.filter({$0 is DeviceSetupViewController}).first
                    //                    print("vc",vc!)
                    //                    self.navigationController?.popToViewController(vc!, animated: true)
                    //                }
                    
                }
                
                self.switchStatus()
                
                
            }, failCompletionHandler: { response -> Void in
                
                print("FAILURE",response)
                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
                    //                self.toggleSwitch.isOn = false
                }else {
                    print("RESPONSE SUCCESS FAILED")
                }
                
            }, error: {  error -> Void in
                print("ON responseString is NIL")
                
                self.customUtil.activityIndicatorStop(view: self.view)
                self.customUtil.toast(view: self, title: "Failure", message: error)
                
            })

        }else {
            print("Edit Btn Not enabled")
            self.customUtil.toast(view: self, title: "Circuits", message: "Select any circuit from list to assign")
        }
       
    }

    @IBAction func switchCircuitToggleAction(_ sender: Any) {
        
        toggleSwitch.isUserInteractionEnabled = false
        customUtil.activityIndicatorStart(view: view)
     
        let ts = String(Date().timeIntervalSince1970)
        print("Time Stamp",ts)
        
        
        if toggleSwitch.isOn == true {
            print("SWITCH ON IF")
            
            let headers: [String:String] =  [
                "installer_uid" : "77",
                "email_id" : "john@brightgreen.com"
            ]
            
            let parameters: [String:Any] = [
                "room_uid" : roomId,
                "switch_uid" : switchId,
                "switch_circuit_uid" : switchCircuitId,
                "switch_status" : "ON",
                "time_stamp" : ts
            ]
            
            
            let urlPath = properties["Switch_Status"].stringValue
        
            httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: {  response -> Void in
            
                print("Sucess PLAN",response)
                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                
                if(success == true){
                    self.customUtil.toast(view: self, title: "Success", message: message)
                }else if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
                    self.toggleSwitch.isOn = false
                }else {
                    print("RESPONSE SUCCESS FAILED")
                }

                
            }, failCompletionHandler: { response -> Void in
            
                print("FAILURE PLAN",response)
                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                if(success == false){
                    self.customUtil.toast(view: self, title: "Failure", message: message)
                    self.toggleSwitch.isOn = false
                }else {
                    print("RESPONSE SUCCESS FAILED")
                }

            }, error: {  error -> Void in
                print("ON responseString is NIL")
                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                self.customUtil.toast(view: self, title: "Failure", message: error)

            })

        }else {
            print("SWITCH OFF ELSE")
            
            let ts = String(Date().timeIntervalSince1970)
            print("Time Stamp",ts)
            
            let headers: [String:String] =  [
                "installer_uid" : "77",
                "email_id" : "john@brightgreen.com"
            ]
            
            let parameters: [String:Any] = [
                "room_uid" : roomId,
                "switch_uid" : switchId,
                "switch_circuit_uid" : switchCircuitId,
                "switch_status" : "OFF",
                "time_stamp" : ts
            ]
            
           let urlPath = properties["Switch_Status"].stringValue
            
            httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
                
                print("Sucess RESPONSE",response)
                
                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                print("Response Message",message)
                print("RESPONSE SUCCESS",success)
                
                if(success == true){
                    self.customUtil.toast(view: self, title: "Success", message: message)
                }else if(success == false){
                   self.customUtil.toast(view: self, title: "Failure", message: message)
                    self.toggleSwitch.isOn = true
                }else {
                    print("RESPONSE SUCCESS FAILED")
                    
                }

            }, failCompletionHandler: { response -> Void in
            
                print("FAILURE RESPONSE",response)
                
                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                
                let message = response["msg"].stringValue
                let success = response["success"].boolValue
                
                if(success == false){
                     self.customUtil.toast(view: self, title: "Failure", message: message)
                    self.toggleSwitch.isOn = true
                }else {
                    print("RESPONSE FAILED")
                }

                
            }, error: { error -> Void in
                print("OFF responseString is NIL")
                self.toggleSwitch.isUserInteractionEnabled = true
                self.customUtil.activityIndicatorStop(view: self.view)
                self.customUtil.toast(view: self, title: "Error!", message: error)
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
            "switch_uid" : switchId,
            "switch_config_sts" : 1
        ]
        
        //Alert to configure switch
        let refreshAlert = UIAlertController(title: "Configure Switch", message: "Do you wish to finish configuring this switch?", preferredStyle: UIAlertControllerStyle.alert)
        
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle YES logic here")
            
            self.customUtil.activityIndicatorStart(view: self.view)
            
            let urlPath = self.properties["Switch_Config"].stringValue
            
            self.httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: {  response -> Void in
                
                self.customUtil.activityIndicatorStop(view: self.view)
                
                print("finishBtnAction Sucess",response)
                
                // TODO: Track the user action that is important for you.
                Answers.logContentView(withName: "KIKO Switch", contentType: "Success Switch Configuration", contentId: self.switchId, customAttributes: ["room_uid":self.roomId, "switch_uid":self.switchId, "res_message" : response.stringValue])
                
                
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
                Answers.logContentView(withName: "KIKO Switch", contentType: "Failure Switch Configuration", contentId: self.switchId, customAttributes: ["room_uid":self.roomId, "switch_uid":self.switchId, "res_message" : response.stringValue])
                
            },  error: {  error -> Void in
                
                print("finishBtnAction Error")
                
                self.customUtil.activityIndicatorStop(view: self.view)
                self.customUtil.toast(view: self, title: "Failure", message: error)
                
                // TODO: Track the user action that is important for you.
                Answers.logContentView(withName: "KIKO Switch", contentType: "Error Switch Configuration", contentId: self.switchId, customAttributes: ["room_uid":self.roomId, "switch_uid":self.switchId, "res_message" : error])
                
                
            })
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
            //refreshAlert.dismiss(animated: true, completion: nil)
        }))
   
        
         self.present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func radioButtonRow2Action(_ sender: Any) {
        
        customUtil.toast(view: self, title: "Disabled", message: "Switch circuit not enabled")
        
        
    }
    
}
