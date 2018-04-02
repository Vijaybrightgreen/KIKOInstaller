//
//  DeviceSetupViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/9/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material

var mqttClient = MqttClient()

class DeviceSetupViewController: UIViewController,UIScrollViewDelegate,UIGestureRecognizerDelegate,UICollisionBehaviorDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addDeviceBtn: FABButton!
    @IBOutlet weak var confirmBtn: FABButton!
    @IBOutlet weak var roomExitBtn: FABButton!
    @IBOutlet weak var completePlanBtn: FABButton!
    
    @IBOutlet weak var actionLabelTop: UILabel!
    @IBOutlet weak var actionLabelBottom: UILabel!
    
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    var httpsClient = HttpsClient()
    
    var animator: UIDynamicAnimator?
    var collision: UICollisionBehavior?
    var snapBehaviour:UISnapBehavior!
    var attachment: UIAttachmentBehavior!
    
    var totalViewsArr = [UIView]()
    
    var planImage = UIImageView()
    
    var path = UIBezierPath()
    var configuredPath = UIBezierPath()
    var selectedRoomPath = UIBezierPath()
    
    var layer = CAShapeLayer()
    var configuredLayer = CAShapeLayer()
    var selectedRoomLayer = CAShapeLayer()
    
    var switchView = UIImageView()
    var pointView = UIImageView()
    
    var selectedStickyWall:String = ""
    
    var jsonObj : JSON = JSON.null
    var selectedRoomJsonObj : JSON = JSON.null  // ***IMPORTANT
    var roomConfigResponse : JSON = JSON.null
    
   
    var selectedRoomIndex = 0   //Selected Room Array Index // ***IMPORTANT
    var routerRoomId = currentRouterRoomId   //Router Room ID //  ***IMPORTANT
    
    var tappedRoomIndex = 0     // SelectedRoomIndex by tap from roomIndexArr
    
    var globalRoomX:CGFloat = 0 // ***IMPORTANT
    var globalRoomY:CGFloat = 0 // ***IMPORTANT
    var globalRoomWidth:CGFloat = 0 // ***IMPORTANT
    var globalRoomHeight:CGFloat = 0 // ***IMPORTANT
    
    var selectedRoomYMin : CGFloat = 0 // ***IMPORTANT
    var selectedRoomYMax : CGFloat = 0 // ***IMPORTANT
    var selectedRoomXMin : CGFloat = 0 // ***IMPORTANT
    var selectedRoomXMax : CGFloat = 0 // ***IMPORTANT
    
    var routerRotateAngle = 0
    
    var viewTag = 500
    var tapTemp = 0
    
    var callRouterRoom = 1
    
    var roomAlreadySelected = 0
    
    var zoomMinScale:CGFloat = 0
    
    let properties = GlobalClass.sharedInstance.propertiesJson()
    
    override func viewDidLoad() {
        print("DeviceSetupViewController viewDidLoad")
        super.viewDidLoad()

        getPlanImage()
        drawWallsOnHomePlan()
        
        scrollView.delegate = self
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        zoomMinScale = min(scaleHeight,scaleWidth)
        
        print("DEVICE SETUP VIEW \(scrollViewFrame)  \(scaleWidth)  \(scaleHeight)  \(zoomMinScale)")
        
        scrollView.minimumZoomScale = zoomMinScale
        scrollView.maximumZoomScale = 4
        scrollView.zoomScale = zoomMinScale

        let roomTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToSelectRoom(tap:)))
        planImage.addGestureRecognizer(roomTapRecognizer)
        
        // Create the Dynamic Animator
        animator = UIDynamicAnimator(referenceView: self.planImage)
        
        //Mqtt didConnect observer
        let name = NSNotification.Name(rawValue: "mqttDidConnect")
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMessage(notification:)), name: name, object: nil)
        
        //Mqtt didDisconnect observer
        let disconnectName = NSNotification.Name(rawValue: "mqttDidDisconnect")
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMessage(notification:)), name: disconnectName, object: nil)
        
    
    }
    
    func receivedMessage(notification: NSNotification) {
//        let userInfo = notification.userInfo as! [String: AnyObject]
//        print("userInfo \(userInfo)")
//        let content = userInfo["message"] as! String
//        let topic = userInfo["topic"] as! String
        //let sender = topic.replacingOccurrences(of: "chat/room/animals/client/", with: "")
        
//        print("MQTT MESSAGE:\(content) TOPIC: \(topic)")
        
//        if content == "ON"{
//            //mqttSwitch.isOn = true
//        }else if content == "OFF"{
//            //mqttSwitch.isOn = false
//        }else {
//            print("Message not ON or OFF")
//        }
        
        let name = notification.name.rawValue
        
        if name == "mqttDidDisconnect" {
            mqttClient.connectMqtt()
        }
        

    }
    
    
    //Request server if room is configured or not
    func requestRoomConfigured(roomId:String) {
        
        self.customUtil.activityIndicatorStart(view: self.view)
        
        //ZoomOut
        self.scrollView.zoomScale = self.zoomMinScale
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "room_uid" : roomId
        ]
        
        let urlPath = properties["Room_Config"].stringValue
        
        httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
            
            print("Sucess RESPONSE",response)
            self.customUtil.activityIndicatorStop(view: self.view)
            
            self.roomConfigResponse = response
            
            let responseRoomConfigSts = response["room_config_sts"].boolValue
            let responseRoomId = response["room_uid"].stringValue
            let rooms = self.jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"]
            var selectedRoomName = rooms[self.tappedRoomIndex]["display_name"].stringValue
            
            print("(\(responseRoomId) == \(self.routerRoomId))")
            
            
            
            //Check if roomId is Router roomID
            if responseRoomId == self.routerRoomId {
                
                print("Router Room Config Check")
                
                if responseRoomConfigSts == true {
                    
                    print("Router Room Configured")
                    self.drawConfiguredRoomWalls()
                    self.roomAlreadySelected = 0
                    
                }else if responseRoomConfigSts == false {
                    
                    
                    print("Router Room not Configured")
                    self.roomAlreadySelected = 1
                    self.zoomToRouterRoom()
                    
                }else {
                    
                    print("if room_config_sts is null")
                    
                }
                
            }else {
                print("Other Rooms Config Check")
                
                self.drawConfiguredRoomWalls()
                
                if responseRoomConfigSts == true {
                    
                    
                    selectedRoomName = rooms[self.selectedRoomIndex]["display_name"].stringValue
                    self.customUtil.toast(view: self, title: "Already Configured", message: "You have already configured \(selectedRoomName)")
                    self.roomAlreadySelected = 0
                    print("Other Room Configured")
                    
                }else if responseRoomConfigSts == false {
                    
                    self.drawSelectedRoomWalls()
                    
                    selectedRoomName = rooms[self.selectedRoomIndex]["display_name"].stringValue
                    
                    
                    self.scrollView.zoom(to: CGRect(x: self.globalRoomX, y: self.globalRoomY, width: self.globalRoomWidth, height: self.globalRoomHeight), animated: true)
                    self.customUtil.toast(view: self, title: "Room Selected", message: "You have Selected \(selectedRoomName)")
                    print("Other Room not Configured")
                    
                    
                    self.switchInstallation(rooms: rooms[self.selectedRoomIndex])
                    self.pointInstallation(rooms: rooms[self.selectedRoomIndex])
                    
                }else {
                    
                    print("else room_config_sts is null")
                    
                }
                
                print("roomAlreadySelected++++ \(self.roomAlreadySelected)")
                
                //Show or hide roomExit button
                if self.roomAlreadySelected == 1 {
                    print("Show Room Exit Button")
                    self.roomExitBtn.isHidden = false
                }else {
                    print("Hide Room Exit Button")
                }
            }
            
