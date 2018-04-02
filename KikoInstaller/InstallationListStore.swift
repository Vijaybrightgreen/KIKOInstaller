//
//  InstallationListStore.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/28/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation

class InstallationListStore: NSData {
    
    var installationListArr = [InstallationListModel]()
    
    func add(list:InstallationListModel) {
        installationListArr.append(list)
    }
    
    func add(planName: String){
        let installationList = InstallationListModel()
        
        installationList.planName = planName
//        installationList.date = date
//        installationList.type = type
//        installationList.confirmPlan = confirmPlan
        
        installationListArr.append(installationList)
    }
    
    func getAll() -> [InstallationListModel]{
        return installationListArr
    }
}
