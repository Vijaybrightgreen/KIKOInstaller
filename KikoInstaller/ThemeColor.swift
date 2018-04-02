//
//  ThemeColor.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/19/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Foundation

class ThemeColor{
    
var customUtil = CustomUtil()
var gradientLayer: CAGradientLayer!
    
    //Text Field
    let placeholderNormalColor:UIColor = UIColor.white
    let placeholderActiveColor:UIColor = UIColor.white
    let dividerNormalColor:UIColor = UIColor.white
    let dividerActiveColor:String = "4ABFA7"
    let clearBtnTintColor:UIColor = UIColor.white
    
    //Navigation bar
    let navigationBarBgColor:String = "475A6B"
    let navigationBarBackColor:String = "4ABFA7"
    
    //Left bar Button
    let BarButtonColor:UIColor = UIColor.white
    
    //Home Screen Label text color
    let labelTextColor:UIColor = UIColor.white
    
    //Dashboard number color
    let dashboardNumColor:String = "5FB9B7"
    
    func createGradientLayer(view:UIView) {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [customUtil.hexStringToUIColor(hex: "5D6D7E").cgColor, customUtil.hexStringToUIColor(hex: "39454E").cgColor]
        //gradientLayer.locations = [-0.5]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        //            self.view.layer.addSublayer(gradientLayer)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

}
