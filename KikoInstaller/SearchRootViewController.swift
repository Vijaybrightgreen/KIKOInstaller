//
//  SearchRootViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/21/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class SearchRootViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var searchField: TextField!
    @IBOutlet weak var tableView: UITableView!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    
    var tfText = ""
   
    let tableSectionArr = ["Installation", "Maintenance", "Quotes"]
    
    var installationListArr = [(String,String)]()
    var maintenanceListArr = [(String,String)]()
    var quotesListArr = [(String,String)]()
    
    var installationSearchArr = [(String,String)]()
    var maintenanceSearchArr = [(String,String)]()
    var quotesSearchArr = [(String,String)]()
    
    var searchResArr = [(String,String)]()
    
    var installationModel:[InstallationListModel] = [InstallationListModel]()
    var maintenanceModel:[MaintenanceListModel] = [MaintenanceListModel]()
    var quotesModel:[QuotesListModel] = [QuotesListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        if (searchField.isFocused == true) {
//            searchField.placeholderLabel.text = ""
//        }else {
//            searchField.placeholderLabel.text = "Search"
//        }
        
        _ = searchField.becomeFirstResponder()

        
        backBtn.tintColor = themeColor.BarButtonColor
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
//        view.addGestureRecognizer(tapGesture)

        
    }
    
    
    func searchTextChanged(textField:  TextField) {
        tfText = textField.text!
        print("searchFieldTextPrinting",tfText)
        
        installationSearchArr = installationListArr.filter { installations in
            return installations.0.lowercased().contains(tfText.lowercased())
        }
        installationSearchArr = installationSearchArr.sorted(by: { $0.0 < $1.0 } )
        
    
        //        if tfText == "" {
        //            indexOfDropDown = 5
        //        } else {
        //            indexOfDropDown = 4
        //        }
        
        print("SearchResultArray",installationSearchArr)
        
        maintenanceSearchArr = maintenanceListArr.filter { maintenances in
            return maintenances.0.lowercased().contains(tfText.lowercased())
        }
        maintenanceSearchArr = maintenanceSearchArr.sorted(by: { $0.0 < $1.0 } )
        
         print("maintenanceSearchArr",maintenanceSearchArr)
        
        quotesSearchArr = quotesListArr.filter { quotes in
            return quotes.0.lowercased().contains(tfText.lowercased())
        }
        quotesSearchArr = quotesSearchArr.sorted(by: { $0.0 < $1.0 } )
         print("quotesSearchArr",quotesSearchArr)
        
        tableView.reloadData()
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSectionArr.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        
//        return tableSectionArr[section]
//    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        returnedView.backgroundColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBgColor)
        
        let label = UILabel(frame: CGRect(x: 15, y: 5, width: UIScreen.main.bounds.width, height: 20))
        label.text = tableSectionArr[section]
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.white
        returnedView.addSubview(label)
        
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("noRowsInSec \(installationModel.count)")
        var rowCount = 0
        if tfText != "" {
            if section == 0{
                rowCount = installationSearchArr.count
            }else if section == 1 {
                rowCount = maintenanceSearchArr.count
            }else{
                rowCount = quotesSearchArr.count
            }
        }else {
            
            if section == 0{
                rowCount = installationModel.count
            }else if section == 1 {
                rowCount = maintenanceModel.count
            }else{
                rowCount = quotesModel.count
            }
        }
        return rowCount
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstallationCell", for: indexPath) as! InstallationCell
        
        cell.backgroundColor = UIColor.clear
        //        cell.iconImage.backgroundColor = UIColor.white
        cell.iconImage.image = UIImage(named: "SearchFilex48.png")
        //        cell.iconImage
        
        //cell.backgroundColor?.withAlphaComponent(0.7)
        
        cell.dateLabel.textColor = UIColor.white
        cell.planNameLabel.textColor = UIColor.white
        
        cell.shareIconImage.isHidden = true
        
        print("indexPath.row \(indexPath.row)")
        
        if tfText != "" {
            switch indexPath.section {
            case 0:
                let  (planName,planDate) = installationSearchArr[indexPath.row]
                cell.planNameLabel.text = planName
                cell.dateLabel.text = planDate
                //-print("CONFIRM",installationModel[indexPath.row].confirmPlan == "1")
                
                //            if (installationModel[indexPath.row].confirmPlan == "1"){
                //                cell.confirmIconImage.image = UIImage(named: "Checkedx48")
                //            }
                print("INSTALLATION ADDRESS : \(String(describing: cell.planNameLabel.text))")
                
            case 1:
                let  (planName,planDate) = maintenanceSearchArr[indexPath.row]
                                cell.planNameLabel.text = planName
                                cell.dateLabel.text = planDate
                
                                //            if (maintenanceModel[indexPath.row].confirmPlan == "1"){
                                //                cell.confirmIconImage.image = UIImage(named: "Checkedx48")
                                //            }
                print("MAINTENANCE ADDRESS : \(String(describing:   cell.planNameLabel.text))")
                
            case 2:
                 let  (planName,planDate) = quotesSearchArr[indexPath.row]
                                cell.planNameLabel.text = planName
                                cell.dateLabel.text = planDate
                
                                //            if (quotesModel[indexPath.row].confirmPlan == "1"){
                                //                cell.confirmIconImage.image = UIImage(named: "Checkedx48")
                                //            }
                print("QUOTES ADDRESS \(String(describing: cell.planNameLabel.text))")
                
            default:
                print("CELLLL DEFAULTTTT")
                cell.planNameLabel.text = ""
            }
        }else {
            
            switch indexPath.section {
            case 0:
                cell.planNameLabel.text = installationModel[indexPath.row].planName
                cell.dateLabel.text = installationModel[indexPath.row].date
                print("CONFIRM",installationModel[indexPath.row].confirmPlan == "1")
                
                //            if (installationModel[indexPath.row].confirmPlan == "1"){
                //                cell.confirmIconImage.image = UIImage(named: "Checkedx48")
                //            }
                print("INSTALLATION ADDRESS : \(String(describing: cell.planNameLabel.text))")
                
            case 1:
                cell.planNameLabel.text = maintenanceModel[indexPath.row].planName
                cell.dateLabel.text = maintenanceModel[indexPath.row].date
                
                //            if (maintenanceModel[indexPath.row].confirmPlan == "1"){
                //                cell.confirmIconImage.image = UIImage(named: "Checkedx48")
                //            }
                print("MAINTENANCE ADDRESS : \(String(describing:   cell.planNameLabel.text))")
                
            case 2:
                cell.planNameLabel.text = quotesModel[indexPath.row].planName
                cell.dateLabel.text = quotesModel[indexPath.row].date
                
                //            if (quotesModel[indexPath.row].confirmPlan == "1"){
                //                cell.confirmIconImage.image = UIImage(named: "Checkedx48")
                //            }
                print("QUOTES ADDRESS \(String(describing: cell.planNameLabel.text))")
                
            default:
                print("CELLLL DEFAULTTTT")
                cell.planNameLabel.text = ""

            }
            
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        print("didSelectRowAt")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "InstallationCell", for: indexPath) as! InstallationCell
        
        let cellForRowAt = tableView.cellForRow(at: indexPath) as! InstallationCell
        
         let  selectedPlan = cellForRowAt.planNameLabel.text
        print("selectedPlan===>",selectedPlan!)
        
        currentSelectedPlanName = selectedPlan!
            
         requestPlan(selectedPlanName: selectedPlan!, indexPath: indexPath)
        
    }
    
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
                    
                    des.planName = selectedPlanName
                    
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
    
    func getMaintenanceList(){
        print("getMaintenanceList-->")
        let maintenanceListStore:MaintenanceListStore = GlobalClass.sharedInstance.getMaintenanceStore()
        maintenanceModel = maintenanceListStore.getAll()
        
        for maintenances in maintenanceModel {
            
            let planName = maintenances.planName
            let planDate = maintenances.date
            
            maintenanceListArr.append((planName!,planDate!))
        }
        
        self.tableView.reloadData()
    }
    
    func getQuotesList(){
        print("getQuotesList-->")
        let quotesListStore:QuotesListStore = GlobalClass.sharedInstance.getQuotesStore()
        quotesModel = quotesListStore.getAll()
        
        for quotes in quotesModel {
            
            let planName = quotes.planName
            let planDate = quotes.date
            
            quotesListArr.append((planName!,planDate!))
        }
        
        self.tableView.reloadData()
    }
    
    //Tap gesture selector
    func tap(gesture: UITapGestureRecognizer){
        searchField.resignFirstResponder()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBgColor)
        themeColor.createGradientLayer(view: view)
        
        //searchField
        searchField.placeholderNormalColor = themeColor.placeholderNormalColor
        searchField.placeholderActiveColor = themeColor.placeholderActiveColor
        searchField.dividerNormalColor = themeColor.dividerNormalColor
        searchField.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        searchField.clearIconButton?.tintColor = themeColor.clearBtnTintColor
        searchField.textColor = UIColor.white
        searchField.addTarget(self, action: #selector(searchTextChanged), for: UIControlEvents.editingChanged)
        
        searchField.placeholderVerticalOffset = 10

        
        getInstallationList()
        getMaintenanceList()
        getQuotesList()
//         let img = UIImage()
//        navigationController?.navigationBar.setBackgroundImage(img, for: .any, barMetrics: .default)
//        navigationController?.navigationBar.shadowImage = img
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchField.resignFirstResponder()
    }
   
    @IBAction func backBtnAction(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}