//            
//            self.drawConfiguredRoomWalls()
            
            //            if roomConfigSts == true {
            //               print("Router Room Configured")
            //            }else if roomConfigSts == false {
            //                print("Router Room not Configured")
            //                self.zoomToRouterRoom()
            //            }else {
            //                print("room_config_sts is null")
            //            }
            
        }, failCompletionHandler: { response -> Void in
            
            print("FAILURE RESPONSE",response)
            self.customUtil.activityIndicatorStop(view: self.view)
            
            self.customUtil.toast(view: self, title: "Failed!", message: "Check the server status")
            self.roomAlreadySelected = 0
            
        }, error: { error -> Void in
            print("ERROR RESPONSE",error)
            self.customUtil.activityIndicatorStop(view: self.view)
            
            self.customUtil.toast(view: self, title: "Error!", message: error)
            
            self.roomAlreadySelected = 0
        })
    }
    
    func getPlanImage() {
        
        jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        
        let base64 = jsonObj["designs"][0]["areas"][currentAreaIndex]["image"].stringValue
        
        let decodedData = NSData(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0))
        let decodedImage = UIImage(data: decodedData! as Data)
        
        let pngImage = UIImagePNGRepresentation(decodedImage!)
        
        let image = UIImage(data: pngImage!)
        
        let imageAlpha = image?.image(alpha: 0.7)
        
        let width = imageAlpha?.width
        let height = imageAlpha?.height
        print("IMG HEIGHT \(String(describing: height))   WIDTH  \(String(describing: width))")
        
        planImage.frame = CGRect(x: 0, y: 0 , width: width!, height: height!)
        planImage.backgroundColor = UIColor.clear.withAlphaComponent(0)
        planImage.isUserInteractionEnabled = true
        planImage.image = imageAlpha
        
        scrollView.contentSize = self.planImage.frame.size
        scrollView.addSubview(planImage)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panButton(pan:)))
        pan.delegate = self
        //planImage.addGestureRecognizer(pan)
        scrollView.panGestureRecognizer.require(toFail: pan)
        
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(gestureRecognizer:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        planImage.addGestureRecognizer(doubleTapRecognizer)
     
    }
    
    
    
    func drawWallsOnHomePlan() {
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
          
                    let segmentsX = CGFloat(rooms["segments"][i][0].floatValue)
                    let segmentsY = CGFloat(rooms["segments"][i][1].floatValue)
                    
                    let nextSegmentX = CGFloat(rooms["segments"][0][0].floatValue)
                    let nextSegmentY = CGFloat(rooms["segments"][0][1].floatValue)
                    
                    autoreleasepool { ()  in
                        
                        drawLines(moveX: segmentsX, moveY: segmentsY, addlinetoX: nextSegmentX, addlinetoY: nextSegmentY)
                        
                    }
                }else {

                    let segmentsX = CGFloat(rooms["segments"][i][0].floatValue)
                    let segmentsY = CGFloat(rooms["segments"][i][1].floatValue)
                    
                    let nextSegmentX = CGFloat(rooms["segments"][i+1][0].floatValue)
                    let nextSegmentY =  CGFloat(rooms["segments"][i+1][1].floatValue)
                    
                    autoreleasepool { ()  in
                        
                        drawLines(moveX: segmentsX, moveY: segmentsY, addlinetoX: nextSegmentX, addlinetoY: nextSegmentY)
                        
                    }
                    
                }
            }
          
           //zoomToRouterRoom()
        }
    }
    
    func drawConfiguredRoomWalls() {
        
        print("drawConfiguredRoomWalls")
        let roomsCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"].count
        print("drawConfiguredRoomWalls ROOM COUNT \(roomsCount)")
        
        let configuredRoomsArr = roomConfigResponse["conf_rooms_id"].arrayValue
        print("%configuredRoom \(configuredRoomsArr.count)")
        let resConfiguredRoomsArrCount = roomConfigResponse["conf_rooms_id"].count
        
        let roomsArr = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"].arrayValue
        let roomsArrCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"].count
        
        var roomsIndArr = [Int]()
        
        let roomArrFilter = roomsArr.filter { dict in
            let id = dict["id"].intValue
            roomsIndArr.append(id)
           // let index = array.indexOf(dict)
            print("%%% \(id)")
            return true
        }
        
        //print("&&& \(roomArrFilter)  roomsIndArr \(roomsIndArr)")
        
        // Show/Hide completePlanBtn Button
        if resConfiguredRoomsArrCount == roomsArrCount {
             print("All Rooms Configured")
            completePlanBtn.isHidden = false
            
        }else {
            print("All Rooms NOT Configured")
            completePlanBtn.isHidden = true
        }
        
        for configuredRoomId in configuredRoomsArr {
            
            print("configuredRoomId \(configuredRoomId)")
            let intVal = configuredRoomId.intValue
            
            let configuredIndexNum = Int(roomsIndArr.index(of: intVal)!)
            
            print("indexNum \(configuredIndexNum)")
           
            let rooms = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][configuredIndexNum]

            let segmentsCount = rooms["segments"].count
            let segments = rooms["segments"]
            
            autoreleasepool { ()  in
            drawConfiguredLines(segments: segments)
            }
//            for i in 0 ..< segmentsCount {
//                
//                if i == segmentsCount-1 {
//                    
//                    let segmentsX = CGFloat(rooms["segments"][i][0].floatValue)
//                    let segmentsY = CGFloat(rooms["segments"][i][1].floatValue)
//                    
//                    let nextSegmentX = CGFloat(rooms["segments"][0][0].floatValue)
//                    let nextSegmentY = CGFloat(rooms["segments"][0][1].floatValue)
//                    
//                    autoreleasepool { ()  in
//                        
//                        drawConfiguredLines(moveX: segmentsX, moveY: segmentsY, addlinetoX: nextSegmentX, addlinetoY: nextSegmentY, segments: segments)
//                        
//                    }
//                }else {
//                    
//                    let segmentsX = CGFloat(rooms["segments"][i][0].floatValue)
//                    let segmentsY = CGFloat(rooms["segments"][i][1].floatValue)
//                    
//                    let nextSegmentX = CGFloat(rooms["segments"][i+1][0].floatValue)
//                    let nextSegmentY =  CGFloat(rooms["segments"][i+1][1].floatValue)
//                    
//                    autoreleasepool { ()  in
//                        
//                        drawConfiguredLines(moveX: segmentsX, moveY: segmentsY, addlinetoX: nextSegmentX, addlinetoY: nextSegmentY, segments: segments)
//                        
//                    }
//                    
//                }
//            }
            
        }
  
    }
    
    func drawSelectedRoomWalls() {
        
        print("+++++++++++++drawSelectedRoomWalls(")
        
        let roomsCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"].count
        print("ROOM COUNT drawSelectedRoomWalls \(roomsCount)")
        
        
        
        let rooms = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex]
        print("drawSelectedRoomWalls rrom index \(selectedRoomIndex)")
        //let segmentsCount = rooms["segments"].count
        let segment = rooms["segments"]
        
        autoreleasepool { ()  in
        drawSelectedRoomLines(segments: segment)
        }
    }
    
    func zoomToRouterRoom() {
  
        let roomsCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"].count
        print("ROOM COUNT \(roomsCount)")
        
        
        for i in 0 ..< roomsCount {
            let rooms = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][i]
            
            let router = rooms["router"].exists()
            print("ROU EXISTS \(router)")
            
            if router == true {
                print("ROOM NO \(i)")
                selectedRoomIndex = i
                
                print("roomI---->",selectedRoomIndex)
                
                selectedRoomJsonObj = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][i]
                routerRoomId = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][i]["id"].stringValue
                
                print("ROOM VALUE \(selectedRoomJsonObj)")
                
                let roomName = rooms["display_name"].stringValue
                print("ROOM NAME  \(roomName)")
                
                globalRoomX = CGFloat(rooms["x"].floatValue)
                globalRoomY = CGFloat(rooms["y"].floatValue)
                globalRoomWidth = CGFloat(rooms["width"].floatValue)
                globalRoomHeight = CGFloat(rooms["height"].floatValue)
                
                print("ZOOM VALUE \(globalRoomX)  \(globalRoomY)  \(globalRoomWidth)  \(globalRoomHeight)")
                
                self.drawSelectedRoomWalls()
                scrollView.zoom(to: CGRect(x: globalRoomX, y: globalRoomY, width: globalRoomWidth, height: globalRoomHeight), animated: true)
                //scrollView.zoom(to: CGRect(x: roomX, y: roomY, width: planImage.width/2, height: planImage.height/2), animated: true)
                
                
                //ROUTER
                let routerCount = rooms["router"].count
                print("ROUTER COUNT \(routerCount)")
                
                for i in 0 ..< routerCount {
                    
                    let routerX = rooms["router"][i]["x"].intValue
                    let routerY = rooms["router"][i]["y"].intValue
                    
                    let routerWidth = rooms["router"][i]["width"].intValue
                    let routerHeight = rooms["router"][i]["height"].intValue
                    
                    routerRotateAngle = rooms["router"][i]["rotation"].intValue
                    
                    print("RoUTER \(routerX)  \(routerY)  \(routerWidth)  \(routerHeight) \(routerRotateAngle)")
                    
                    let viewPoint = UIView(frame: CGRect(x: routerX , y: routerY, width: routerWidth, height: routerHeight))
                    
                    viewPoint.center = CGPoint(x: routerX, y: routerY)
                    
                    
                    viewPoint.cornerRadius = (viewPoint.width) / 2
                    
                    viewPoint.autoresizesSubviews = true
                    viewPoint.clipsToBounds = true
                    
                    viewPoint.isUserInteractionEnabled = true
                    viewPoint.backgroundColor = UIColor.darkGray
                    
                    if routerRotateAngle == 0 {
                        viewPoint.transform = viewPoint.transform.rotated(by: .pi/2)
                        print("ROUTER ROTATE ANGLE IS 0 DEGREE")
                        
                    }else {
                        print("ROUTER ROTATE ANGLE NOT 0 DEGREE")
                    }
                    
                    planImage.addSubview(viewPoint)
                }
                
                //SWITCH
                switchInstallation(rooms: rooms)
                
                //POINT
                pointInstallation(rooms: rooms)
                
                
            } else {
                print("ROUTER NOT AVAILABLE IN THIS ROOM")
            }
        }
    }
    
    
    func switchInstallation(rooms: JSON) {
        let switchCount = rooms["light_switches"].count
        print("SWITCH COUNT \(switchCount)")
        
        
        for i in 0 ..< switchCount {
            
            let switchX = rooms["light_switches"][i]["x"].intValue
            let switchY = rooms["light_switches"][i]["y"].intValue
            
            let switchWidth = rooms["light_switches"][i]["width"].intValue
            let switchHeight = rooms["light_switches"][i]["height"].intValue
            
            print("Switch \(switchX)  \(switchY)  \(switchWidth)  \(switchHeight) ")
            
            switchView = UIImageView(frame: CGRect(x: switchX , y: switchY, width: switchWidth, height: switchHeight))
            
            switchView.center = CGPoint(x: switchX, y: switchY)
            
            switchView.cornerRadius = (switchView.width) / 2
            switchView.tag = i + 500
            
            switchView.stringTag = String(switchView.tag)
            
            switchView.autoresizesSubviews = true
            switchView.clipsToBounds = true
            
            // VIEW BLINK ANIMATION
            switchView.alpha = 0
            //var stopBlink = false
            UIView.animate(withDuration: 1.0, delay: 0.5, options: [.autoreverse, .curveEaseInOut], animations: {
                
                self.switchView.alpha = 1.0
                
            }, completion: nil)
            
            
            //Check with Switch Config response if configured switch is grayed out else switch is enabled
            let switchConfigSts = roomConfigResponse["switch"][i]["switch_config_sts"].boolValue
            
            print("switchConfigSts/// \(switchConfigSts)")
            
            if switchConfigSts == true {
                print("switchConfigSts TRUE")
                switchView.isUserInteractionEnabled = false
                switchView.backgroundColor = UIColor.darkGray
                
            }else if switchConfigSts == false {
                print("switchConfigSts FALSE")
                switchView.isUserInteractionEnabled = true
                switchView.backgroundColor = customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(0.6)
                
            }else {
                print("switchConfigSts else")
            }
            

            totalViewsArr.append(switchView)
            planImage.addSubview(switchView)
           
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapBtn(tap:)))
            tap.delegate = self
            switchView.addGestureRecognizer(tap)
            
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panButton(pan:)))
            pan.delegate = self
            switchView.addGestureRecognizer(pan)
            scrollView.panGestureRecognizer.require(toFail: pan)
            
            //            //setup collisionBehaviour and animator
            //            collision = UICollisionBehavior(items: [switchView])
            //            //collisionBehaviour!.collisionMode = UICollisionBehaviorMode.allZeros
            //            animator = UIDynamicAnimator(referenceView: planImage)
            //            collision?.translatesReferenceBoundsIntoBoundary = true
            //
            //            collision?.addBoundary(withIdentifier: "boundary" as NSCopying, for: UIBezierPath(rect: CGRect(x: roomX, y: roomY, width: roomWidth, height: roomHeight)))
            //            animator?.addBehavior(collision!)
            //            print("\(roomX) \(roomY) --- \(roomWidth) \(roomHeight)")
        }

    }
    
    
    func pointInstallation(rooms: JSON) {
        let pointCount = rooms["point"].count
        print("point COUNT \(pointCount)")
        
        for i in 0 ..< pointCount {
            
            let pointX = rooms["point"][i]["x"].intValue
            let pointY = rooms["point"][i]["y"].intValue
            
            let pointWidth = rooms["point"][i]["width"].intValue
            let pointHeight = rooms["point"][i]["height"].intValue
            
            print("point \(pointX)  \(pointY)  \(pointWidth)  \(pointHeight) ")
            
            pointView = UIImageView(frame: CGRect(x: pointX , y: pointY, width: pointWidth, height: pointHeight))
            
            pointView.center = CGPoint(x: pointX, y: pointY)
            
            pointView.cornerRadius = (pointView.width) / 2
            pointView.tag = i + 1000
            
            pointView.autoresizesSubviews = true
            pointView.clipsToBounds = true
            
            // VIEW BLINK ANIMATION
            pointView.alpha = 0
            //var stopBlink = false
            UIView.animate(withDuration: 1.0, delay: 0.5, options: [.autoreverse, .curveEaseInOut], animations: {
                
                self.pointView.alpha = 1.0
                
            }, completion: nil)
            
            //Check with Point Config response if configured point is grayed out else point is enabled
            let pointConfigSts = roomConfigResponse["point"][i]["point_config_sts"].boolValue
            
            if pointConfigSts == true {
                print("pointConfigSts TRUE")
                pointView.isUserInteractionEnabled = false
                pointView.backgroundColor = UIColor.darkGray
                
            }else if pointConfigSts == false {
                print("pointConfigSts FALSE")
                pointView.isUserInteractionEnabled = true
                pointView.backgroundColor = customUtil.hexStringToUIColor(hex: "4ABFA7").withAlphaComponent(0.6)
            }else {
                print("pointConfigSts else")
            }

            totalViewsArr.append(pointView)
            planImage.addSubview(pointView)
            
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapBtn(tap:)))
            tap.delegate = self
            pointView.addGestureRecognizer(tap)
            
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panButton(pan:)))
            pan.delegate = self
            pointView.addGestureRecognizer(pan)
            scrollView.panGestureRecognizer.require(toFail: pan)
        }
        
    }
    

    
    func drawLines(moveX: CGFloat,moveY: CGFloat, addlinetoX: CGFloat, addlinetoY:CGFloat){

        path.move(to: CGPoint(x: moveX, y: moveY))
        path.addLine(to: CGPoint(x: addlinetoX, y: addlinetoY))
        
        layer.path = path.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.withAlphaComponent(0.7).cgColor
        layer.lineWidth = 2
        
        self.planImage.layer.addSublayer(layer)
    }
    
    func drawConfiguredLines(segments: JSON){
        
        let segmentsCount = segments.count
       
        let segmentX = CGFloat(segments[0][0].floatValue)
        let segmentY = CGFloat(segments[0][1].floatValue)
        
        configuredPath.move(to: CGPoint(x: segmentX, y: segmentY))
        
        for i in 1 ..< segmentsCount {
            configuredPath.addLine(to: CGPoint(x: CGFloat(segments[i][0].floatValue), y: CGFloat(segments[i][1].floatValue)))
        }
        
        configuredPath.close()
        
        configuredLayer.path = configuredPath.cgPath
        configuredLayer.fillColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        configuredLayer.strokeColor = UIColor.green.withAlphaComponent(0.7).cgColor
        configuredLayer.lineWidth = 2
        
        self.planImage.layer.addSublayer(configuredLayer)
        
    }
    
    func drawSelectedRoomLines(segments: JSON){
        
        let segmentsCount = segments.count
        
        var segmentXArr = [CGFloat]()
        var segmentYArr = [CGFloat]()
        
        let segmentX = CGFloat(segments[0][0].floatValue)
        let segmentY = CGFloat(segments[0][1].floatValue)
        
        selectedRoomPath.move(to: CGPoint(x: segmentX, y: segmentY))
        
        for i in 1 ..< segmentsCount {
            selectedRoomPath.addLine(to: CGPoint(x: CGFloat(segments[i][0].floatValue), y: CGFloat(segments[i][1].floatValue)))
            
            segmentXArr.append(CGFloat(segments[i][0].floatValue))
            segmentYArr.append(CGFloat(segments[i][1].floatValue))
           // if CGFloat(segments[i][1].floatValue)
        }
        
        if segmentXArr.count != 0 {
            
            selectedRoomXMax = segmentXArr.max()!
            selectedRoomXMin = segmentXArr.min()!
            
            print("selectedRoomXMax \(selectedRoomXMax)  selectedRoomXMin \(selectedRoomXMin)")
            
        }
        
        if segmentYArr.count != 0 {
            
            selectedRoomYMax = segmentYArr.max()!
            selectedRoomYMin = segmentYArr.min()!
            print("selectedRoomYMax \(selectedRoomYMax) selectedRoomYMin \(selectedRoomYMin)")
            
        }
        
       
        selectedRoomPath.close()
        
        selectedRoomLayer.path = selectedRoomPath.cgPath
        selectedRoomLayer.fillColor = UIColor.clear.cgColor
        selectedRoomLayer.strokeColor = customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(0.7).cgColor
        selectedRoomLayer.lineWidth = 2
    
        self.planImage.layer.addSublayer(selectedRoomLayer)
        
    }
    
    
    //Single Tap selector
    func tapBtn(tap: UITapGestureRecognizer) {
        print("TAPPED BUTTON")
        
        if attachment != nil {
        animator?.removeBehavior(attachment)
        }
        
        self.scrollView.isScrollEnabled = true
        
        print("TAP planBGCOLor",self.planImage.backgroundColor == UIColor.clear.withAlphaComponent(1.0))
        print("TAP view BGCOLOR",(tap.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(1.0) || tap.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "4ABFA7").withAlphaComponent(1.0)) )
        
        let selectedDevice = (tap.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(1.0) || tap.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "4ABFA7").withAlphaComponent(1.0))
        let notSelectedDevice = (tap.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(0.6) || tap.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "4ABFA7").withAlphaComponent(0.6))
        
        if self.planImage.backgroundColor == UIColor.clear.withAlphaComponent(1.0) && selectedDevice{
            print("TEMPo IF")
            
            roomExitBtn.isHidden = false
            
            actionLabelTop.text = "Select or add device"
            actionLabelBottom.text = "Tap a device to configure or select add device"
            
            customUtil.navTitle(text: "Device Setup", view: self)
            
            addDeviceBtn.isHidden = false
            confirmBtn.isHidden = true
            
            viewTag = (tap.view?.tag)!
            print("VIEW TAG IF: ",viewTag)
            
            // Remove close image
            for subview in view.subviews {
                if let findView = subview.viewWithTag(viewTag) as? UIImageView{
                    findView.image = nil
                }
            }
            
            if viewTag >= 500 && viewTag < 1000 {
                tap.view?.backgroundColor = customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(0.6)
   
            }else if viewTag >= 1000 {
                tap.view?.backgroundColor = customUtil.hexStringToUIColor(hex: "4ABFA7").withAlphaComponent(0.6)

            }else {
                print("VIEW TAG NOT SWITCH OR POINT")
            }
            
            
            UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: {
                //                self.planImage.alpha = 0.6
                
                self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(0)
                self.tapTemp = 0
                //self.rotateTemp = 0
            }, completion: nil)
        }
        else if self.planImage.backgroundColor == UIColor.clear.withAlphaComponent(0) && notSelectedDevice  {
            
            addDeviceBtn.isHidden = true
            confirmBtn.isHidden = false
            roomExitBtn.isHidden = true
            
            self.scrollView.isScrollEnabled = false
            
            actionLabelTop.text = "Correct location..."
            actionLabelBottom.text = "Confirm or drag device to change location"
            
            
            print("TEMPo ELSE")
            viewTag = (tap.view?.tag)!
            print("VIEW TAG else if: ",viewTag)
            
            // Add Close image for selected view
            for subview in view.subviews {
                if let findView = subview.viewWithTag(viewTag) as? UIImageView{
                    print("Change image \(findView)")
                    findView.image = UIImage(named: "CloseX48")
                }
            }
            
            if viewTag >= 500 && viewTag < 1000 {
                let switchNo = viewTag - 500
                let switchName = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex]["light_switches"][switchNo]["name"].stringValue
                print("SWITCH NAME \(switchName)")
                customUtil.navTitle(text: switchName, view: self)
                
                print("switchView.tag  \(String(describing: tap.view?.tag))")

                tap.view?.backgroundColor = customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(1.0)
                
            }else if viewTag >= 1000 {
                let pointNo = viewTag - 1000
                let pointName = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex]["point"][pointNo]["name"].stringValue
                print("POINT NAME \(pointName)")
                customUtil.navTitle(text: pointName, view: self)
                
                tap.view?.backgroundColor = customUtil.hexStringToUIColor(hex: "4ABFA7").withAlphaComponent(1.0)
            }else {
                print("VIEW TAG NOT SWITCH OR POINT")
            }
            
            
            UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //self.planImage.alpha = 1.0
                self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(1.0)
                self.tapTemp = 1
            }, completion: nil)
        }
        else  {
            print("VIEW IS ALREADY SELECTED")
            self.scrollView.isScrollEnabled = false
        }
        
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
            print("DEVICE SETUP VIEW DOUBLE TAP \(CGRect(origin: origin, size: size))")
        }
    }
    
    
    //Pan Gesture Selector
    func panButton(pan:UIPanGestureRecognizer) {
        
        var currentPanLocPoint = CGPoint()
        
        print("VIEW TAG : ",viewTag)
        self.scrollView.isScrollEnabled = false
        
        var selectedKikoDevice = ""
        
        print("PAN VIEWTAG",viewTag == pan.view?.tag)
        print("PAN TAP TEMP",tapTemp)
        print("PAN view BGColor",(pan.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(1.0) || pan.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "4ABFA7").withAlphaComponent(0.6)))
        
        if viewTag == pan.view?.tag && tapTemp == 1 && (pan.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(1.0) || pan.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "4ABFA7").withAlphaComponent(1.0)) {
            
            print("DEVICE SETUP VIEW LOC -----> \((pan.location(in: planImage)))   FRAME: \(planImage.frame.contains(pan.location(in: planImage)))")
            
            if planImage.frame.contains(pan.location(in: planImage)) { //Check bounds for panning
                
                let locPoint = pan.location(in: planImage) // get pan location
                let draggedView = pan.view
                
                currentPanLocPoint = locPoint
                
                print("--> \(globalRoomX)  \(globalRoomY) \(globalRoomWidth) \(globalRoomHeight)")
                
                if (globalRoomX < locPoint.x) && (locPoint.x  < globalRoomX+globalRoomWidth) && (globalRoomY < locPoint.y) && (locPoint.y < globalRoomY+globalRoomHeight) {
                    print("PAN ENDED LOCATION : \(locPoint) \(locPoint.x)  \(locPoint.y)  PLAN TAG \(String(describing: draggedView?.tag))")
                    
                    draggedView?.center = locPoint // set View to where finger is
                    print("viewTag  -> ",viewTag)
                    
                    if viewTag >= 500 && viewTag < 1000 {
                        let switchNo = viewTag - 500
                        
                        selectedKikoDevice = "Switch"
                        
                        selectedRoomJsonObj["light_switches"][switchNo]["x"].stringValue = locPoint.x.description
                        selectedRoomJsonObj["light_switches"][switchNo]["y"].stringValue = locPoint.y.description
                        
                        selectedStickyWall = selectedRoomJsonObj["light_switches"][switchNo]["sticky_wall"].stringValue
                        
                    } else if viewTag >= 1000 {
                        
                        let pointNo = viewTag - 1000
                        
                        selectedKikoDevice = "Point"
                        
                        selectedRoomJsonObj["point"][pointNo]["x"].stringValue = locPoint.x.description
                        selectedRoomJsonObj["point"][pointNo]["y"].stringValue = locPoint.y.description
                        
                        selectedStickyWall = selectedRoomJsonObj["point"][pointNo]["sticky_wall"].stringValue
                        
                    } else {
                        print("VIEW TAG NOT SWITCH OR POINT")
                    }
                    
                    print("DEVICE SETUP VIEW draggedView=== \(String(describing: draggedView?.tag))  POINT ----------> \(locPoint)  \(planImage.height)")
                }else {
                    print("DEVICE SETUP VIEW PAN OUT OF ROOM BOUNDRY")
                }
                
            }else{
                print("DEVICE SETUP VIEW PAN NOT IN IMAGE FRAME")
            }
            
            
            if pan.state == UIGestureRecognizerState.changed {
                
                if attachment != nil {
                    animator?.removeBehavior(attachment)
                }
                
                print("UIGestureRecognizerState.changed")
                
                //animator?.addBehavior(collision!)
            } else if pan.state == UIGestureRecognizerState.ended {
                
                print("UIGestureRecognizerState.ended")
                
                
                if snapBehaviour != nil {
                    animator?.removeBehavior(snapBehaviour)
                }
                
                if attachment != nil {
                    animator?.removeBehavior(attachment)
                }
                
                for otherViews in totalViewsArr {
                    if (pan.view == otherViews){
                        if ((pan.view?.frame)!.intersects(otherViews.frame)) {
                            // Do something
                            print("INTERSECTS")
                        }
                    }
                    
                    
                }
                
                //            collision = UICollisionBehavior(items: totalViewsArr)
                //            collision?.translatesReferenceBoundsIntoBoundary = true
                //            collision?.collisionMode = .items
                //            collision?.collisionDelegate = self
                //            collision?.action = {
                //                print("Collision")
                //
                //            }
                //            animator?.addBehavior(collision!)
                print("currentPanLocPoint \(currentPanLocPoint)")
                
                
                print("@@@@ selectedRoomYMax/2 \(selectedRoomYMax/2)")
                
                let roomMidHeight = globalRoomHeight / 2
                let roomMidY = selectedRoomYMin + roomMidHeight
                
                let roomMidWidth = globalRoomWidth / 2
                let roomMidX = selectedRoomXMin + roomMidWidth
                
                var finalSnapX = ""
                var finalSnapY = ""
                
                print("roomMidHeight \(roomMidHeight) \(roomMidY)")
                print("selectedStickyWall \(selectedStickyWall)")
                
                if selectedStickyWall == "y" ||  selectedStickyWall == "y2"{
                    
                    print("selectedStickyWall y or y1")
                    
                    if currentPanLocPoint.y < roomMidY { //Upper half of room
                        
                        print("currentPanLocPoint.y if \(currentPanLocPoint.y)")
                        snapBehaviour = UISnapBehavior(item: pan.view!, snapTo: CGPoint(x: currentPanLocPoint.x, y: selectedRoomYMin))
                        print("snap if \(currentPanLocPoint.x) \(selectedRoomYMin)")
                        snapBehaviour.damping = 0.3
                        animator?.addBehavior(snapBehaviour)
                        
                        finalSnapX = currentPanLocPoint.x.description
                        finalSnapY = selectedRoomYMin.description
                        
                    }else if currentPanLocPoint.y > roomMidY{ //lower half of room
                        
                        print("currentPanLocPoint.y else \(currentPanLocPoint.y)")
                        snapBehaviour = UISnapBehavior(item: pan.view!, snapTo: CGPoint(x: currentPanLocPoint.x, y: selectedRoomYMax))
                        print("snap else \(currentPanLocPoint.x) \(selectedRoomYMax)")
                        snapBehaviour.damping = 0.3
                        animator?.addBehavior(snapBehaviour)
                        
                        finalSnapX = currentPanLocPoint.x.description
                        finalSnapY = selectedRoomYMax.description
                        
                    }
                }else if selectedStickyWall == "x" ||  selectedStickyWall == "x2"{
                    
                    if currentPanLocPoint.x < roomMidX{ // left half
                        
                        print("currentPanLocPoint.x if")
                        snapBehaviour = UISnapBehavior(item: pan.view!, snapTo: CGPoint(x: selectedRoomXMin, y: currentPanLocPoint.y))
                        print("snap else \(currentPanLocPoint.x) \(selectedRoomYMax)")
                        snapBehaviour.damping = 0.3
                        animator?.addBehavior(snapBehaviour)
                        
                        finalSnapX = selectedRoomXMin.description
                        finalSnapY = currentPanLocPoint.y.description
                        
                    }else if currentPanLocPoint.x > roomMidX{ // Right half
                        print("currentPanLocPoint.x else")
                        snapBehaviour = UISnapBehavior(item: pan.view!, snapTo: CGPoint(x: selectedRoomXMax, y: currentPanLocPoint.y))
                        print("snap else \(currentPanLocPoint.x) \(selectedRoomYMax)")
                        snapBehaviour.damping = 0.3
                        animator?.addBehavior(snapBehaviour)
                        
                        finalSnapX = selectedRoomXMax.description
                        finalSnapY = currentPanLocPoint.y.description
                    }
                    
                }else {
                    print("selectedStickyWall is wrong")
                }
                
                
                //Save X and Y of snapped kiko devices
                if selectedKikoDevice == "Switch" && finalSnapX != "" && finalSnapY != ""{
                    
                    let switchNo = viewTag - 500
                    selectedRoomJsonObj["light_switches"][switchNo]["x"].stringValue = finalSnapX
                    selectedRoomJsonObj["light_switches"][switchNo]["y"].stringValue = finalSnapY
                    
                }else if selectedKikoDevice == "Point" && finalSnapX != "" && finalSnapY != ""{
                    
                    let pointNo = viewTag - 1000
                    selectedRoomJsonObj["point"][pointNo]["x"].stringValue = finalSnapX
                    selectedRoomJsonObj["point"][pointNo]["y"].stringValue = finalSnapY
                    
                }else {
                    print("selectedKikoDevice not switch or point")
                }
            }
            
            
        }else{
            print("DEVICE SETUP VIEW TAP AND PAN VIEW")
        }
    }
    
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        print("delegate' \(behavior)  \(item1)  \(item2) \(p)")
        
        if collision != nil {
            animator?.removeBehavior(collision!)
        }
        //attachment = UIAttachmentBehavior(item: item2, attachedToAnchor: CGPoint(x: pointX, y: pointY))
        
