//
//  LoginViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 12/28/16.
//  Copyright © 2016 Eoxys Systems. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class LoginViewController: UIViewController,UITextFieldDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var emailText: TextField!
    @IBOutlet weak var passwordText: TextField!

    @IBOutlet weak var loginBtn: FlatButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    var userModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Balaji")
        
    
        
        //menu
//        menuBtn.target = revealViewController()
//        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 260
        
        revealViewController().bounceBackOnOverdraw = true
        revealViewController().tapGestureRecognizer()
        
        self.scrollView.delegate = self
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeRight.direction = UISwipeGestureRecognizerDirection.right
//        swipeRight.delegate = self
//        self.view.addGestureRecognizer(swipeRight)
//        
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeLeft.delegate = self
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(swipeLeft)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.leftBarButtonItem?.tintColor = Color.white
                
        //emailText
        emailText.textColor = UIColor.white
        emailText.placeholderNormalColor = themeColor.placeholderNormalColor
        emailText.placeholderActiveColor = themeColor.placeholderActiveColor
        emailText.dividerNormalColor = themeColor.dividerNormalColor
        emailText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        emailText.clearIconButton?.tintColor = themeColor.clearBtnTintColor
        
        // Do this for each UITextField
        emailText.delegate = self
        emailText.tag = 0 //Increment accordingly
        
        //passwordText
        passwordText.textColor =  UIColor.white
        passwordText.placeholderNormalColor = themeColor.placeholderNormalColor
        passwordText.placeholderActiveColor = themeColor.placeholderActiveColor
        passwordText.dividerNormalColor = themeColor.dividerNormalColor
        passwordText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        
        passwordText.delegate = self
        
        //Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        view.addGestureRecognizer(tapGesture)
        revealViewController().rightRevealToggle(animated: true)
        
        }
    
        //Change text field when return button is tapped
         func textFieldShouldReturn(_ textField: UITextField) -> Bool
        {
            // Try to find next responder
            if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
        }
    
        //Scroll to active Text Field
        func keyboardWillShow(notification:NSNotification){
            //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
            var userInfo = notification.userInfo!
            var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
            var contentInset:UIEdgeInsets = self.scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height + 10
            self.scrollView.contentInset = contentInset
        }
    
        //Scroll to active Text Field
        func keyboardWillHide(notification:NSNotification){
            let contentInset:UIEdgeInsets = UIEdgeInsets.zero
            self.scrollView.contentInset = contentInset
        }
    
        //Protocol methods for gesture recognizer
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            return true
        }
    
    //Parse JSON file
    func parseJSON(userName:String,userPassword:String){

        if let path = Bundle.main.path(forResource: "checkUserId", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = JSON(data: data)
                
                    let name = jsonObj["user"]["username"].string
                    let password = jsonObj["user"]["password"].string
                    let userId = jsonObj["param"]["userId"].string
                    let userUid = jsonObj["param"]["userUid"].string
                    let sessionId = jsonObj["param"]["sessionId"].string
                    let act = jsonObj["act"].string
                    
                    print("User Name:\(String(describing: name))")
                    print("password :\(String(describing: password))")
                    print("Session Id:\(String(describing: sessionId))")
                    print("User Uid:\(String(describing: userUid))")
                    print("User Id:\(String(describing: userId))")
                

                
                if((userName == name) && (userPassword == password) && (act == "home")){
                    if name != nil && userId != nil && userUid != nil {
                        let user = UserStore()
                        user.clearAll()
            
                        
                        user.add(userUid: userUid!, userId: userId!, userName: name!)
                        
                        GlobalClass.sharedInstance.setUserStore(user: user)
                        
                        UserDefaults.standard.set(userUid!, forKey: "userUid")
                        UserDefaults.standard.set(userId, forKey: "userId")
                        print("Values Stored")
                        
                        self.performSegue(withIdentifier: "homeSegue", sender: self)
//                        let desCont = storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
//                        self.show(desCont!, sender: nil)
                        
                    }
                    else{
                        print("Login Failed")
                        
                    }
                }
                else{
                    passwordText.detail = "Incorrect Email Address or Password"
                    passwordText.detailColor = UIColor.red
                    
                    print("Incorrect UserName or Password")
                    emailText.shake(count: 4, for: 0.25, withTranslation: -13)
                    passwordText.shake(count: 4, for: 0.25, withTranslation: -13)
                    loginBtn.shake(count: 4, for: 0.25, withTranslation: -13)
                }

            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                revealViewController().revealToggle(animated: true)
                emailText.resignFirstResponder()
                passwordText.resignFirstResponder()
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                revealViewController().rightRevealToggle(animated: true)
                emailText.resignFirstResponder()
                passwordText.resignFirstResponder()
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    //Tap gesture selector
    func tap(gesture: UITapGestureRecognizer){
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        revealViewController().rightRevealToggle(animated: true)
    }


    override func viewWillAppear(_ animated: Bool) {
        print("View Will Appear")
        emailText.text = ""
        passwordText.text = ""
        passwordText.detail = ""
        themeColor.createGradientLayer(view: view)
    }
    
    
    // Login Button Action
    @IBAction func loginBtnAction(_ sender: Any) {
        print("Login Button Clicked")
        let userName = self.emailText.text
        let password = self.passwordText.text
        
        parseJSON(userName: userName!, userPassword: password!)
    }


    @IBAction func signUpBtnAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "signupSegue",sender: self)
        }
           //self.performSegue(withIdentifier: "signupSegue", sender: self)
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("Prepare",segue.identifier!)
        
        
//        var selectedView = ""
//        let destController = segue.destination as? HomeViewController
//        destController.
    }
    

}

