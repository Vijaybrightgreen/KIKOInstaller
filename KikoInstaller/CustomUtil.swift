//
//  CustomUtil.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/3/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Foundation


class CustomUtil {
    
    let label = UILabel()
    
    var fieldText = ""
    
    //HEX Code to UIColor
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func navTitle(text: String,view: UIViewController){
            if let navBar = view.navigationController?.navigationBar {
                
                print("Called!!!")
                
                label.text = text
                fieldText = text
                
                label.textColor = UIColor.white
                label.font = UIFont(name: "Roboto-Bold", size: 17)
                label.frame = CGRect(x: 0, y: 30, width: 250, height: 21)
                label.center = CGPoint(x: navBar.center.x+10, y: navBar.center.y-20)
                navBar.addSubview(label)
                
//                let leftItem = UIBarButtonItem(customView: label)
//                view.navigationItem.leftBarButtonItems?.insert(leftItem, at: 1)
                
            }
        }
    
    func showNavTitle(view: UIViewController) {
        
        navTitle(text: fieldText, view: view)
        
    }
    
    func removeNavTitle(view: UIViewController){
//        let leftItem = UIBarButtonItem(customView: label)
//        view.navigationItem.leftBarButtonItems?.remove(at: 1)
         label.removeFromSuperview()
    }
    
    // set the UIAlerController property
    var alert: UIAlertController!
    
    //Alert
    func toast(view:UIViewController ,title: String, message: String) -> Void
    {
        
        alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: UIAlertControllerStyle.alert)
        
        view.present(alert, animated: true, completion: nil)
        // let cancelAction = UIAlertAction(title: "OK",style: .cancel, handler: nil)
        
        //alert.addAction(cancelAction)
        
        let timeToDisappear = DispatchTime.now() + 1.5
 
        DispatchQueue.main.asyncAfter(deadline: timeToDisappear){
            // your code with delay
            self.alert.dismiss(animated: true, completion: nil)
        }
        
        //self.present(alert, animated: true, completion: nil)
        
        // setting the NSTimer to close the alert after timeToDissapear seconds.
        //_ = Timer.scheduledTimer(timeInterval: Double(timeToDissapear), target: self, selector: Selector("dismissAlert"), userInfo: nil, repeats: false)
    }

    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingView: UIView = UIView()
    
    func activityIndicatorStart(view:UIView) {
        print("Activity Indicator Start")
        
        view.opacity = 0.7
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.lightGray
        // loadingView.alpha = 0.7
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        view.addSubview(loadingView)
        
        activityIndicator.center = self.loadingView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func activityIndicatorStop(view:UIView) {
        print("Activity Indicator Stop")
        
        view.opacity = 1.0
        
        activityIndicator.stopAnimating()
        loadingView.removeFromSuperview()
        
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }
    
}

public extension UIView {
    
    func shake(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.repeatCount = count ?? 2
        animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? -5
        layer.add(animation, forKey: "shake")
    }
    
    
}