//        attachment = UIAttachmentBehavior(item: item1, attachedTo: item2)
       
        attachment = UIAttachmentBehavior(item: item1, offsetFromCenter: .zero, attachedTo: item2, offsetFromCenter: .zero)
        attachment.frequency = 0
        //attachment.anchorPoint = p
        attachment.damping = 0.3

        animator?.addBehavior(attachment)
        
    }
    
    // Scroll View Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return planImage
    }
    
    
    // Select the Room by touchpoint
    func tapToSelectRoom(tap:UITapGestureRecognizer) {
        
        if roomAlreadySelected == 0 {
            roomAlreadySelected = 1
            print("Room SELECTED")
            
            let rooms = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"]
            
            let touchPoint = tap.location(in: self.planImage)
            let touchX = touchPoint.x
            let touchY = touchPoint.y
            print("ROOM touch POINT \(touchPoint) touchX \(touchX) touchY \(touchY) ")
            
            let roomsCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"].count
            print("tapToSelectRoom ROOM COUNT \(roomsCount)")
            
            var roomIndexArr = [CGFloat]()
            
            for i in 0 ..< roomsCount {
                let roomXMin = CGFloat(rooms[i]["x"].floatValue)
                let roomYMin = CGFloat(rooms[i]["y"].floatValue)
                
                let roomWidth = CGFloat(rooms[i]["width"].floatValue)
                let roomHeight = CGFloat(rooms[i]["height"].floatValue)
                
                let roomXMax = roomXMin + roomWidth
                let roomYMax = roomYMin + roomHeight
                
                print("roomXMin \(roomXMin) roomYMin \(roomYMin) roomXMax \(roomXMax) roomYMax \(roomYMax)")
                
                switch touchX {
                case roomXMin ... roomXMax:
                    //print("Room X--> room Index\(i)")
                    
                    if ((roomYMin < touchY) && (touchY < roomYMax)){
                        //print("ROOM IND--> \(i)")
                        
                        roomIndexArr.append(CGFloat(i))
                        
                    }else {
                        print("Touch not in room")
                    }
                    
                default:
                    print("touchX failure")
                }
                
            }
            
            if roomIndexArr.count == 1 {
                print("1 Room Selected")
                print("roomArr \(roomIndexArr)")
                
                tappedRoomIndex = Int(roomIndexArr[0])
                
                selectedRoomIndex = tappedRoomIndex
                selectedRoomJsonObj = rooms[selectedRoomIndex]
                
                 let selectedRoomName = rooms[self.tappedRoomIndex]["display_name"].stringValue
                let roomId = rooms[tappedRoomIndex]["id"].stringValue
                print("roomId--> \(roomId)")
                
                // Check if tapped room is router room
                if roomId != routerRoomId {
                   
                    
                    let selectedRoomX = CGFloat(rooms[tappedRoomIndex]["x"].floatValue)
                    let selectedRoomY = CGFloat(rooms[tappedRoomIndex]["y"].floatValue)
                    let selectedRoomWidth = CGFloat(rooms[tappedRoomIndex]["width"].floatValue)
                    let selectedRoomHeight = CGFloat(rooms[tappedRoomIndex]["height"].floatValue)
                    
                    globalRoomX = selectedRoomX
                    globalRoomY = selectedRoomY
                    globalRoomWidth = selectedRoomWidth
                    globalRoomHeight = selectedRoomHeight
                    
                   requestRoomConfigured(roomId: roomId)
                    
                    //            switchInstallation(rooms: rooms[roomIndex])
                    //            pointInstallation(rooms: rooms[roomIndex])
                }
                else {
                    customUtil.toast(view: self, title: "Already Configured", message: "You have already configured \(selectedRoomName)")
                    roomAlreadySelected = 0
                }
                
                
                
            }else if (roomIndexArr.count > 1) {
                print("Multiple Room Selected")
                print("roomArr Elements \(roomIndexArr)")
                
                let alert = UIAlertController(title: "Multiple Rooms Selected", message: "Select a room to Configure", preferredStyle: .alert)
                for i in roomIndexArr {
                    
                    let roomIndex = Int(i)
                    print("Room IND--> \(roomIndex)")
                    let selectedRoomName = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomIndex]["display_name"].stringValue
                    
                    alert.addAction(UIAlertAction(title: selectedRoomName, style: .default, handler: selectedRoomActionFromRoomIndexArr(roomIndex: roomIndex)))
                    
                }
                self.present(alert, animated: true, completion: nil)
            }else {
                print("roomIndexArr Count 0 outside room areas selected")
                roomAlreadySelected = 0
            }
            
        }else {
            print("**ROOM Already Selected**")
        }
    }
    
    
    func selectedRoomActionFromRoomIndexArr(roomIndex:Int) -> (_ alertAction:UIAlertAction) -> () {
    return { alertAction in
    print("roomIndex: \(roomIndex)")
        
        let rooms = self.jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"]
        
        self.tappedRoomIndex = roomIndex
        self.selectedRoomIndex = self.tappedRoomIndex
        self.selectedRoomJsonObj = rooms[self.selectedRoomIndex]
        
        
        let selectedRoomName = rooms[self.tappedRoomIndex]["display_name"].stringValue
        let roomId = rooms[self.tappedRoomIndex]["id"].stringValue
        print("roomId-->| \(roomId)")
        
        if roomId != self.routerRoomId {
           // self.customUtil.toast(view: self, title: "Room Selected", message: "You have Selected \(selectedRoomName)")
            
            let selectedRoomX = CGFloat(rooms[roomIndex]["x"].floatValue)
            let selectedRoomY = CGFloat(rooms[roomIndex]["y"].floatValue)
            let selectedRoomWidth = CGFloat(rooms[roomIndex]["width"].floatValue)
            let selectedRoomHeight = CGFloat(rooms[roomIndex]["height"].floatValue)
            
            self.globalRoomX = selectedRoomX
            self.globalRoomY = selectedRoomY
            self.globalRoomWidth = selectedRoomWidth
            self.globalRoomHeight = selectedRoomHeight
            
            //self.scrollView.zoom(to: CGRect(x: selectedRoomX, y: selectedRoomY, width: selectedRoomWidth, height: selectedRoomHeight), animated: true)
            
            self.requestRoomConfigured(roomId: roomId)
            
        }else {
            self.customUtil.toast(view: self, title: "Already Configured", message: "You have already configured \(selectedRoomName)")
            self.roomAlreadySelected = 0
        }

    }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        
        mqttClient.connectMqtt()
        
        print("roomAlreadySelected Appear- \(roomAlreadySelected)")
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        actionLabelTop.text = "Select or add device"
        actionLabelBottom.text = "Tap a device to configure or select add device"
        
        confirmBtn.isHidden = true
        addDeviceBtn.isHidden = false
        
        if roomAlreadySelected == 1 { //Show roomExitBtn if roomAlreadySelected
            print("Show roomExitBtn if roomAlreadySelected")
            roomExitBtn.isHidden = false
        }
        
        jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        selectedRoomJsonObj = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex]
        
        print("*roomI \(selectedRoomIndex)")
