//
//  HomeViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/9/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material

var currentSelectedPlanName : String = ""

class HomeViewController: UIViewController,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var homeMenuBtn: UIBarButtonItem!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var homeProfilePhoto: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var installationsNum: UILabel!
    @IBOutlet weak var maintenanceNum: UILabel!
    @IBOutlet weak var quotesNum: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var window: UIWindow?
    
    var expandedSections: NSMutableSet = []
    var sectionData:[String] = ["Upcoming Installations","Upcoming Maintenance","Jobs for Quote"]
    var imgArr:[UIImage] =  [UIImage(named: "HomeGreen")!,UIImage(named: "EditGreen")!,UIImage(named: "ThumbGreen")!]
    //var addressLabelArr:[String] = ["123","456","789"]
    //var aLabelArr:[String] = ["main","tain","enance","fdf","dfgdf","dfg"]
    //var bLabelArr:[String] = ["jobd","for","quotes","dd","ee","we","yy","tt","ewr","efr"]
    var dateLabelArr:Array = [String!]()
    var iconImgArr:Array = [UIImage]()
    //let label = UILabel()
    
    let dashboardModel = DashboardModel()
    var dashboard = [DashboardModel]()
    
    
    var installation:[InstallationListModel] = [InstallationListModel]()
    var maintenance:[MaintenanceListModel] = [MaintenanceListModel]()
    var quotes:[QuotesListModel] = [QuotesListModel]()
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var fileUtil = FileUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDid Load")
        

        //Round ProfileImage
        homeProfilePhoto.isUserInteractionEnabled = true
        homeProfilePhoto.layer.borderColor = UIColor.white.cgColor
        homeProfilePhoto.layer.borderWidth = 2
        homeProfilePhoto.layer.cornerRadius = homeProfilePhoto.width / 2
        homeProfilePhoto.layer.masksToBounds = false
        homeProfilePhoto.clipsToBounds = true
        
//        profileName.text = dashboardModel.userName
//        profileName.textColor = themeColor.labelTextColor
        
        searchBtn.tintColor = themeColor.BarButtonColor
       
        
