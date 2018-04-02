//
//  FilePlansViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/30/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON

//Area index made Global
var currentAreaIndex = 0 

class InstallationFilePlansViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var filterBtn: UIBarButtonItem!
    
    var selectedPlanName : String!
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    
    var installationModel:[InstallationListModel] = [InstallationListModel]()
    
    let areas = [JSON]()
    
    var jsonObj : JSON = JSON.null
    
    var numOfRows = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        requestInstallationList()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 75
        
        searchBtn.tintColor = themeColor.BarButtonColor
        filterBtn.tintColor = themeColor.BarButtonColor
        
    }
    
    //Get Installation list from store
    func requestInstallationList(){
        
        let installationListStore:InstallationListStore = GlobalClass.sharedInstance.getInstallationStore()
        installationModel = installationListStore.getAll()
        
        self.tableView.reloadData()
    }
    
    func getPlanFromGlobal() {
         jsonObj = GlobalClass.sharedInstance.getPlanJsonObject()
         self.tableView.reloadData()
    }
    
    func routerExists() {
        let areaCount = jsonObj["designs"][0]["areas"].count
        
        for i in 0 ..< areaCount {
            
            let roomsCount = jsonObj["designs"][0]["areas"][i]["designer_data"]["rooms"].count
            print("roomCount \(roomsCount)")
            
            for j in 0 ..< roomsCount {
                
                let routerExist = jsonObj["designs"][0]["areas"][i]["designer_data"]["rooms"][j]["router"].exists()
                
                if routerExist == true {
                    print("Router ---> Exists")
                }else {
                    print("Router NOT Exists")
                }
                
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getPlanFromGlobal()
        routerExists()
        
        print("selectedPlanName",selectedPlanName)
        customUtil.navTitle(text: selectedPlanName, view: self)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
        themeColor.createGradientLayer(view: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customUtil.removeNavTitle(view: self)
        
    }
    
    //Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let areasCount = jsonObj["designs"][0]["areas"].count
        
        print("AREAS COUNT",areasCount)
        return areasCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstallationCell", for: indexPath) as! InstallationCell
        cell.selectionStyle = UITableViewCellSelectionStyle.blue
        
        // if !self.refreshControl.isRefreshing{
        
        print("INDEXPATH : \(indexPath)")
        // print("Text")
        
        //        cell.planNameLabel.text = installationModel[indexPath.row].areaName
        //        cell.dateLabel.text = installationModel[indexPath.row].areaDate
        
        let areas = jsonObj["designs"][0]["areas"]
        print("AREAS",areas)
        
        let areaName = areas[indexPath.row]["title"].stringValue
        let areaDate = areas[indexPath.row]["modified"].stringValue
        
        print("AREA ---> NAME \(areaName) DATE : \(areaDate)")
        
        cell.planNameLabel.text = areaName
        cell.dateLabel.text = areaDate
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegue(withIdentifier: "planSegue", sender: self)
        
        print("INSTALLATION FILE PLAN didSelectRowAt")
        // PUSH Segue with flip animation
        let  mainStory = UIStoryboard(name: "Home", bundle: nil)
        let des = mainStory.instantiateViewController(withIdentifier: "ConfirmPlanViewController") as! ConfirmPlanViewController
        
        currentAreaIndex = indexPath.row
        
        
        UIView.beginAnimations("animation", context: nil)
        UIView.setAnimationDuration(0.6)
        self.navigationController!.pushViewController(des, animated: false)
        UIView.setAnimationTransition(UIViewAnimationTransition.flipFromRight, for: self.navigationController!.view, cache: false)
        UIView.commitAnimations()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    
    func isUIViewControllerPresentedAsModal() -> Bool {
        //        if((self.presentingViewController) != nil) {
        //            print("presentingViewController")
        //            return true
        //        }
        
        if(self.presentingViewController?.presentedViewController == self) {
            print("presentedViewController")
            return true
        }
        
        if(self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
            print("MODEL FROM MENU WITH NAV")
            
            return true
        }
        
        print("PUSH")
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterPopoverSegue" {
            let vc = segue.destination
            
            vc.preferredContentSize = CGSize(width: 120, height: 150)
            
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        print("Back Button")
        
        _ = self.navigationController?.popViewController(animated: true)
        
//        let res = isUIViewControllerPresentedAsModal()
//        print("RESULT \(res)")
//        if res == true {
//            self.dismiss(animated: true, completion: nil)
//        }
//        else{
//            _ = self.navigationController?.popViewController(animated: true)
//        }
        
    }
    
    @IBAction func searchBtnAction(_ sender: Any) {
         //self.performSegue(withIdentifier: "installationSearchSegue", sender: self)
    }
    
    @IBAction func filterBtnAction(_ sender: Any) {
    }
    
//    @IBAction func backBtnAction(_ sender: UIButton) {
//        print("Back Button")
//        
//        let res = isUIViewControllerPresentedAsModal()
//        print("RESULT \(res)")
//        if res == true {
//            self.dismiss(animated: true, completion: nil)
//        }
//        else{
//            _ = self.navigationController?.popViewController(animated: true)
//        }
//        
//    }
//    
//    @IBAction func searchBtnAction(_ sender: Any) {
//        self.performSegue(withIdentifier: "installationSearchSegue", sender: self)
//    }
//    
//    
//    @IBAction func filterBtnAction(_ sender: Any) {
//        self.performSegue(withIdentifier: "filterPopoverSegue", sender: self)
//    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */


}
