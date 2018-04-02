//
//  EditCircuitsViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 7/8/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material

class EditCircuitsViewController: UIViewController,UIScrollViewDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    var httpsClient = HttpsClient()
    
    var planImage = UIImageView()
    
    var path = UIBezierPath()
    var lightPath = UIBezierPath()
    var selectedLightPath = UIBezierPath()
    
    var jsonObj : JSON = JSON.null
    var jsonUpdateLightItemsObj : JSON = JSON.null
    var jsonLightsInsideRoomObj : JSON = JSON.null


    let properties = GlobalClass.sharedInstance.propertiesJson()
    
    var currentswitchNo = 0
    var currentRoomNo = 0
    var currentCircuitId = ""
  
    var circuitIndex = Int()
    
    var selectedLightArr = [String]()
    var selectedCircuitId = ""
    
    var edited = false
    
    var switchView = UIView()
    var lightView = UIView()
    
    var zoomMinScale:CGFloat = 0
    
    var mappedDict = Dictionary<String,[JSON]>()
    
    override func viewDidLoad() {
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

        
        // Do any additional setup after loading the view.
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
    
    func drawLines(moveX: CGFloat,moveY: CGFloat, addlinetoX: CGFloat, addlinetoY:CGFloat){
        
        let img = planImage.image
        
        
        //        autoreleasepool { ()  in
        
        UIGraphicsBeginImageContextWithOptions((img?.size)!, false, 0)
        
        img?.draw(at: CGPoint(x: 0, y: 0))
        
        
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
    
    func drawLightLines(moveX: CGFloat,moveY: CGFloat, addlinetoX: CGFloat, addlinetoY:CGFloat){
        
        let img = planImage.image
        
        
        //        autoreleasepool { ()  in
        
        UIGraphicsBeginImageContextWithOptions((img?.size)!, false, 0)
        
        img?.draw(at: CGPoint(x: 0, y: 0))
        
        customUtil.hexStringToUIColor(hex: "F4B400").setStroke()
//        UIColor.yellow.setStroke()
        lightPath.lineWidth = 1
        //path.stroke()
        
        lightPath.move(to: CGPoint(x: moveX, y: moveY))
        lightPath.addLine(to: CGPoint(x: addlinetoX, y: addlinetoY))
       
        lightPath.stroke()
        
        self.planImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //        }
        //im = nil
        
    }
    
    func drawSelectedLightLines(moveX: CGFloat,moveY: CGFloat, addlinetoX: CGFloat, addlinetoY:CGFloat){
        
        let img = planImage.image
        
        
        //        autoreleasepool { ()  in
        
        UIGraphicsBeginImageContextWithOptions((img?.size)!, false, 0)
        
        img?.draw(at: CGPoint(x: 0, y: 0))
        
        customUtil.hexStringToUIColor(hex: "F9356B").setStroke() //pink color
        //        UIColor.yellow.setStroke()
        selectedLightPath.lineWidth = 1
        //path.stroke()
        
        selectedLightPath.move(to: CGPoint(x: moveX, y: moveY))
        selectedLightPath.addLine(to: CGPoint(x: addlinetoX, y: addlinetoY))
        
        selectedLightPath.stroke()
        
        self.planImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //        }
        //im = nil
        
    }
    
    func lightsInstallation(){
        
//        mappedDict = Dictionary<String,[JSON]>()
       
        let lightsArr = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["lights"].arrayValue
        
        let lightsCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["lights"].count
        print("lightsCount-->",lightsCount)
        
        for light in lightsArr {
            
            let lightId = light["id"].stringValue
            let circuitId = light["circuit"].stringValue
            print("lightId \(lightId) circuitId \(circuitId)")
            
            let lightX = light["x"].intValue
            let lightY = light["y"].intValue
            let lightWidth = light["width"].intValue
            let lightHeight = light["height"].intValue
            print("lightId \(lightId) \(lightX) \(lightY)")
            
            
            
            lightView = UIView(frame: CGRect(x: lightX , y: lightY, width: lightWidth, height: lightHeight))
            
            lightView.center = CGPoint(x: lightX, y: lightY)
            
            lightView.cornerRadius = (lightView.width) / 2
            
            lightView.stringTag = lightId
            
            lightView.autoresizesSubviews = true
            lightView.clipsToBounds = true
            
            print("!!currentCircuitId")
            
            //Change color for Selected light group
            if circuitId == currentCircuitId {
                lightView.backgroundColor = customUtil.hexStringToUIColor(hex: "F9356B")
                selectedLightArr.append(lightView.stringTag!)
                print("++selectedLightArr",selectedLightArr)
                
            } else {
                lightView.backgroundColor = customUtil.hexStringToUIColor(hex: "F4B400")  //yellow Color
            }
            
            
            // VIEW BLINK ANIMATION
            lightView.alpha = 0
            //var stopBlink = false
            UIView.animate(withDuration: 1.0, delay: 0.5, options: [.autoreverse, .curveEaseInOut], animations: {
                
                self.lightView.alpha = 1.0
                
            }, completion: nil)
            
            planImage.addSubview(lightView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapLight(tap:)))
            tap.delegate = self
            lightView.addGestureRecognizer(tap)
            
            //Check groupId if same append to the key
            if var val = mappedDict[circuitId] {
                
                print("@IF \(val)")
                val.append(light)
                print("iFFFF \(val)")
                mappedDict[circuitId] = val
            } else {
                
                var events = [JSON]()
                print("@ELSE \(events)")
                events.append(light)
                print("@@@@ \(events)")
                mappedDict[circuitId] = events
            }

        }
        
        print("mappedDict \(mappedDict)______________________________________________________**+")
       
    }
    
    
    func drawLightGroupLines() {
        
        let circuitIdArr = Array(mappedDict.keys)
        
        
        for circuitId in circuitIdArr {
            
            let valArrCount = mappedDict[circuitId]?.count
            let valArr = mappedDict[circuitId]
            
            print("valArrCount \(valArrCount) valArr \(String(describing: valArr))")
           
            
            for i in 0 ..< valArrCount! {
                
                if i == valArrCount!-1 {
                    print("iffiiii_...")
                } else {
                    print("elseeee//,,..")
                    
                    let lightX = CGFloat((valArr?[i]["x"].floatValue)!)
                    let lightY = CGFloat((valArr?[i]["y"].floatValue)!)
                    
                    let nextLightX = CGFloat((valArr?[i+1]["x"].floatValue)!)
                    let nextLightY = CGFloat((valArr?[i+1]["y"].floatValue)!)
                    
                    print(" +++ \(lightX) \(lightY) \(nextLightX) \(nextLightY)")
                    
                    //IF circuitId is same change line color to selected color
                    if circuitId == currentCircuitId {
                        autoreleasepool { ()  in
                            
                            drawSelectedLightLines(moveX: lightX, moveY: lightY, addlinetoX: nextLightX, addlinetoY: nextLightY)
                            
                        }
                    } else {
                        autoreleasepool { ()  in
                            
                            drawLightLines(moveX: lightX, moveY: lightY, addlinetoX: nextLightX, addlinetoY: nextLightY)
                            
                        }
                    }
                    
                   
                }
                
                
            }
            
        }
    }
    
    
//    func circuitInstallation() {
//        
//        let CircuitInSwitchArr = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["light_switches"][currentswitchNo]["circuits"].arrayValue
//        print("CircuitInSwitchArr \(CircuitInSwitchArr)")
//        
//        for circuitInSwitch in CircuitInSwitchArr {
//          
//            
//            let circuitsArr =  jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["circuits"].arrayValue
//            
//            for circuit in circuitsArr {
//                print("circuit \(circuit)")
//                
//                if circuit["id"].stringValue == circuitInSwitch.stringValue {
//                    print("Circuit Equal")
//                    let itemsArr = circuit["items"].arrayValue
//                    print("itemsArr \(itemsArr)")
//                    
//                    for item in itemsArr {
//                        let lightsInRoomArr = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["lights"].arrayValue
//                        print("lightsInRoomArr \(lightsInRoomArr)")
//                        
//                        for lightInRoom in lightsInRoomArr {
//                            
//                            if lightInRoom["id"].stringValue == item.stringValue {
//                                
//                                let lightId = lightInRoom["id"].stringValue
//                                let lightX = lightInRoom["x"].intValue
//                                let lightY = lightInRoom["y"].intValue
//                                let lightWidth = lightInRoom["width"].intValue
//                                let lightHeight = lightInRoom["height"].intValue
//                                print("lightId \(lightId) \(lightX) \(lightY)")
//                                
//                                lightView = UIView(frame: CGRect(x: lightX , y: lightY, width: lightWidth, height: lightHeight))
//                                
//                                lightView.center = CGPoint(x: lightX, y: lightY)
//                                
//                                lightView.cornerRadius = (lightView.width) / 2
//                                //lightView.tag = i + 500
//                                
//                                lightView.autoresizesSubviews = true
//                                lightView.clipsToBounds = true
//                                
//                                lightView.backgroundColor = UIColor.yellow
//                                
//                                // VIEW BLINK ANIMATION
//                                lightView.alpha = 0
//                                //var stopBlink = false
//                                UIView.animate(withDuration: 1.0, delay: 0.5, options: [.autoreverse, .curveEaseInOut], animations: {
//                                    
//                                    self.lightView.alpha = 1.0
//                                    
//                                }, completion: nil)
//
//                                planImage.addSubview(lightView)
//                
//                                
//                            }else {
//                                print("Else+++")
//                            }
//                        }
//
//                    }
//                    
//                    
//                } else {
//                    print("Circuit Not Equal")
//                }
//            }
//        }
//        
//    }
    
    func zoomIntoCurrentRoom() {
        
        let roomX = CGFloat(jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["x"].floatValue)
        let roomY = CGFloat(jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["y"].floatValue)
        let roomWidth = CGFloat(jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["width"].floatValue)
        let roomHeight = CGFloat(jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["height"].floatValue)
        
        scrollView.zoom(to: CGRect(x: roomX, y: roomY, width: roomWidth, height: roomHeight), animated: true)
    }
    
    func currentSwitchInstallation() {
        
        let rooms = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]
        
        let switchX = rooms["light_switches"][currentswitchNo]["x"].intValue
        let switchY = rooms["light_switches"][currentswitchNo]["y"].intValue
        
        let switchWidth = rooms["light_switches"][currentswitchNo]["width"].intValue
        let switchHeight = rooms["light_switches"][currentswitchNo]["height"].intValue
        
        print("Switch \(switchX)  \(switchY)  \(switchWidth)  \(switchHeight) ")
        
        switchView = UIView(frame: CGRect(x: switchX , y: switchY, width: switchWidth, height: switchHeight))
        
        switchView.center = CGPoint(x: switchX, y: switchY)
        
        switchView.cornerRadius = (switchView.width) / 2
        
        switchView.autoresizesSubviews = true
        switchView.clipsToBounds = true
        
        
        
        // VIEW BLINK ANIMATION
        switchView.alpha = 0
        //var stopBlink = false
        UIView.animate(withDuration: 1.0, delay: 0.5, options: [.autoreverse, .curveEaseInOut], animations: {
            
            self.switchView.alpha = 1.0
            
        }, completion: nil)
        
        switchView.backgroundColor = customUtil.hexStringToUIColor(hex: "F9356B").withAlphaComponent(1)
        
        planImage.addSubview(switchView)
    }
    
    // Scroll View Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return planImage
    }
    
     func tapLight(tap: UITapGestureRecognizer) {
        
        let tappedlightViewTag = (tap.view?.stringTag)!
        
        print("TaPPP Light",tappedlightViewTag)
    
        if tap.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "F4B400") { //Yellow Color F4B400
          
            tap.view?.backgroundColor = customUtil.hexStringToUIColor(hex: "F9356B")
            
            selectedLightArr.append(tappedlightViewTag)
            
            print("selectedLightArr",selectedLightArr)
            
//            for dict in mappedDict {
//                
//                let dictValArr = dict.value
//                
//                for lightId in dictValArr {
//                    
//                    let lightIdMappedDict = lightId["id"].stringValue
//                    print("lightIdMappedDict \(lightIdMappedDict)")
//                    
//                     selectedLightArr.append(lightIdMappedDict)
//                    
////                    if  tappedlightViewTag == lightIdMappedDict{
////                        
////                        selectedCircuitId = dict.key
////                        print("selectedCircuiId \(selectedCircuitId)")
////                        
////                        let selectedkeysVal = mappedDict[selectedCircuitId]!
////                        
////                        
////                        print("val-++",mappedDict[selectedCircuitId]!)
////                        
////                        
////                    }else {
////                        print("Light Group Id not available")
////                    }
//                    
//                }
//                
//            }

           
            
        }else if tap.view?.backgroundColor == customUtil.hexStringToUIColor(hex: "F9356B"){ //pink color F9356B
            
            tap.view?.backgroundColor = customUtil.hexStringToUIColor(hex: "F4B400")
        
            selectedLightArr = selectedLightArr.filter { $0 != tappedlightViewTag }
            
            print("selectedLightArr removed",selectedLightArr)
            
        }else {
            print("tap view color else")
        }
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         print("!!!!!viewWillappear!!!!!!!")
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
        
        customUtil.navTitle(text: "Edit Circuit", view: self)
        
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
        
        
        zoomIntoCurrentRoom()
        currentSwitchInstallation()
        
        lightsInstallation()
        drawLightGroupLines()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print("!!!!!viewWillDisappear!!!!")
        customUtil.removeNavTitle(view: self)
        
