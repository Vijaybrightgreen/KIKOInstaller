//
//  MaintenanceViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/25/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material
import DropDown

class MaintenanceViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterBtn: UIBarButtonItem!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    
    let dropDown = DropDown()
    
    var maintenanceModel:[MaintenanceListModel] = [MaintenanceListModel]()
    
    var searchResArr = [(String,String)]()
    var sortArr = [(String,String)]()
    var maintenanceListArr = [(String,String)]()
    
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

        
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 75
     
        // Do any additional setup after loading the view.
    }
    
    //Get Maintenance list from store
    func getMaintenanceList(){
        
        let maintenanceListStore:MaintenanceListStore = GlobalClass.sharedInstance.getMaintenanceStore()
        maintenanceModel = maintenanceListStore.getAll()
        
        for maintenances in maintenanceModel {
            
            let planName = maintenances.planName
            let planDate = maintenances.date
            
            maintenanceListArr.append((planName!,planDate!))
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
            searchResArr = maintenanceListArr.filter { maintenances in
                return maintenances.0.lowercased().contains(tfText.lowercased())
            }
            searchResArr = searchResArr.sorted(by: { $0.0 < $1.0 } )
        }
        
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
                print("else numberOfRowsInSection \(maintenanceListArr.count)")
                return maintenanceListArr.count
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
                cell.planNameLabel.text = maintenanceModel[indexPath.row].planName
                cell.dateLabel.text = maintenanceModel[indexPath.row].date
                
            }
            
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // self.performSegue(withIdentifier: "maintenancePlan", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // POPOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("VIEWWILLAPPEAR")
        
        getMaintenanceList()
        
        if self.navigationItem.rightBarButtonItems?.count == 3 {
            print("Removed SearchBar")
            self.navigationItem.rightBarButtonItems?.remove(at: 2)
        }
        
        customUtil.navTitle(text: "Maintenance", view: self)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBackColor)
        navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
        themeColor.createGradientLayer(view: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customUtil.removeNavTitle(view: self)
        
        tfText = ""
        
        
        self.searchField.alpha = 0.0
        self.searchBtn.image = UIImage(named: "searchx48")
        
        
        maintenanceListArr.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "maintenanceFilterPopoverSegue" {
            let vc = segue.destination
            
            vc.preferredContentSize = CGSize(width: 120, height: 150)
            
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
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
    
    @IBAction func backBtnAction(_ sender: Any) {
        print("Maintenance Back Button")
        //_ = self.navigationController?.popViewController(animated: true)
        let res = isUIViewControllerPresentedAsModal()
        print("RESULT \(res)")
        if res == true {
            self.dismiss(animated: true, completion: nil)
        }
        else{
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func filterBtnAction(_ sender: Any) {
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
                self.sortArr = self.maintenanceListArr
                self.tableView.reloadData()
                
            case 1:
                print("Index 1")
                
            case 2:
                print("Index 2")
                print("insta))) \(self.maintenanceListArr)")
                self.sorted = true
                self.sortArr = self.maintenanceListArr.sorted(by: { $0.0 < $1.0 })
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

    
    @IBAction func searchBtnAction(_ sender: Any) {
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
