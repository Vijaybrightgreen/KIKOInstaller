//
//  RouterInstallLocationViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/3/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material

var currentRouterRoomId = ""

class RouterInstallLocationViewController: UIViewController,UIScrollViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editRouterStsBtn: FABButton!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    var httpsClient = HttpsClient()
    
    var planImage = UIImageView()
    
    var jsonObj : JSON = JSON.null
    var roomJsonObj : JSON = JSON.null
    var routerConfigResponse : JSON = JSON.null
    var roomI = 0
    
    var roomX:CGFloat = 0
    var roomY:CGFloat = 0
    var roomWidth:CGFloat = 0
    var roomHeight:CGFloat = 0
    
    var routerRotateAngle = 0
    
    var viewTag:Int!
    var tapTemp = 0
    
    var roomId = ""
    var routerId = ""

    let properties = GlobalClass.sharedInstance.propertiesJson()
    
    var path = UIBezierPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPlanImage()
        
        drawWallsOnHomePlan()
        
        scrollView.delegate = self
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight,scaleWidth)
        
        print("NOW \(scrollViewFrame)  \(scaleWidth)  \(scaleHeight)  \(minScale)")
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 4
        scrollView.zoomScale = minScale
        
    }
    
    func requestRouterConfigCheck(routerId:String,roomId:String) {
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "router_uid" : routerId,
            "room_uid" : roomId
        ]
        

        let urlPath = properties["Router_Config_Check"].stringValue
        print("UUUURL== \(urlPath)  routerId \(routerId) room_uid \(roomId)")
        
        httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
            
            self.routerConfigResponse = response
            
            print("Sucess RESPONSE---->",response)
            
            self.routerInstallation()
            
        }, failCompletionHandler: { response -> Void in
            
            print("FAILURE RESPONSE",response)
            
            
            
        }, error: { error -> Void in
            print("ERROR RESPONSE",error)
            
        })
    }
    
    func requestChangeRouterConfig(routerId: String, roomId: String, routerConfigSts: Bool) {
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "router_uid" : routerId,
            "router_config_sts" : routerConfigSts,
            "room_uid" : roomId
        ]
        
        let urlPath = properties["Router_Config"].stringValue
        
        httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
            
            self.routerConfigResponse = response
            
            print("requestChangeRouterConfig Sucess RESPONSE---->",response)
    
            
        }, failCompletionHandler: { response -> Void in
            
            print("requestChangeRouterConfig FAILURE RESPONSE",response)
            
            
            
        }, error: { error -> Void in
            print("requestChangeRouterConfig ERROR RESPONSE",error)
            
        })
    }
    
    func getPlanImage() {
  
        jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        
        let email = jsonObj["client_email"].stringValue
        print("EMAIL ID",email)
        
        let base64 = jsonObj["designs"][0]["areas"][currentAreaIndex]["image"].stringValue
        
        let decodedData = NSData(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0))
        let decodedImage = UIImage(data: decodedData! as Data)
        
        let pngImage = UIImagePNGRepresentation(decodedImage!)
        
        let image = UIImage(data: pngImage!)
        
        let imageAlpha = image?.image(alpha: 0.7)
        
        let width = imageAlpha?.width
        let height = imageAlpha?.height
        print("ImAGE HEIGHT \(String(describing: height))   WIDTH  \(String(describing: width))")
        
        planImage.frame = CGRect(x: 0, y: 0 , width: width!, height: height!)
        planImage.isUserInteractionEnabled = true
        planImage.image = imageAlpha
        
        
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
       
    }
    
     func drawWallsOnHomePlan() {
        
        let roomsCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"].count
        print("ROOM COUNT \(roomsCount)")
        
        
        for i in 0 ..< roomsCount {
            let rooms = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][i]
            
            routerExists(index: i)
            
            //                    let roomX = CGFloat(rooms["x"].floatValue)
            //                    let roomY = CGFloat(rooms["y"].floatValue)
            //                    let roomWidth = CGFloat(rooms["width"].floatValue)
            //                    let roomHeight = CGFloat(rooms["height"].floatValue)
            
            
            let segmentsCount = rooms["segments"].count
            
            for i in 0 ..< segmentsCount {
                
                if i == segmentsCount-1 {
                    
                    print("IFF---> LINE")
                    let segmentsX = CGFloat(rooms["segments"][i][0].floatValue)
                    let segmentsY = CGFloat(rooms["segments"][i][1].floatValue)
                    
                    let nextSegmentX = CGFloat(rooms["segments"][0][0].floatValue)
                    let nextSegmentY = CGFloat(rooms["segments"][0][1].floatValue)
                    
                    autoreleasepool { ()  in
                        
                        drawLines(moveX: segmentsX, moveY: segmentsY, addlinetoX: nextSegmentX, addlinetoY: nextSegmentY)
                        
                    }
                }else {
                    
                    
                    print("ELSE----> LINE")
                    let segmentsX = CGFloat(rooms["segments"][i][0].floatValue)
                    let segmentsY = CGFloat(rooms["segments"][i][1].floatValue)
                    
                    let nextSegmentX = CGFloat(rooms["segments"][i+1][0].floatValue)
                    let nextSegmentY =  CGFloat(rooms["segments"][i+1][1].floatValue)
                    
                    autoreleasepool { ()  in
                        
                        drawLines(moveX: segmentsX, moveY: segmentsY, addlinetoX: nextSegmentX, addlinetoY: nextSegmentY)
                        
                    }
                    
                }
            }
      
            
        }
        
    }
    
    //Check router Exists and assign Router Room index to "roomI" variable
    func routerExists(index:Int) {
        
        let rooms = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][index]
        let router = rooms["router"].exists()
        print("ROU EXISTS \(router)")
        
        if router == true {
            
            print("ROOM NO \(index)")
            roomI = index
            
            currentRouterRoomId = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI]["id"].stringValue
            
            roomJsonObj = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][index]
            print("ROOM VALUE \(roomJsonObj)")
            
            let roomName = rooms["display_name"].stringValue
            print("ROOM NAME  \(roomName)")
            
            roomX = CGFloat(rooms["x"].floatValue)
            roomY = CGFloat(rooms["y"].floatValue)
            roomWidth = CGFloat(rooms["width"].floatValue)
            roomHeight = CGFloat(rooms["height"].floatValue)
            
            print("ZOOM VALUE \(roomX)  \(roomY)  \(roomWidth)  \(roomHeight)")
        }else {
            print("ROUTER NOT AVAILABLE IN THIS ROOM")
        }
    }
    
    func routerInstallation() {
        
        let rooms = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI]
        
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
            
            //let viewPoint = UIView(frame: CGRect(origin: CGPoint(x: routerX, y: routerY), size: CGSize(width: routerWidth, height: routerHeight)))
            
            // UIView(frame: CGRect())
            
            
            viewPoint.center = CGPoint(x: routerX, y: routerY)
            
            
            viewPoint.cornerRadius = (viewPoint.width) / 2
            viewPoint.tag = i + 500
            viewPoint.autoresizesSubviews = true
            viewPoint.clipsToBounds = true
            
            let responseRouterConfigSts = routerConfigResponse["router_config_status"].boolValue
            print("responseRouterConfigSts  \(responseRouterConfigSts)")
            
            if responseRouterConfigSts == true {
                viewPoint.isUserInteractionEnabled = false
                viewPoint.backgroundColor = UIColor.darkGray
            }else {
                viewPoint.isUserInteractionEnabled = true
                viewPoint.backgroundColor = customUtil.hexStringToUIColor(hex: "4ABFA7")
            }
           
            
            if routerRotateAngle == 0 {
                viewPoint.transform = viewPoint.transform.rotated(by: .pi/2)
                print("ROUTER ROTATE ANGLE IS 0 DEGREE")
                
            }else {
                print("ROUTER ROTATE ANGLE *NOT* 0 DEGREE")
            }
            
            planImage.addSubview(viewPoint)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapBtn(tap:)))
            tap.delegate = self
            viewPoint.addGestureRecognizer(tap)
            
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panButton(pan:)))
            pan.delegate = self
            viewPoint.addGestureRecognizer(pan)
            scrollView.panGestureRecognizer.require(toFail: pan)
            
            let rotate = UILongPressGestureRecognizer(target: self, action: #selector(rotateView(longPress:)))
            rotate.delegate = self
            viewPoint.addGestureRecognizer(rotate)
            
            
            //                    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(gestureRecognizer:)))
            //                    tapRecognizer.numberOfTapsRequired = 2
            //                    planImage.addGestureRecognizer(tapRecognizer)
            
        }
        
    }
    
    func drawLines(moveX: CGFloat,moveY: CGFloat, addlinetoX: CGFloat, addlinetoY:CGFloat){
        
        let img = planImage.image
        
        
        //        autoreleasepool { ()  in
        
        UIGraphicsBeginImageContextWithOptions((img?.size)!, false, 0)
        
        img?.draw(at: CGPoint(x: 0, y: 0))
        
        // Stroke
        UIColor.black.setStroke()
        path.lineWidth = 2
        //path.stroke()
        
        path.move(to: CGPoint(x: moveX, y: moveY))
        path.addLine(to: CGPoint(x: addlinetoX, y: addlinetoY))
        
        path.stroke()
        
        self.planImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //        }
        //im = nil
        
        
    }
    
    
    //Single Tap selector
    func tapBtn(tap: UITapGestureRecognizer) {
        print("TAPPED BUTTON")
        
        viewTag = tap.view?.tag
        self.scrollView.isScrollEnabled = true
        
        if self.planImage.backgroundColor == UIColor.clear.withAlphaComponent(1.0) {
            print("TEMPo IF")
            
            customUtil.navTitle(text: "Router Setup", view: self)
            
            UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: {
                //                self.planImage.alpha = 0.6
                self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(0)
                self.tapTemp = 0
                //self.rotateTemp = 0
            }, completion: nil)
        }else {
            print("TEMPo ELSE")
            
            let routerName = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI]["router"][0]["name"].stringValue
            print("ROUTER NAME \(routerName)")
            customUtil.navTitle(text: routerName, view: self)
            
            self.scrollView.isScrollEnabled = false
            UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //self.planImage.alpha = 1.0
                self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(1.0)
                self.tapTemp = 1
            }, completion: nil)
        }
        
