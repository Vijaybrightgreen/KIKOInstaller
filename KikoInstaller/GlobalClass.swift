//
//  GlobalClass.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/9/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation
import SwiftyJSON

class GlobalClass{
    
    //Singleton
    class var sharedInstance : GlobalClass  {
        struct Singleton {
            static let instance = GlobalClass()
        }
        return Singleton.instance
    }
    
    //Property JSON
    func propertiesJson() -> JSON {
        
        let path = Bundle.main.path(forResource: "Properties", ofType: "plist")
        let dictionary:NSDictionary = NSDictionary(contentsOfFile: path!)!
        let dictionaryJson:JSON = JSON(dictionary)
        print("dictionaryJson",dictionaryJson)
        
        let host = dictionaryJson["Host"].stringValue
        print("host",host)
        
        return dictionaryJson
    }
    
    //PLAN JSON OBJECT
    var jsonObject : JSON = JSON.null
    
    func setPlanJsonObject(object: JSON) {
        jsonObject = object
        print("JSON OBJECT SET SUCCESSFULLY IN GLOBAL CLASS")
    }
    
    func getPlanJsonObject() -> JSON {
        print("JSON OBJ GET FROM GLOBAL CLASS")
        return jsonObject
    }
   
    //User Store
    private var userStore:UserStore = UserStore()
    
    func setUserStore(user:UserStore){
        self.userStore = user
    }
    
    func getUserStore() -> UserStore{
        return self.userStore
    }
    
    //Dashboard Store
    private var dashboardStore:DashboardStore = DashboardStore()
    func setDashboardStore(data:DashboardStore){
        self.dashboardStore = data
    }
    
    func getDashboardStore() -> DashboardStore{
        return self.dashboardStore
    }
    
    
    //InstallationList Store
    private var installationListStore:InstallationListStore = InstallationListStore()
    
    func setInstallationStore(installationList:InstallationListStore){
        self.installationListStore = installationList
    }
    
    func getInstallationStore() -> InstallationListStore{
        return self.installationListStore
    }
    
    //MaintenanceList Store
    private var maintenanceListStore:MaintenanceListStore = MaintenanceListStore()
    
    func setMaintenanceStore(maintenanceList:MaintenanceListStore){
        self.maintenanceListStore = maintenanceList
    }
    
    func getMaintenanceStore() -> MaintenanceListStore{
        return self.maintenanceListStore
    }
    
    //QuotesList Store
    private var quotesListStore:QuotesListStore = QuotesListStore()
    
    func setQuotesStore(quotesList:QuotesListStore){
        self.quotesListStore = quotesList
    }
    
    func getQuotesStore() -> QuotesListStore{
        return self.quotesListStore
    }
    
    //Plan Store
    private var planStore:PlanStore = PlanStore()
    
    func setPlanStore(plan:PlanStore){
        self.planStore = plan
    }
    
    func getPlanStore() -> PlanStore{
        return self.planStore
    }
    
}
