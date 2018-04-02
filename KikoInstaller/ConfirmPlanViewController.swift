//
//  ConfirmPlanViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/2/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON

 
class ConfirmPlanViewController: UIViewController,UIScrollViewDelegate,UIGestureRecognizerDelegate {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mqttSwitch: UISwitch!

    
    var planImage = UIImageView()
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()

    var mqttMessage : String = ""
    
    var planName = ""
    
    var jsonObj : JSON = JSON.null

    let fileMngr = FileManager.default
    
//    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
//    let loadingView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPlanFromGlobal()
        
        //  shareBtn.tintColor = themeColor.BarButtonColor
        

        scrollView.delegate = self
      
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight,scaleWidth)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 4
        scrollView.zoomScale = minScale
        
//        mqttClient.connectMqtt()
//        print("mqttMessage viewDidLoad",mqttMessage)
//       
//        let name = NSNotification.Name(rawValue: "MQTTMessageNotification")
//        NotificationCenter.default.addObserver(self, selector: #selector(ConfirmPlanViewController.receivedMessage(notification:)), name: name, object: nil)
        
    }
    
    func receivedMessage(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let content = userInfo["message"] as! String
        let topic = userInfo["topic"] as! String
        //let sender = topic.replacingOccurrences(of: "chat/room/animals/client/", with: "")
        
        print("MQTT MESSAGE:\(content) TOPIC: \(topic)")
        if content == "ON"{
            mqttSwitch.isOn = true
        }else if content == "OFF"{
            mqttSwitch.isOn = false
        }else {
            print("Message not ON or OFF")
        }
        
//        let chatMessage = ChatMessage(sender: sender, content: content)
//        messages.append(chatMessage)
    }
    
    
    func getPlanFromGlobal() {
        
        //Get Plan Object to Global Class
        jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        
        let base64 = jsonObj["designs"][0]["areas"][currentAreaIndex]["image"].stringValue
        
        let decodedData = NSData(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0))
        let decodedImage = UIImage(data: decodedData! as Data)
        
        let pngImage = UIImagePNGRepresentation(decodedImage!)
        
        let image = UIImage(data: pngImage!)
        
        let width = image?.width
        let height = image?.height
        print("ImAGE HEIGHT \(String(describing: height))   WIDTH  \(String(describing: width))")
        
        
        planImage.frame = CGRect(x: 0, y: 0 , width: width!, height: height!)
        planImage.isUserInteractionEnabled = true
        planImage.image = image
        
        //scrollView.backgroundColor = UIColor.blue
        scrollView.contentSize = self.planImage.frame.size
        scrollView.addSubview(planImage)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panButton(pan:)))
        pan.delegate = self
        //planImage.addGestureRecognizer(pan)
        scrollView.panGestureRecognizer.require(toFail: pan)
        
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(gestureRecognizer:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        planImage.addGestureRecognizer(doubleTapRecognizer)
        
        
        let roomsCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"].count
        print("ROOM COUNT \(roomsCount)")
        
        
        for i in 0 ..< roomsCount {
            let rooms = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][i]
            //                    let roomX = CGFloat(rooms["x"].floatValue)
            //                    let roomY = CGFloat(rooms["y"].floatValue)
            //                    let roomWidth = CGFloat(rooms["width"].floatValue)
            //                    let roomHeight = CGFloat(rooms["height"].floatValue)
            
            
            let segmentsCount = rooms["segments"].count
            
            for i in 0 ..< segmentsCount {
                
                if i == segmentsCount-1 {
                    
                    //
                    //print("IFF---> LINE")
                    //                            let segmentsX = CGFloat(rooms["segments"][i][0].floatValue)
                    //                            let segmentsY = CGFloat(rooms["segments"][i][1].floatValue)
                    //
                    //                            let nextSegmentX = CGFloat(rooms["segments"][0][0].floatValue)
                    //                            let nextSegmentY = CGFloat(rooms["segments"][0][1].floatValue)
                    
                    //                            autoreleasepool { ()  in
                    //
                    //                                drawLines(moveX: segmentsX, moveY: segmentsY, addlinetoX: nextSegmentX, addlinetoY: nextSegmentY)
                    //
                    //                            }
                }else {
                    
                    //
                    //print("ELSE----> LINE")
                    //                            let segmentsX = CGFloat(rooms["segments"][i][0].floatValue)
                    //                            let segmentsY = CGFloat(rooms["segments"][i][1].floatValue)
                    //
                    //                            let nextSegmentX = CGFloat(rooms["segments"][i+1][0].floatValue)
                    //                            let nextSegmentY =  CGFloat(rooms["segments"][i+1][1].floatValue)
                    
                    //                            autoreleasepool { ()  in
                    //
                    //                                drawLines(moveX: segmentsX, moveY: segmentsY, addlinetoX: nextSegmentX, addlinetoY: nextSegmentY)
                    //
                    //                            }
                }
            }
        }
        
    }
    
    
    func listFilesFromDocumentsFolder()->[String]?{
        //full path to documents directory
        let docs=fileMngr.urls(for: .documentDirectory,in: .userDomainMask)[0].path;
        //list all contents of directory and return as [String] OR nil if failed
        return try? fileMngr.contentsOfDirectory(atPath:docs+"/OriginalPlan");
    }
    
    //Double Tap selector
    func onDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
        let scale = min(scrollView.zoomScale * 2, scrollView.maximumZoomScale)
        
        if scale != scrollView.zoomScale {
            let point = gestureRecognizer.location(in: planImage)
            
            let scrollSize = scrollView.frame.size
            let size = CGSize(width: scrollSize.width / scale,
                              height: scrollSize.height / scale)
            let origin = CGPoint(x: point.x - size.width / 2,
                                 y: point.y - size.height / 2)
            scrollView.zoom(to:CGRect(origin: origin, size: size), animated: true)
            print("DOUBLE TAP \(CGRect(origin: origin, size: size))")
        }
    }
    
    
    //Pan Gesture Selector
    func panButton(pan:UIPanGestureRecognizer) {
        
        print("LOC -----> \((pan.location(in: planImage)))   FRAME: \(planImage.frame.contains(pan.location(in: planImage)))")
        if planImage.frame.contains(pan.location(in: planImage)) { //Check bounds for panning
            
            let point = pan.location(in: planImage) // get pan location
            let draggedView = pan.view
            
           // if (11.7821 < point.x) && (point.x < 118.5) && (293.9320 < point.y) && (point.y < 400.6) && (draggedView?.tag == 500) {
                //print("PAN ENDED LOCATION : \(point) PLAN IMAGE SIZE \(planImage.frame.size)")
                
                draggedView?.center = point // set View to where finger is
                print("draggedView=== \(String(describing: draggedView?.tag))  POINT ----------> \(point)  \(planImage.height)")
            //}else {
                
            //}
            
        }else{
            print("WHHHHYYYY")
        }
        
    }

    
    // Scroll View Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return planImage
    }


    
    override func viewWillAppear(_ animated: Bool) {
        customUtil.navTitle(text: currentSelectedPlanName, view: self)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        customUtil.removeNavTitle(view: self)
        
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
         _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func publishButton(_ sender: Any) {
        //mqttClient.publishToTopic(topic: "/Balaji", payload: "Hiyaaaaaa")
    }
  

    @IBAction func subscribeButton(_ sender: Any) {
       //mqttClient.subscribeToTopic(topic: "/Goutham")
         print("mqttMessage subscribeButton",mqttMessage)
    }
     
    @IBAction func switchAction(_ sender: Any) {
    }
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        
        let  mainStory = UIStoryboard(name: "Home", bundle: nil)
        let destination = mainStory.instantiateViewController(withIdentifier: "ConnectToRouterViewController") as! ConnectToRouterViewController
        self.navigationController!.pushViewController(destination, animated: true)

//        destination.planJsonObj = jsonObj

    }
}
