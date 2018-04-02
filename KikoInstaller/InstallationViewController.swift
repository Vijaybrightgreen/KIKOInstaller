//
//  InstallationViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/25/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material
import DropDown


class InstallationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var filterBtn: UIBarButtonItem!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    var refreshControl: UIRefreshControl!
    
    let dropDown = DropDown()
    
    var installationModel:[InstallationListModel] = [InstallationListModel]()
    
    var searchResArr = [(String,String)]()
    var sortArr = [(String,String)]()
    var installationListArr = [(String,String)]()
    
    var numOfRows = 0
    
    var tfText = ""
    var sorted = false
    
    var searchField = TextField(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBtn.tintColor = UIColor.white
        searchField.dividerActiveColor = UIColor.white
        searchField.dividerNormalColor = UIColor.white
        searchField.placeholderActiveColor = UIColor.white
        searchField.placeholderNormalColor = UIColor.white
        searchField.textColor = UIColor.white
        searchField.isClearIconButtonEnabled = false
        searchField.addTarget(self, action: #selector(textfieldDataChanged), for: UIControlEvents.editingChanged)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 75
        
        searchBtn.tintColor = themeColor.BarButtonColor
        filterBtn.tintColor = themeColor.BarButtonColor
        
//        installationModel.sort(by: {$0.planName < $1.planName})
//        tableView.reloadData()
        
        //pull to refresh
//        refreshControl = UIRefreshControl.init()
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refreshControl.addTarget(self, action: #selector(self.requestInstallationList), for: UIControlEvents.valueChanged)
//        tableView.addSubview(refreshControl)
        //if installationListModel.count <= 0{
        //requestInstallationList()
        //}
       
    }

    //Get Installation list from store
    func getInstallationList(){
        print("getInstallationList-->")
        let installationListStore:InstallationListStore = GlobalClass.sharedInstance.getInstallationStore()
        installationModel = installationListStore.getAll()
        
        for installations in installationModel {
            
            let planName = installations.planName
            let planDate = installations.date
            
             installationListArr.append((planName!,planDate!))
        }
        
        self.tableView.reloadData()
    }
    
    func textfieldDataChanged(textField:  TextField) {
        tfText = textField.text!
        print("searchFieldTextPrinting",tfText)
        
        if sorted == true {
            sortArr = sortArr.filter { sort in
                return sort.0.lowercased().contains(tfText.lowercased())
            }
            sortArr = sortArr.sorted(by: { $0.0 < $1.0 } )
        }else {
            searchResArr = installationListArr.filter { installations in
                return installations.0.lowercased().contains(tfText.lowercased())
            }
            searchResArr = searchResArr.sorted(by: { $0.0 < $1.0 } )
        }
        
        
//        if tfText == "" {
//            indexOfDropDown = 5
//        } else {
//            indexOfDropDown = 4
//        }
        
        print("SearchResultArray",searchResArr)
        
        tableView.reloadData()
    }

 
    //Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sorted == true {
            print("If Sorted numberOfRowsInSection \(sortArr.count)")
            return sortArr.count
        }else {
            if tfText != "" {
                print("If numberOfRowsInSection \(searchResArr.count)")
                return searchResArr.count
            }
            else {
                print("else numberOfRowsInSection \(installationListArr.count)")
                return installationListArr.count
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstallationCell", for: indexPath) as! InstallationCell
        
        // if !self.refreshControl.isRefreshing{
        
        print("INDEXPATH : \(indexPath)")
        print("Text")
        
        if sorted == true {
             print("If cellForRowAt Sorted")
            let  (planName,planDate) = sortArr[indexPath.row]
            cell.planNameLabel.text = planName
            cell.dateLabel.text = planDate
        }else {
            if tfText != "" {
                print("If cellForRowAt")
                let  (planName,planDate) = searchResArr[indexPath.row]
                cell.planNameLabel.text = planName
                cell.dateLabel.text = planDate
                
            }
            else {
                print("else cellForRowAt")
                cell.planNameLabel.text = installationModel[indexPath.row].planName
                cell.dateLabel.text = installationModel[indexPath.row].date
                
            }
            
        }
        return cell
        
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegue(withIdentifier: "planSegue", sender: self)
        
        let fileType = installationModel[indexPath.row].type
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstallationCell", for: indexPath) as! InstallationCell
        
        if sorted == true {
            print("If didSelectRowAt Sorted")
            let  (planName,planDate) = sortArr[indexPath.row]
            cell.planNameLabel.text = planName
            currentSelectedPlanName = planName
            print("*(selectedPlanName) \(currentSelectedPlanName)")
            requestPlan(selectedPlanName: currentSelectedPlanName, indexPath: indexPath)

        }else {
            if tfText != "" {
                let  (planName,planDate) = searchResArr[indexPath.row]
                currentSelectedPlanName = planName
                print("*(selectedPlanName) \(currentSelectedPlanName)")
                requestPlan(selectedPlanName: currentSelectedPlanName, indexPath: indexPath)
            }else {
                currentSelectedPlanName = installationModel[indexPath.row].planName
                print("*(selectedPlanName) \(currentSelectedPlanName)")
                requestPlan(selectedPlanName: currentSelectedPlanName, indexPath: indexPath)
            }
        }
        
        
        
        
        
        print("INSTALLATION FILE")
//        // PUSH Segue with flip animation
//        let  mainStory = UIStoryboard(name: "Home", bundle: nil)
//        let des = mainStory.instantiateViewController(withIdentifier: "ConfirmPlanViewController") as! ConfirmPlanViewController
//        UIView.beginAnimations("animation", context: nil)
//        UIView.setAnimationDuration(0.6)
//        self.navigationController!.pushViewController(des, animated: false)
//        UIView.setAnimationTransition(UIViewAnimationTransition.flipFromRight, for: self.navigationController!.view, cache: false)
//        UIView.commitAnimations()
        
        //tableView.deselectRow(at: indexPath, animated: true)
        
        
        // } else if(fileType == "folder") {
        //            print("INSTALLATION FOLDER")
        //
        //            //self.performSegue(withIdentifier: "installationFilePlanSegue", sender: self)
        //
        //            let  mainStory = UIStoryboard(name: "Home", bundle: nil)
        //            let destination = mainStory.instantiateViewController(withIdentifier: "InstallationFilePlansViewController") as! InstallationFilePlansViewController
        //            self.navigationController!.pushViewController(destination, animated: false)
        //
        //            destination.selectedPlanName = cell.planNameLabel.text
        //
        ////            let areas = installationModel[indexPath.row].areas
        ////            print("AREAS",areas!)
        ////
        ////
        ////            for arrayValue in areas! {
        ////                let areaName = arrayValue["area_name"].stringValue
        ////                let areaDate = arrayValue["date"].stringValue
        ////                print("AREA ---> NAME \(areaName) DATE : \(areaDate)")
        ////
        ////                cell.planNameLabel.text = arrayValue["area_name"].stringValue
        ////                cell.dateLabel.text = arrayValue["area_name"].stringValue
        ////
        ////              }
        ////            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        //
        //        }
        
    }
       
           // }
    
    func requestPlan(selectedPlanName : String, indexPath : IndexPath) {
        
        print("selectedPlanName \(selectedPlanName)")
        if let path = Bundle.main.path(forResource: selectedPlanName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                //print("DDDDDADATA",data)
                //jsonObj = JSON(data: data, options: .mutableContainers, error: nil)
                
                //print("JSON \(jsonObj)")
                
                fileUtil.filesAtDoc()
                
                
                //let tempDir = fileUtil.createTempDirectory()
                //print("TEMPP DIR",tempDir!)
                
                do{
                    
                    try fileUtil.writeFileToOriginalFolder(dataForJson: data as AnyObject, path: "/OriginalPlan/\(selectedPlanName).json")
                    print("FILE ORIGINAL WRITE SUCCESS")
                }catch{
                    print("Error writing data: \(error)")
                }
                
                do{
                    
                    try fileUtil.writeFileToTempFolder(dataForJson: data as AnyObject, path: "/TempPlan/\(selectedPlanName).json")
                    print("FILE TEMP WRITE SUCCESS")
                }catch{
                    print("Error writing data: \(error)")
                }
                
                
                let fileData = fileUtil.readFile(path: "/TempPlan/\(selectedPlanName).json")
                //print("file DATA READ \(fileData)")
                
                let jsonObj = JSON(data: fileData as! Data, options: .mutableContainers, error: nil)
                //print("FILE JSON OBJ \(jsonObj)")
                
                //Set Plan Object to Global Class
                GlobalClass.sharedInstance.setPlanJsonObject(object: jsonObj)
                
                let areaCount = jsonObj["designs"][0]["areas"].count
                print("**& areaCount \(areaCount)")
                
                let  mainStory = UIStoryboard(name: "Home", bundle: nil)
                
                //Push to ConfirmPlanViewController
                if areaCount == 1 {
                    
                    print("Area Count is 1")
                    // PUSH Segue with flip animation
                    
                    let des = mainStory.instantiateViewController(withIdentifier: "ConfirmPlanViewController") as! ConfirmPlanViewController
                    
                    des.planName = currentSelectedPlanName
                    
                    UIView.beginAnimations("animation", context: nil)
                    UIView.setAnimationDuration(0.6)
                    self.navigationController!.pushViewController(des, animated: false)
                    UIView.setAnimationTransition(UIViewAnimationTransition.flipFromRight, for: self.navigationController!.view, cache: false)
                    UIView.commitAnimations()
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                } else if areaCount > 1 {
                    print("Area Count more than 1")
                    
                    // PUSH Segue
                    let des = mainStory.instantiateViewController(withIdentifier: "InstallationFilePlansViewController") as! InstallationFilePlansViewController
                    
                    des.selectedPlanName = selectedPlanName
                    
                    self.navigationController!.pushViewController(des, animated: true)
                    
                } else {
                    print("Area Count error 😡")
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
            customUtil.toast(view: self, title: "Failure", message: "Plan Not Available")
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        getInstallationList()
        
        //print("self.navigationItem.rightBarButtonItems? \(self.navigationItem.rightBarButtonItems?.count)")
        
        if self.navigationItem.rightBarButtonItems?.count == 3 {
            print("Removed SearchBar")
            self.navigationItem.rightBarButtonItems?.remove(at: 2)
        }

        navigationController?.isNavigationBarHidden = false
        
        customUtil.navTitle(text: "Installation", view: self)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
        themeColor.createGradientLayer(view: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customUtil.removeNavTitle(view: self)
        
        tfText = ""
        
        self.searchField.alpha = 0.0
        self.searchBtn.image = UIImage(named: "searchx48")
    
        sorted = false
        
        installationListArr.removeAll()
        
    }
    

    
    @IBAction func backBtnAction(_ sender: UIButton) {
        print("Back Button")

            let res = isUIViewControllerPresentedAsModal()
            print("RESULT \(res)")
            if res == true {
                self.dismiss(animated: true, completion: nil)
            }
            else{
                _ = self.navigationController?.popViewController(animated: true)
            }
       
    }
    
    @IBAction func searchBtnAction(_ sender: Any) {
        //self.performSegue(withIdentifier: "installationSearchSegue", sender: self)
        
        searchField.placeholder = "Search"
        let navField = UIBarButtonItem(customView:searchField)
        searchField.isClearIconButtonAutoHandled = true
        
        if searchBtn.image == UIImage(named: "searchx48") {
            print("searchBtn")
            customUtil.removeNavTitle(view: self)
            self.navigationItem.rightBarButtonItems?.append(navField)
            searchField.becomeFirstResponder()
            searchField.alpha = 0.0
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveLinear, animations: {
                self.searchField.alpha = 1.0
                self.searchBtn.image = UIImage(named: "CloseX48")
            },  completion: nil)
            
        }
        else if searchBtn.image == UIImage(named: "CloseX48") {
            print("CloseBtn")
            
            searchField.resignFirstResponder()
            self.searchField.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
                self.searchField.alpha = 0.0
                self.searchBtn.image = UIImage(named: "searchx48")
            },  completion: nil)
            
            
            
            self.navigationItem.rightBarButtonItems?.remove(at: 2)
            customUtil.showNavTitle(view: self)
        }

        
    }
    
    
    @IBAction func filterBtnAction(_ sender: Any) {
//        self.performSegue(withIdentifier: "filterPopoverSegue", sender: self)
        
        dropDown.topOffset = CGPoint(x: 0, y: 0)
        
        dropDown.anchorView = filterBtn
        dropDown.direction = .bottom
        dropDown.textColor = customUtil.hexStringToUIColor(hex: "686868")
        dropDown.dataSource = ["By None","By Date","By Plan Name","By Last Accessed"]
        
        
        dropDown.selectionAction = {(index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            switch index {
            case 0:
                print("Index 0")
                self.sortArr = self.installationListArr
                self.tableView.reloadData()
                
            case 1:
                print("Index 1")

            case 2:
                print("Index 2")
                print("insta))) \(self.installationListArr)")
                self.sorted = true
                self.sortArr = self.installationListArr.sorted(by: { $0.0 < $1.0 })
                print("sort \(self.sortArr)")
                self.tableView.reloadData()
            
            case 3:
                 print("Index 3")
                
            default:
                print("default")
            }
//            self.selectDeviceType.text = item
//            
//            self.selectDeviceTypeArrow.image = UIImage(named: "dropDown_Up-48")
//            
//            self.selectDeviceType.dividerColor = self.customUtil.hexStringToUIColor(hex: "686868")
//            self.selectDeviceType.dividerThickness = 0.5
            
            
        }
        
        dropDown.show()
        
        dropDown.cancelAction = { [unowned self] in
            //			// You could for example deselect the selected item
//            
//            self.selectDeviceTypeArrow.image = UIImage(named: "dropDown_Up-48")
//            
//            self.selectDeviceType.dividerColor = self.customUtil.hexStringToUIColor(hex: "686868")
//            self.selectDeviceType.dividerThickness = 0.5
            
        }
    }
 

}
