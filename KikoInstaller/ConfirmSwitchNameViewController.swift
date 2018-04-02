//
//  ConfirmSwitchNameViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/11/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON



class ConfirmSwitchNameViewController: UIViewController,UITextFieldDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var switchNameText: TextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    var httpsClient = HttpsClient()
    
    var jsonObj : JSON = JSON.null
    var roomJsonObj : JSON = JSON.null
    var statusData : JSON = JSON.null
    
    var switchArrNo = 0
    var switchTag = 0
    var roomNo = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        
        //getDataFromObject()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        switchNameText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        
        // Do this for each UITextField
        switchNameText.delegate = self
        switchNameText.textColor = customUtil.hexStringToUIColor(hex: "686868")
        switchNameText.tag = 0 //Increment accordingly
        
        //Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        view.addGestureRecognizer(tapGesture)

    }
    
    func textFieldShouldReturn(userText: TextField!) -> Bool {
        switchNameText.resignFirstResponder()
        return true
    }
    
    //Scroll to active Text Field
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 10
        self.scrollView.contentInset = contentInset
    }
    
    //Scroll to active Text Field
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    //Protocol methods for gesture recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    //Tap gesture selector
    func tap(gesture: UITapGestureRecognizer){
        switchNameText.resignFirstResponder()
    }

    //Dismiss keyboard when return button is tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return false
    }
    
    func getDataFromObject() {
        
        jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        roomJsonObj = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]
        
        print("jjjj \(jsonObj)")
        
        print("ROOM NO \(roomNo) \(switchArrNo)")
        print("--Swit",jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["light_switches"][switchArrNo])
        
//        let switchX = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomNo]["router"][0]["x"]
//        let switchY = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomNo]["router"][0]["y"]
//        print("RESULT switch X : \(switchX)  Y:\(switchY)")
        
        let jsonSwitchName = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["light_switches"][switchArrNo]["name"].stringValue
        
       // let jsonRouterName = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomNo]["router"][0]["name"].stringValue
        
        print("Switch NAME \(jsonSwitchName) ")
        
        switchNameText.text = jsonSwitchName
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getDataFromObject()
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
   
    
    @IBAction func nextBtnAction(_ sender: Any) {
        
        customUtil.activityIndicatorStart(view: self.view)
        
        let roomUid = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["id"].stringValue
        let switchUid = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["light_switches"][switchArrNo]["id"].stringValue
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "room_uid" : roomUid,
            "switch_uid" : switchUid
        ]
        
        print("ROOM No \(roomUid) Switch No \(switchUid)")
        
       
         let properties = GlobalClass.sharedInstance.propertiesJson()
         let urlPath = properties["Update_Switch"].stringValue
        
        httpsClient.postRequest(urlPath: urlPath, headers: headers , parameters: parameters, sucCompletionHandler: { response -> Void in
            print("sucCompletionHandler RESPONSE -->",response)
            
            self.customUtil.activityIndicatorStop(view: self.view)
            
            self.statusData = response
            
            print("Sucess PLAN ")
            let compareJson = self.jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][self.roomNo]["light_switches"][self.switchArrNo]["name"].stringValue == self.switchNameText.text!
            print("JSON COMPARE EQUAL \(compareJson)")
            
            let  mainStory = UIStoryboard(name: "Home", bundle: nil)
            let destination = mainStory.instantiateViewController(withIdentifier: "AssignCircuitToSwitchViewController") as! AssignCircuitToSwitchViewController
            self.navigationController!.pushViewController(destination, animated: true)
            
            print("TEST STATUS -->",self.statusData)
            
            destination.currentRoomNo = self.roomNo
            destination.currentswitchNo = self.switchArrNo
            destination.switchStatusData = self.statusData
            
            
            if(compareJson == true) {
                print("JSON COMPARISON VALUES SAME")
            }else{
                
                self.jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][self.roomNo]["light_switches"][self.switchArrNo]["name"].stringValue = self.switchNameText.text!
                
                GlobalClass.sharedInstance.setPlanJsonObject(object: self.jsonObj)
                print("JSON VALUE SET TO GLOBAL Class")
                
                do{
                    print("CHANGED JSON \(self.jsonObj)")
                    let data = try self.jsonObj.rawData()
                    print("NEWW---> \(data)")
                    try self.fileUtil.overwriteFileToTempFolder(dataForJson: data as AnyObject, path: "/TempPlan/\(currentSelectedPlanName).json")
                    print("OVERWRITE FILE TEMP WRITE SUCCESS")
                }catch{
                    print("OVERWRITE Error writing data: \(error)")
                }
            }
            
        }, failCompletionHandler: { response -> Void in
            
            print("failCompletionHandler RESPONSE -->",response)
            self.customUtil.activityIndicatorStop(view: self.view)
            self.customUtil.toast(view: self, title: "Failure", message: " ")
            

        }, error: {  error -> Void in
            
            print("error Response",error)
            self.customUtil.activityIndicatorStop(view: self.view)
            self.customUtil.toast(view: self, title: "Error!", message:error)
        })
            
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        
         _ = self.navigationController?.popViewController(animated: true)
        
    }
    

}