//        scrollView.zoom(to: CGRect(x: roomX, y: roomY, width: roomWidth, height: roomHeight), animated: true)
        print("DEVICE SETUP VIEW ZOOOOOOMING")
        
        customUtil.navTitle(text: "Device Setup", view: self)

        if callRouterRoom == 1 {
            print("FirstTime View Appears send Router Room ID \(currentRouterRoomId) as parameter")
            requestRoomConfigured(roomId: currentRouterRoomId)
            //roomAlreadySelected = 1
            callRouterRoom = 0
        } else {
            print("Send Current roomId as parameter")
//            roomAlreadySelected = 0
            let currentRoomId = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex]["id"].stringValue
            requestRoomConfigured(roomId: currentRoomId)
        }
        
        
        print("2 roomAlreadySelected Appear- \(roomAlreadySelected)")
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
        
        //        if tapTemp == 1 {
        //
        //            if viewTag >= 500 && viewTag < 1000 {
        //                let switchNo = viewTag - 500
        //                let switchName = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomI]["switch"][switchNo]["name"].stringValue
        //                print("SWITCH NAME viewWillAppear \(switchName)")
        //                customUtil.navTitle(text: switchName, view: self)
        //            }else if viewTag >= 1000 {
        //                let pointNo = viewTag - 1000
        //                let pointName = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomI]["point"][pointNo]["name"].stringValue
        //                print("POINT NAME  viewWillAppear \(pointName)")
        //                customUtil.navTitle(text: pointName, view: self)
        //            } else {
        //                print("NOT A SWITCH OR POINT viewWillAppear")
        //            }
        //        }else {
        //            print("viewWillAppear Tap Temp 0")
        //             customUtil.navTitle(text: "Device Setup", view: self)
        //        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print("viewWillDisappear")
        customUtil.removeNavTitle(view: self)
        
        self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(0)
        planImage.subviews.forEach { $0.removeFromSuperview() }
        
        selectedRoomPath.removeAllPoints()
        selectedRoomLayer.removeFromSuperlayer()
       
    }

    @IBAction func backBtn(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
 
    @IBAction func addDeviceBtnAction(_ sender: Any) {
        print("ADD DEVICE BTN CLICKED")
       
    }
    
    @IBAction func roomExitBtnAction(_ sender: Any) {
        
        self.view.setNeedsDisplay()
        
        roomAlreadySelected = 0
        self.tapTemp = 0
        
        UIView.animate(withDuration: 1.0, delay: 0.5, options: [.curveEaseInOut], animations: {
            
            self.planImage.subviews.forEach { $0.removeFromSuperview() }
            self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(0)
            self.scrollView.zoomScale = self.zoomMinScale
            self.customUtil.navTitle(text: "Device Setup", view: self)
            
        }, completion: nil)
        
        print("zoomMinScale \(zoomMinScale)")

        //Remove selectedRoomLines
        selectedRoomPath.removeAllPoints()
        selectedRoomLayer.removeFromSuperlayer()
    }
    
    @IBAction func completePlanBtnAction(_ sender: Any) {
        print("completePlanBtnAction")
        
        self.customUtil.activityIndicatorStart(view: self.view)
        
        let areaId = jsonObj["designs"][0]["areas"][currentAreaIndex]["id"].stringValue
        print("areaId \(areaId) ")
        
        let planUid = jsonObj["uid"].stringValue
        let planUidData = planUid.data(using: String.Encoding.utf8)
        print("==== \(planUid)  \(String(describing: planUidData))")
        
        let jsonString = jsonObj.rawString()
        //print("jsonString-->",jsonString!)
        let jsonData = jsonString?.data(using: String.Encoding.utf8)
        
        print("jsonDATA-->",jsonData!)
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        
        let properties = GlobalClass.sharedInstance.propertiesJson()
        let host = properties["Host"].stringValue
        let urlPath = properties["Update_House_Plan"].stringValue
        let url = host + urlPath
        print("URL Path",host+urlPath)
        
        sessionManager.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(planUidData!, withName: "plan_uid")
            multipartFormData.append(jsonData!, withName: "plan_upd_json", fileName: "plan_upd_json", mimeType: "application/json")     
            
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
                            
                            self.customUtil.toast(view: self, title: "Success", message: message)
                            
                            //Delay perform Segue by 1.5 seconds
                            let timeToDissapear : DispatchTime = DispatchTime.now() + 1.5
                            let when = timeToDissapear
                            DispatchQueue.main.asyncAfter(deadline: when){
                                // PUSH Segue with flip animation
                                UIView.beginAnimations("animation", context: nil)
                                UIView.setAnimationDuration(0.6)
                                let mainStory = UIStoryboard(name: "Home", bundle: nil)
                                let des = mainStory.instantiateViewController(withIdentifier: "InstallationSummaryViewController") as! InstallationSummaryViewController
                                
                                des.areaId = areaId
                                    
                                self.navigationController!.pushViewController(des, animated: false)
                                UIView.setAnimationTransition(UIViewAnimationTransition.flipFromRight, for: self.navigationController!.view, cache: false)
                                UIView.commitAnimations()
                            }
                            
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
   
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        let  mainStory = UIStoryboard(name: "Home", bundle: nil)
        let switchDestination = mainStory.instantiateViewController(withIdentifier: "ConfirmSwitchNameViewController") as! ConfirmSwitchNameViewController
        let pointDestination = mainStory.instantiateViewController(withIdentifier: "ConfirmPointNameViewController") as! ConfirmPointNameViewController
        
        print("@RoomI \(selectedRoomIndex)")
        
        if viewTag >= 500 && viewTag < 1000 {
            print("SWITCH SELECTED")
            switchDestination.switchArrNo = viewTag - 500
            switchDestination.roomNo = selectedRoomIndex
            switchDestination.switchTag = viewTag
         
            let compareJson = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex] == selectedRoomJsonObj
            print("SWITCH JSON COMPARE EQUAL \(compareJson)")
            
            
            if(compareJson == true){
                print("SWITCH JSON COMPARISON VALUES SAME")
            }else{
                jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex] = selectedRoomJsonObj
                
                let switchX = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex]["light_switches"][viewTag - 500]["x"]
                let switchY = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex]["light_switches"][viewTag - 500]["y"]
                
                let switchNo = viewTag - 500
                 //let switchName = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomI]["switch"][switchNo]["name"].stringValue
                
                print("switch X : \(switchX)  Y:\(switchY) ")
                
                GlobalClass.sharedInstance.setPlanJsonObject(object: jsonObj)
                print("SWITCH JSON VALUE SET TO GLOBAL Class")
                
                do{
                    print("SWITCH CHANGED JSON \(jsonObj)")
                    let data = try jsonObj.rawData()
                    print("SWITCH NEWW---> \(data)")
                    try fileUtil.overwriteFileToTempFolder(dataForJson: data as AnyObject, path: "/TempPlan/\(currentSelectedPlanName).json")
                    print("SWITCH OVERWRITE FILE TEMP WRITE SUCCESS")
                }catch{
                    print("SWITCH OVERWRITE Error writing data: \(error)")
                }
            }
            
            // PUSH Segue with flip animation
            UIView.beginAnimations("animation", context: nil)
            UIView.setAnimationDuration(0.6)
            self.navigationController!.pushViewController(switchDestination, animated: false)
            UIView.setAnimationTransition(UIViewAnimationTransition.flipFromRight, for: self.navigationController!.view, cache: false)
            UIView.commitAnimations()
            
        }
        else if viewTag >= 1000 {
            print("POINT SELECTED")
            let compareJson = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex] == selectedRoomJsonObj
            print("POINT JSON COMPARE EQUAL \(compareJson)")
            
            pointDestination.pointArrNo = viewTag - 1000
            pointDestination.roomNo = selectedRoomIndex

            if(compareJson == true){
                print("POINT JSON COMPARISON VALUES SAME")
            }else{
                jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex] = selectedRoomJsonObj
                
                let pointX = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex]["point"][viewTag - 1000]["x"]
                let pointY = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][selectedRoomIndex]["point"][viewTag - 1000]["y"]
                
                print("point X : \(pointX)  Y:\(pointY) ")
                
                GlobalClass.sharedInstance.setPlanJsonObject(object: jsonObj)
                print("POINT JSON VALUE SET TO GLOBAL Class")
                
                do{
                    print("POINT CHANGED JSON \(jsonObj)")
                    let data = try jsonObj.rawData()
                    print("POINT NEWW---> \(data)")
                    try fileUtil.overwriteFileToTempFolder(dataForJson: data as AnyObject, path: "/TempPlan/\(currentSelectedPlanName).json")
                    print("POINT OVERWRITE FILE TEMP WRITE SUCCESS")
                }catch{
                    print("POINT OVERWRITE Error writing data: \(error)")
                }
            }
            
            // PUSH Segue with flip animation
            UIView.beginAnimations("animation", context: nil)
            UIView.setAnimationDuration(0.6)
            self.navigationController!.pushViewController(pointDestination, animated: false)
            UIView.setAnimationTransition(UIViewAnimationTransition.flipFromRight, for: self.navigationController!.view, cache: false)
            UIView.commitAnimations()
            
        }else {
            print("VIEW TAG NOT SWITCH OR POINT \(viewTag) ")
        }
       
        
    }
}