//        //Update the JSON OBJ with new values
//        jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["circuits"][circuitIndex]["items"] = jsonUpdateLightItemsObj
//        
//        jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["lights"] = jsonLightsInsideRoomObj
//        
//        print("()()()()()()( ",jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["circuits"][circuitIndex]["items"])
//        
//        
//        GlobalClass.sharedInstance.setPlanJsonObject(object: jsonObj)
//        
//        //Overwrite File in Local
//        do{
//            print("LIGHTS CHANGED JSON \(jsonObj)")
//            let data = try jsonObj.rawData()
//            print("LIGHTS NEWW---> \(data)")
//            try fileUtil.overwriteFileToTempFolder(dataForJson: data as AnyObject, path: "/TempPlan/\(currentSelectedPlanName).json")
//            print("LIGHTS OVERWRITE FILE TEMP WRITE SUCCESS")
//        }catch{
//            print("LIGHTS OVERWRITE Error writing data: \(error)")
//        }
//        
//        print("***********************)()*******",jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["circuits"][circuitIndex]["items"].arrayValue)

        
        self.planImage.backgroundColor = UIColor.clear.withAlphaComponent(0)
        planImage.subviews.forEach { $0.removeFromSuperview() }
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        navigationController?.view.layer.add(transition, forKey:kCATransition)
        _ = self.navigationController?.popViewController(animated: false)
          
    }

    @IBAction func confirmBtnAction(_ sender: Any) {
        
        
//        let lightsInsideRoomArr = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["lights"]
//        
//        let circuitCount = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["circuits"].count
//        let circuitArr = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["circuits"].arrayValue
//        
//        
//        
//        var circuitItemStrArr : [String] = []
//        
//        print("circuitCount",circuitCount)
//        
//        //Parsing Circuit Array
//        for i in 0 ..< circuitArr.count{
//        
//            let circuitId = circuitArr[i]["id"].stringValue
//            print("circuitId-->",circuitId)
//            print("currentCircuitId++",currentCircuitId)
//            
//            // If circuitId is same as currentCircuitId
//            if circuitId == currentCircuitId {
//                print("circuitId Mathed")
//                
//                circuitIndex = i
//                
//            }else {
//                print("No match circuitId")
//            }
//        }
//        
//        
//        print("circuitIndex====",circuitIndex)
//        
//        
//        //selectedLightArr will have the selected light id
//        for selectedLightId in selectedLightArr {
//            print("selectedLightId-- \(selectedLightId)")
//            circuitItemStrArr.append(selectedLightId)
//           
//            //Lights inside the room array also has to be updated
//            for i in 0 ..< lightsInsideRoomArr.count {
//                
//                jsonLightsInsideRoomObj = jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["lights"][i]
//                
//                
//                let lightId = jsonLightsInsideRoomObj["id"].stringValue
//                print("++_+__)_)lightId",lightId)
//                
//                if lightId == selectedLightId {
//                    
//                     jsonLightsInsideRoomObj["id"].stringValue = currentCircuitId
//                    
////                    circuitId = currentCircuitId
//                    
//                    print("circuitId___()",jsonLightsInsideRoomObj["id"].stringValue)
//                    
//                    
//                }
//                
//            }
//        }
//        
//        print("***IMPPPPP",jsonObj["designs"][0]["areas"][currentAreaIndex]["designer_data"]["rooms"][currentRoomNo]["lights"])
//        
//        circuitItemStrArr = Array(Set(circuitItemStrArr))
//        print("circuitItemStrArr++++++++++___",circuitItemStrArr)
//        
//  
//        jsonUpdateLightItemsObj = []
//      
//        //Append selected lights to JSON OBJ
//        for i  in 0 ..< circuitItemStrArr.count {
//            
//           jsonUpdateLightItemsObj.appendIfArray(json: JSON(circuitItemStrArr[i]))
//            
//        }
//    
//
//        let transition = CATransition()
//        transition.duration = 0.5
//        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromBottom
//        navigationController?.view.layer.add(transition, forKey:kCATransition)
//        _ = self.navigationController?.popViewController(animated: false)
//       
        
    }
}


//Adding "stringTag" attribute to UIView
private var stringTagHandle: UInt8 = 0
extension UIView {
   
    //use Objective C Associated Object API to add this property to UIView
    @IBInspectable public var stringTag:String? {
        get {
            if let object = objc_getAssociatedObject(self, &stringTagHandle) as? String {
                return object
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &stringTagHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //this should work in a similar way to viewWithTag:
    public func viewWithStringTag(strTag:String) -> UIView? {
        
        if stringTag == strTag {
            return self
        }
        
        for view in subviews  {
            if let matchingSubview = view.viewWithStringTag(strTag: strTag) {
                return matchingSubview
            }
        }
        
        return nil
    }
}

extension JSON{
    mutating func appendIfArray(json:JSON){
        if var arr = self.array{
            arr.append(json)
            self = JSON(arr);
        }
    }
    
    mutating func appendIfDictionary(key:String,json:JSON){
        if var dict = self.dictionary{
            dict[key] = json;
            self = JSON(dict);
        }
    }
}



