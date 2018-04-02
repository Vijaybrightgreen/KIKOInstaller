//
//  ConfirmPointNameViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/18/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON


class ConfirmPointNameViewController: UIViewController,UITextFieldDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pointNameText: TextField!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    var httpsClient = HttpsClient()
    
    var jsonObj : JSON = JSON.null
    var roomJsonObj : JSON = JSON.null
    var statusData : JSON = JSON.null
    
    var pointArrNo = 0
    var roomNo = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.delegate = self
        self.pointNameText.delegate = self
        
        getDataFromObject()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        pointNameText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        
        // Do this for each UITextField
        pointNameText.delegate = self
        pointNameText.textColor = customUtil.hexStringToUIColor(hex: "686868")
        pointNameText.tag = 0 //Increment accordingly
        
        //Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        view.addGestureRecognizer(tapGesture)
        
        
    }
    
    func getDataFromObject() {
        
        jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        roomJsonObj = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]
        
        print("ROOM NO \(roomNo)")
        
        
        let jsonPointName = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["point"][pointArrNo]["name"].stringValue
        
        // let jsonRouterName = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomNo]["router"][0]["name"].stringValue
        
        print("Point NAME \(jsonPointName) ")
        
        pointNameText.text = jsonPointName
        
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
        pointNameText.resignFirstResponder()
    }
    
    //Dismiss keyboard when return button is tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldReturn(userText: TextField!) -> Bool {
        pointNameText.resignFirstResponder()
        return true
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
        
        customUtil.activityIndicatorStart(view: self.view)
        
        let roomUid = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["id"].stringValue
        let pointUid = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["point"][pointArrNo]["id"].stringValue
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "room_uid" : roomUid,
            "point_uid" : pointUid
        ]
        
        print("ROOM No \(roomUid) Point No \(pointUid)")

        let properties = GlobalClass.sharedInstance.propertiesJson()
        let urlPath = properties["Update_Point"].stringValue

        
        httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
            
            self.customUtil.activityIndicatorStop(view: self.view)
            
             self.statusData = response
            
            print("Sucess PLAN ")
            
            let compareJson = self.jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][self.roomNo]["point"][self.pointArrNo]["name"].stringValue == self.pointNameText.text!
            print("JSON COMPARE EQUAL \(compareJson)")
            
            let  mainStory = UIStoryboard(name: "Home", bundle: nil)
            let destination = mainStory.instantiateViewController(withIdentifier: "AssignCircuitToPointViewController") as! AssignCircuitToPointViewController
            self.navigationController!.pushViewController(destination, animated: false)
            
            destination.currentRoomNo = self.roomNo
            destination.currentPointNo = self.pointArrNo
            destination.pointStatusData = self.statusData
            print("status json \(self.statusData)")
            
            if(compareJson == true){
                print("JSON COMPARISON VALUES SAME")
            }else{
                
                self.jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][self.roomNo]["point"][self.pointArrNo]["name"].stringValue = self.pointNameText.text!
                
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
            print("FAILURE PLAN")
            self.customUtil.activityIndicatorStop(view: self.view)
            self.customUtil.toast(view: self, title: "Failure", message: " ")
        
        }, error: { error -> Void in

            print("ResponseString is NIL")
            self.customUtil.activityIndicatorStop(view: self.view)
            self.customUtil.toast(view: self, title: "Failure", message: error)
        })
    
    }
    
    
    @IBAction func backBtnAction(_ sender: Any) {
         _ = self.navigationController?.popViewController(animated: true)
    }
}