//        if self.planImage.backgroundColor == UIColor.clear.withAlphaComponent(1.0) {
//            print("TEMPo IF")
//            
//            customUtil.navTitle(text: "Router Setup", view: self)
//            
//            UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: {
////                self.planImage.alpha = 0.6
//                self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(0)
//                self.tapTemp = 0
//                //self.rotateTemp = 0
//            }, completion: nil)
//        }else {
//            print("TEMPo ELSE")
//            
//            let routerName = jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomI]["router"][0]["name"].stringValue
//            print("ROUTER NAME \(routerName)")
//            customUtil.navTitle(text: routerName, view: self)
//
//            self.scrollView.isScrollEnabled = false
//            UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
//                //self.planImage.alpha = 1.0
//                self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(1.0)
//                self.tapTemp = 1
//            }, completion: nil)
//        }
        
    }
    
    func rotateView(longPress: UILongPressGestureRecognizer) {
        print("ROTATE VIEW")
        //        let rotation = rotate.rotation
        let view = longPress.view
        var temp = 0
        if tapTemp == 1 {
            
            if longPress.state == UIGestureRecognizerState.began {
                if temp == 0 {
                    
                    if routerRotateAngle == 0 {
                        print("ROUTER ANGLE 90 degree")
                        view?.transform = (view?.transform)!.rotated(by: .pi/2)
                        
                        routerRotateAngle = 90
                        // jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomI]["router"][0]["rotation"].stringValue = String(routerRotateAngle)
                        
                        let RdnVal = CGFloat(atan2f(Float((view?.transform.b)!), Float((view?.transform.a)!)))
                        let DgrVal = RdnVal *  (180 / .pi)
                        print("ROTATE ANGLE  \(DgrVal)")
                        
                    } else {
                        print("ROUTER ANGLE 0 degree")
                        view?.transform = (view?.transform)!.rotated(by: -.pi/2)
                        
                        routerRotateAngle = 0
                        //jsonObj["designs"][0]["areas"][0]["designer_data"]["rooms"][roomI]["router"][0]["rotation"].stringValue = String(routerRotateAngle)
                    }
                    
                    temp = 1
                }
            }
            
            if longPress.state == UIGestureRecognizerState.ended {
                temp = 0
                
            }
        } else {
            print("TAP AND ROTATE")
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
            print("DOUBLE TAP \(CGRect(origin: origin, size: size))")
        }
    }
    
    
    //Pan Gesture Selector
    func panButton(pan:UIPanGestureRecognizer) {
        
        if viewTag == pan.view?.tag && tapTemp == 1 {
            
            print("LOC -----> \((pan.location(in: planImage)))   FRAME: \(planImage.frame.contains(pan.location(in: planImage)))")
            if planImage.frame.contains(pan.location(in: planImage)) { //Check bounds for panning
                
                let point = pan.location(in: planImage) // get pan location
                let draggedView = pan.view
                
                
                if (roomX < point.x) && (point.x  < roomX+roomWidth) && (roomY < point.y) && (point.y < roomY+roomHeight) {
                    print("PAN ENDED LOCATION : \(point) \(point.x)  \(point.y)  PLAN TAG \(String(describing: draggedView?.tag))")
                    
                    draggedView?.center = point // set View to where finger is
                    
                    roomJsonObj["router"][0]["x"].stringValue = point.x.description
                    roomJsonObj["router"][0]["y"].stringValue = point.y.description
                    
                    print("draggedView=== \(String(describing: draggedView?.tag))  POINT ----------> \(point)  \(planImage.height)")
                }else {
                    print("PAN OUT OF ROOM BOUNDRY")
                }
                
            }else{
                print("PAN NOT IN IMAGE FRAME")
            }
        }else{
            print("TAP AND PAN VIEW")
        }
        
        
    }
    
    // Scroll View Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return planImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
         roomId = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI]["id"].stringValue
         routerId = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI]["router"][0]["id"].stringValue
        
        requestRouterConfigCheck(routerId: routerId, roomId: roomId)
        
        scrollView.zoom(to: CGRect(x: roomX, y: roomY, width: roomWidth, height: roomHeight), animated: true)
        print("ZOOOOOOMING")
        if tapTemp == 1 {
            
            let routerName = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI]["router"][0]["name"].stringValue
            print("ROUTER NAME \(routerName)")
            customUtil.navTitle(text: routerName, view: self)
        } else {
            customUtil.navTitle(text: "Router Setup", view: self)
        }
        
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        customUtil.removeNavTitle(view: self)
        
        self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(0)
        planImage.subviews.forEach { $0.removeFromSuperview() }
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Reconfiguring Router location option
    @IBAction func editRouterConfigStsAction(_ sender: Any) {
        
        planImage.subviews.forEach { $0.removeFromSuperview() }
        
        let headers: [String:String] =  [
            "installer_uid" : "77",
            "email_id" : "john@brightgreen.com"
        ]
        
        let parameters: [String:Any] = [
            "router_uid" : routerId,
            "router_config_sts" : false,
            "room_uid" : roomId
        ]
        
        let urlPath = properties["Router_Config"].stringValue
        
        httpsClient.postRequest(urlPath: urlPath, headers: headers, parameters: parameters, sucCompletionHandler: { response -> Void in
            
            self.routerConfigResponse = response
            
            self.routerInstallation()
            print("editRouterConfigStsAction Sucess RESPONSE---->",response)
            
            
        }, failCompletionHandler: { response -> Void in
            
            print("editRouterConfigStsAction FAILURE RESPONSE",response)
            
            
            
        }, error: { error -> Void in
            print("editRouterConfigStsAction ERROR RESPONSE",error)
            
        })
    }
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        
        requestChangeRouterConfig(routerId: routerId, roomId: roomId, routerConfigSts: true)
        
        let  mainStory = UIStoryboard(name: "Home", bundle: nil)
        let des = mainStory.instantiateViewController(withIdentifier: "RouterDetailsViewController") as! RouterDetailsViewController
        
        //ROOM NUMBER IN WHICH ROUTER EXISTS
        des.roomNo = roomI
        
        
        let compareJson = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI] == roomJsonObj
        print("JSON COMPARE EQUAL \(compareJson)")
        
        
        if(compareJson == true){
            print("JSON COMPARISON VALUES SAME")
        }else{
            jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI] = roomJsonObj
            
            let routerX = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI]["router"][0]["x"]
            let routerY = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI]["router"][0]["y"]
            jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][roomI]["router"][0]["rotation"].stringValue = String(routerRotateAngle)
            
            
            print("ROUTER X : \(routerX)  Y:\(routerY) rotate \(routerRotateAngle)")
            
            GlobalClass.sharedInstance.setPlanJsonObject(object: jsonObj)
            print("JSON VALUE SET TO GLOBAL Class")
            do{
                print("CHANGED JSON \(jsonObj)")
                let data = try jsonObj.rawData()
                print("NEWW---> \(data)")
                try fileUtil.overwriteFileToTempFolder(dataForJson: data as AnyObject, path: "/TempPlan/\(currentSelectedPlanName).json")
                print("OVERWRITE FILE TEMP WRITE SUCCESS in file \(currentSelectedPlanName)")
            }catch{
                print("OVERWRITE Error writing data: \(error)")
            }

        }
        
        // PUSH Segue with flip animation
        UIView.beginAnimations("animation", context: nil)
        UIView.setAnimationDuration(0.6)
        self.navigationController!.pushViewController(des, animated: false)
        UIView.setAnimationTransition(UIViewAnimationTransition.flipFromRight, for: self.navigationController!.view, cache: false)
        UIView.commitAnimations()
   
        //self.performSegue(withIdentifier: "routerDetailsSegue", sender: nil)
        
    }
    
}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