//        installationsNum.text = dashboardModel.numOfInstallation
//        maintenanceNum.text = dashboardModel.numOfMaintenance
//        quotesNum.text = dashboardModel.numOfQuotes
        
        
        
        installationsNum.textColor = customUtil.hexStringToUIColor(hex: themeColor.dashboardNumColor)
        maintenanceNum.textColor = customUtil.hexStringToUIColor(hex: themeColor.dashboardNumColor)
        quotesNum.textColor = customUtil.hexStringToUIColor(hex: themeColor.dashboardNumColor)
        
        installationsNum.isUserInteractionEnabled = true
        maintenanceNum.isUserInteractionEnabled = true
        quotesNum.isUserInteractionEnabled = true
        
        //Menu
        homeMenuBtn.target = revealViewController()
        homeMenuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 260
        
        revealViewController().bounceBackOnOverdraw = true
        revealViewController().tapGestureRecognizer()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.delegate = self
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.delegate = self
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        //Navigation Bar Button
        self.navigationItem.leftBarButtonItem?.tintColor = themeColor.BarButtonColor
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.installationViewController(gesture:)))
        installationsNum.addGestureRecognizer(tapGesture)
        
        let maintenanceTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.maintenanceViewController(gesture:)))
        maintenanceNum.addGestureRecognizer(maintenanceTapGesture)
        
        let quotesTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.quotesViewController(gesture:)))
        quotesNum.addGestureRecognizer(quotesTapGesture)
        
        let profilePhotoTap = UITapGestureRecognizer(target: self, action: #selector(self.tapProfilePhoto(gesture:)))
        homeProfilePhoto.addGestureRecognizer(profilePhotoTap)
//        view.addGestureRecognizer(tapGesture)
//        tapGesture.cancelsTouchesInView = true
//        revealViewController().rightRevealToggle(animated: true)

    }
    
    /**
     Request Dashboard data in viewWillAppear
     */
    func requestDashboardData(){
        
        if let path = Bundle.main.path(forResource: "dashboard", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = JSON(data: data, options: .mutableContainers, error: nil)
                
                let dashboardStore = DashboardStore()
                
//                var userName = jsonObj["user"]["username"].string
//                userName = "BALAJI"
               
                print("NAMMME   \(String(describing: jsonObj["user"]["username"].string))")
                
                
                dashboardModel.userName = jsonObj["user"]["username"].string
                dashboardModel.numOfInstallation = jsonObj["dashboard"]["no_of_installation"].string
                dashboardModel.numOfMaintenance = jsonObj["dashboard"]["no_of_maintenance"].string
                dashboardModel.numOfQuotes = jsonObj["dashboard"]["no_of_quotes"].string
                
                let objCount = jsonObj["object"].count
                print("OBJECT \(objCount)")
                
                dashboardStore.add(dashboard: dashboardModel)
                GlobalClass.sharedInstance.setDashboardStore(data: dashboardStore)
                print("DASHBOARD STORED")
                
                
                
                let installationListStore = InstallationListStore()
                
                let numOfRows = jsonObj["installation"].count
                
                print("ROWS \(numOfRows)")
                for i in 0 ..< numOfRows {
                    let installationListModel = InstallationListModel()
                    //let installation = jsonObj["installation"][i]
                    print("ARRNUM \(i)")
                    installationListModel.planName = jsonObj["installation"][i]["plan_name"].string
                    
                    installationListModel.date = jsonObj["installation"][i]["date"].string
                    installationListModel.confirmPlan = jsonObj["installation"][i]["confirm_plan"].string
                    installationListModel.type = jsonObj["installation"][i]["type"].string
                    
                    installationListModel.areas = jsonObj["installation"][i]["areas"].arrayValue
        
                    
//                    let areaCount = jsonObj["installation"][i]["areas"].count
//                    print("AREACOUNT",areaCount)
//                    for i in 0 ..< areaCount {
//                        print("Installation Area Name",installation["areas"][i]["area_name"].stringValue)
//                        installationListModel.areaName = installation["areas"][i]["area_name"].string
//                        installationListModel.areaDate = installation["areas"][i]["date"].string
//                        
//                        installationListStore.add(list: installationListModel)
//                    }
                    
//                                        print("planName \(planName)")
                    
                    installationListStore.add(list: installationListModel)
                }
                GlobalClass.sharedInstance.setInstallationStore(installationList: installationListStore)
                print("Installation list STORED")
                self.installation = installationListStore.getAll()
                
                self.tableView.reloadData()
                
                
                let maintenanceListStore = MaintenanceListStore()
                
                let maintenanceCount = jsonObj["maintenance"].count
                print("maintenanceCount \(maintenanceCount)")
                for i in 0 ..< maintenanceCount {
                    let maintenanceListModel = MaintenanceListModel()
                    
                    print("ARRNUM MAINTENANCE \(i)")
                    maintenanceListModel.planName = jsonObj["maintenance"][i]["plan_name"].string
                    maintenanceListModel.date = jsonObj["maintenance"][i]["date"].string
                    maintenanceListModel.confirmPlan = jsonObj["maintenance"][i]["confirm_plan"].string
                    
                    //                    print("planName \(planName)")
                    maintenanceListStore.add(list: maintenanceListModel)
                }
                GlobalClass.sharedInstance.setMaintenanceStore(maintenanceList: maintenanceListStore)
                print("MAINTENANCE list STORED")
                self.maintenance = maintenanceListStore.getAll()
                
                self.tableView.reloadData()
                
                
                let quotesListStore = QuotesListStore()
                
                let quotesCount = jsonObj["jobs_for_quotes"].count
                print("quotesCount \(quotesCount)")
                for i in 0 ..< quotesCount {
                    let quotesListModel = QuotesListModel()
                    
                    print("ARRNUM QUOTES \(i)")
                    quotesListModel.planName = jsonObj["jobs_for_quotes"][i]["plan_name"].string
                    quotesListModel.date = jsonObj["jobs_for_quotes"][i]["date"].string
                    quotesListModel.confirmPlan = jsonObj["jobs_for_quotes"][i]["confirm_plan"].string
   
                    quotesListStore.add(list: quotesListModel)
                }
                GlobalClass.sharedInstance.setQuotesStore(quotesList: quotesListStore)
                print("QUOTES list STORED")
                self.quotes = quotesListStore.getAll()
                
                self.tableView.reloadData()
                
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
 
    
    func sectionTapped(sender: UIButton){
        print("sectionTapped")
//        self.tableView.
        
        let section = sender.tag
        let shouldExpand = !expandedSections.contains(section)
        
        
        if (shouldExpand) {
            print("if \(shouldExpand)")
            expandedSections.removeAllObjects()
            expandedSections.add(section)
            
        }else{
             print("else \(shouldExpand)")
            expandedSections.removeAllObjects()
        }
        
//        self.tableView.reloadSections([section], with: .automatic)
        
        self.tableView.reloadData()
    }
    
    //Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        print("sectionData.count \(sectionData.count)")
        return sectionData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("viewForHeaderInSection")
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 85))
        headerView.backgroundColor = customUtil.hexStringToUIColor(hex: "5D6D7E")
       
        let logoImage = UIImageView.init(frame: CGRect(x: 10, y: 25, width: 25 , height: 25))
        logoImage.tintColor = customUtil.hexStringToUIColor(hex: "5FB9B7")
        logoImage.image = imgArr[section]
        
        var arrowImage = UIImageView()
        
       
        if (expandedSections.contains(section)){
            arrowImage = UIImageView.init(frame: CGRect(x: UIScreen.main.bounds.width-35, y: 27, width: 22 , height: 22))
            arrowImage.image = UIImage(named: "Upx50")
        }else {
            arrowImage = UIImageView.init(frame: CGRect(x: UIScreen.main.bounds.width-35, y: 27, width: 22, height: 22))
            arrowImage.image = UIImage(named: "Downx50")
        }
        
        let headerTitle = UILabel.init(frame: CGRect(x: 50, y: 25, width: 250, height: 28))
        headerTitle.textColor = UIColor.white
        headerTitle.text = sectionData[section]
        
        let tappedSection = UIButton.init(frame: CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: headerView.frame.size.height))
        tappedSection.addTarget(self, action: #selector(sectionTapped), for: .touchUpInside)
        tappedSection.tag = section
        
        headerView.addSubview(arrowImage)
        headerView.addSubview(logoImage)
        headerView.addSubview(headerTitle)
        headerView.addSubview(tappedSection)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 85
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("SECTION \(section)")
        if (expandedSections.contains(section)) {
            print("section : \(section)")
            switch section {
                
            case 0:
                print("CASE 0 \(installation.count)")
                return installation.count
            case 1:
                print("CASE 1 \(maintenance.count)")
                return maintenance.count
            case 2:
                print("CASE 2 \(quotes.count)")
                
                if quotes.count == 0 {
                    expandedSections.removeAllObjects()
                    self.tableView.reloadData()
                    customUtil.toast(view: self, title: "Jobs for Quote", message: "No plans available")
                }
                
                return quotes.count
            
                
            default:
                print("DEFAULT")
                return 0
            
            }
        }else {
            print("CELL ELSE")
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        print("Default Cell")
        //let dash = dashboard[indexPath.row]
        
        let dashboardStore = DashboardStore()
        print("ALLL \(dashboardStore.getAll())")
        let cell = tableView.dequeueReusableCell(withIdentifier: "expandCell") as! ExpandCell
        
        cell.backgroundColor = customUtil.hexStringToUIColor(hex: "475A6B")
        print("indexPath.row \(indexPath.row)")
        switch indexPath.section {
        case 0:
            cell.addressLabel.text = installation[indexPath.row].planName
            cell.dateLabel.text = installation[indexPath.row].date
            print("CONFIRM",installation[indexPath.row].confirmPlan == "1")
      
//            if (installation[indexPath.row].confirmPlan == "1"){
//                cell.confirmIconImg.image = UIImage(named: "Checkedx48")
//            }
            print("INSTALLATION ADDRESS : \(String(describing: cell.addressLabel.text))")
            
        case 1:
            cell.addressLabel.text = maintenance[indexPath.row].planName
            cell.dateLabel.text = maintenance[indexPath.row].date
            
//            cell.confirmIconImg.isHidden = true
//            if (maintenance[indexPath.row].confirmPlan == "1"){
//                cell.confirmIconImg.image = UIImage(named: "Checkedx48")
//            }
            print("MAINTENANCE ADDRESS : \(String(describing: cell.addressLabel.text))")
            
        case 2:
            cell.addressLabel.text = quotes[indexPath.row].planName
            cell.dateLabel.text = quotes[indexPath.row].date
            
//            cell.confirmIconImg.isHidden = true
//            if (quotes[indexPath.row].confirmPlan == "1"){
//                cell.confirmIconImg.image = UIImage(named: "Checkedx48")
//            }
            print("QUOTES ADDRESS \(String(describing: cell.addressLabel.text))")
            
        default:
            print("CELLLL DEFAULTTTT")
            cell.addressLabel.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // PUSH Segue with flip animation
        print("TABLE didSelectRowAt ")
        
//        let  mainStory = UIStoryboard(name: "Home", bundle: nil)
//        let des = mainStory.instantiateViewController(withIdentifier: "ConfirmPlanViewController") as! ConfirmPlanViewController
//        UIView.beginAnimations("animation", context: nil)
//        UIView.setAnimationDuration(0.6)
//        self.navigationController!.pushViewController(des, animated: false)
//        UIView.setAnimationTransition(UIViewAnimationTransition.flipFromRight, for: self.navigationController!.view, cache: false)
//        UIView.commitAnimations()
//        let cell = tableView.dequeueReusableCell(withIdentifier: "expandCell", for: indexPath) as! ExpandCell
        
        
//        let cell = tableView.cellForRow(at: indexPath!)
        
        let cell:ExpandCell = tableView.cellForRow(at: indexPath) as! ExpandCell
        
        let selectedPlanName = cell.addressLabel.text!
        
        print("Home selectedPlanName \(selectedPlanName)")
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
                    currentSelectedPlanName = selectedPlanName
                    
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
                    currentSelectedPlanName = selectedPlanName
                    
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
        
        
//        tableView.deselectRow(at: indexPath, animated: true)

    }

//    //Tap gesture selector
//    func tap(gesture: UITapGestureRecognizer){
//        
//        revealViewController().rightRevealToggle(animated: true)
//    }
    
    func installationViewController(gesture: UITapGestureRecognizer){
        print("installationViewController")
        
        
        self.performSegue(withIdentifier: "installationSegue", sender: UILabel())
      
    }
    
    func maintenanceViewController(gesture: UITapGestureRecognizer){
        print("maintenanceViewController")
        
        self.performSegue(withIdentifier: "maintenanceSegue", sender: UILabel())
        
    }
    
    func quotesViewController(gesture: UITapGestureRecognizer){
        print("quotesViewController")
        
        //customUtil.toast(view: self, title: "Quotes", message: "No plans available")
        
        self.performSegue(withIdentifier: "quotesSegue", sender: UILabel())
        
    }
    
    func tapProfilePhoto(gesture: UITapGestureRecognizer){
        print("tapProfilePhoto")
        
//        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
//        let desController = mainStoryboard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
//        self.present(desController, animated: true, completion: nil)
//         self.performSegue(withIdentifier: "accountSegue", sender: nil)
        
        DispatchQueue.main.async {
            // push view controller but animate modally
            let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
            
            let navigationController = self.navigationController
            
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromTop
            navigationController?.view.layer.add(transition, forKey: nil)
            navigationController?.pushViewController(vc, animated: false)

        }
        
    }
    
    //Protocol methods for gesture recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                revealViewController().revealToggle(animated: true)
                print("Home Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Home Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                revealViewController().rightRevealToggle(animated: true)
                print("Home Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Home Swiped up")
            default:
                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        print("VIEWWILLAPPEAR")
        
        requestDashboardData()
        
        profileName.text = dashboardModel.userName
        profileName.textColor = themeColor.labelTextColor
        
        installationsNum.text = dashboardModel.numOfInstallation
        maintenanceNum.text = dashboardModel.numOfMaintenance
        quotesNum.text = dashboardModel.numOfQuotes
        
       customUtil.navTitle(text: "Home", view: self)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBgColor)
        themeColor.createGradientLayer(view: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("HOME viewWillDisappear")
        customUtil.removeNavTitle(view: self)
        expandedSections.removeAllObjects()
    }
    
//    @IBAction func logoutBtnAction(_ sender: Any) {
//        
//        //Alert to logout
//        let refreshAlert = UIAlertController(title: "Logout", message: "Do you wish to logout?", preferredStyle: UIAlertControllerStyle.alert)
//        
//        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
//            print("Handle YES logic here")
//            
//            //Clear authentication
//            UserDefaults.standard.set(nil, forKey: "userId")
//            UserDefaults.standard.set(nil, forKey: "userUid")
//            print("Authentication Clear")
//            
//            self.dismiss(animated: true, completion: nil)
//            
//        }))
//        
//        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
//            print("Handle No Logic here")
//            //refreshAlert.dismiss(animated: true, completion: nil)
//        }))
//        
//        present(refreshAlert, animated: true, completion: nil)
//        
//       
//    }
    
//    @IBAction func logoutBtnAction(_ sender: Any) {
//        //Clear authentication
//        UserDefaults.standard.set(nil, forKey: "userId")
//        UserDefaults.standard.set(nil, forKey: "userUid")
//        print("Authentication Clear")
//        
//        dismiss(animated: true, completion: nil)
//    }

    @IBAction func searchBtnAction(_ sender: Any) {
        
        let  mainStory = UIStoryboard(name: "Home", bundle: nil)
        let des = mainStory.instantiateViewController(withIdentifier: "SearchRootViewController") as! SearchRootViewController
        self.navigationController!.pushViewController(des, animated: false)

        
//        window = UIWindow(frame: Screen.bounds)
//        window!.rootViewController = SearchViewController(rootViewController: UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "SearchRootViewController"))
//        window!.makeKeyAndVisible()
        
        //self.performSegue(withIdentifier: "searchSegue", sender: self)
        
    }

    // MARK: - Navigation
     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         print("Home Controller prepare func")
    }
 

}
