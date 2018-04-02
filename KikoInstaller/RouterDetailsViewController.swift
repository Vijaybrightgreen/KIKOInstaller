//
//  RouterDetailsViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/9/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit

class RouterDetailsViewController: UIViewController {

    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var routerName: UILabel!
    
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    
    var roomNo = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromObject()
        
        // Do any additional setup after loading the view.
    }
    
    func getDataFromObject() {
        let jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        
        print("ROOM NO \(roomNo)")
        
        let routerX = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["router"][0]["x"]
        let routerY = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["router"][0]["y"]
         print("RESULT ROUTER X : \(routerX)  Y:\(routerY)")
        
        let jsonRoomName = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["display_name"].stringValue
        let jsonRouterName = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomNo]["router"][0]["name"].stringValue
        
        print("ROOM NAME \(jsonRoomName) ROUTER NAME \(jsonRouterName)")
        
        roomName.text = jsonRoomName
        routerName.text = jsonRouterName
       
    }

    override func viewWillAppear(_ animated: Bool) {
        
        //customUtil.navTitle(text: "Kiko Router", view: self)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        //customUtil.removeNavTitle(view: self)
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }

    @IBAction func confirmBtnAction(_ sender: Any) {
        
         self.performSegue(withIdentifier: "timeToAddDeviceSegue", sender: nil)
        
    }
}
