//
//  DashboardStore.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 2/3/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation

class DashboardStore: NSData {
    var dashboardArr = [DashboardModel]()
    var temp = [[String]]()
    
    func add(stringArr: [String]) {
        temp.append(stringArr)
    }
    
    func add(dashboard:DashboardModel) {
        dashboardArr.append(dashboard)
    }
    
//    func add(installationAddressLabel:String,installationDateLabel:String, maintenanceAddressLabel:String, quotesAddressLabel:String){
//        let dashboardModel = DashboardModel()
//        dashboardModel.installationAddressLabel = installationAddressLabel
//        dashboardModel.installationDateLabel = installationDateLabel
//        dashboardModel.maintenanceAddressLabel = maintenanceAddressLabel
//        dashboardModel.quotesAddressLabel = quotesAddressLabel
//        
//        dashboardArr.append(dashboardModel)
//    }
    
    func getAll() -> [[String]] {
        return temp
    }
    
    func getAt(index:Int) -> DashboardModel!{
        return dashboardArr[index]
    }
    
    func getSize() -> Int{
        return dashboardArr.count
    }
    
//    func add(installationAddressLabel:String) {
//        let dashboardModel = DashboardModel()
//         dashboardModel.installationAddressLabel = installationAddressLabel
//        
//        dashboardArr.append(dashboardModel)
//    }
//    
//    func add(maintenanceAddressLabel:String) {
//        let dashboardModel = DashboardModel()
//        dashboardModel.maintenanceAddressLabel = maintenanceAddressLabel
//        
//        dashboardArr.append(dashboardModel)
//    }
//    
//    func add(quotesAddressLabel:String) {
//        let dashboardModel = DashboardModel()
//        dashboardModel.quotesAddressLabel = quotesAddressLabel
//        
//        dashboardArr.append(dashboardModel)
//    }
//    
//    func addAt(index:Int , installationAddressLabel:String) {
//        let dashboardModel = DashboardModel()
//        dashboardModel.installationAddressLabel = installationAddressLabel
//        
//        
//        dashboardArr[index] = dashboardModel
//    }
//    
//    func addAt(index:Int, maintenanceAddressLabel:String) {
//        let dashboardModel = DashboardModel()
//         dashboardModel.maintenanceAddressLabel = maintenanceAddressLabel
//        
//        dashboardArr[index] = dashboardModel
//    }
//    
//    func addAt(index:Int, quotesAddressLabel:String) {
//        let dashboardModel = DashboardModel()
//         dashboardModel.quotesAddressLabel = quotesAddressLabel
//        
//        dashboardArr[index] = dashboardModel
//    }
    

    
    
//    func getAll() -> [DashboardModel]{
//        return dashboardArr
//    }
}
