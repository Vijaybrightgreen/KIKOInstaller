//
//  PlanStore.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 2/20/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation

class PlanStore: NSData {
    
    var planArr = [PlanModel]()
    
    func add(plan:PlanModel) {
        planArr.append(plan)
    }
    
    func add(hotspotId:String ,xVal:Int ,yVal:Int){
        let plan = PlanModel()
        
        plan.hotspotId = hotspotId
        plan.xVal = xVal
        plan.yVal = yVal
        
        planArr.append(plan)
    } 
    
   
    func getAll() -> [PlanModel]{
        return planArr
    }
}
