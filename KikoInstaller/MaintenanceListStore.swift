//
//  MaintenanceListStore.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 2/8/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation

class MaintenanceListStore:NSData {
    
    var maintenanceListArr = [MaintenanceListModel]()
    
    func add(list:MaintenanceListModel) {
        maintenanceListArr.append(list)
    }
    
    func add(planName: String){
        let maintenanceList = MaintenanceListModel()
        
        maintenanceList.planName = planName
        
        maintenanceListArr.append(maintenanceList)
    }
    
    func getAll() -> [MaintenanceListModel]{
        return maintenanceListArr
    }

}
