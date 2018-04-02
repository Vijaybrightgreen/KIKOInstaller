//
//  AccountViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 7/31/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Material

class AccountViewController: UIViewController,UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: TextField!
    @IBOutlet weak var emailText: TextField!
    @IBOutlet weak var passwordText: TextField!
    @IBOutlet weak var mobileNoText: TextField!
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Round ProfileImage
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        
        imagePicker.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        backBtn.tintColor = themeColor.BarButtonColor
        
        //NameText
        nameText.text = "john"
        nameText.textColor = UIColor.white
        nameText.placeholderNormalColor = themeColor.placeholderNormalColor
        nameText.placeholderActiveColor = themeColor.placeholderActiveColor
        nameText.dividerNormalColor = themeColor.dividerNormalColor
        nameText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        
        //emailText
        emailText.text = "john@bg.com"
        emailText.textColor = UIColor.white
        emailText.placeholderNormalColor = themeColor.placeholderNormalColor
        emailText.placeholderActiveColor = themeColor.placeholderActiveColor
        emailText.dividerNormalColor = themeColor.dividerNormalColor
        emailText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        
        //PasswordText
        passwordText.text = "*****"
        passwordText.textColor = UIColor.white
        passwordText.placeholderNormalColor = themeColor.placeholderNormalColor
        passwordText.placeholderActiveColor = themeColor.placeholderActiveColor
        passwordText.dividerNormalColor = themeColor.dividerNormalColor
        passwordText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        
        //MobileNoText
        mobileNoText.text = "9876543210"
        mobileNoText.textColor = UIColor.white
        mobileNoText.placeholderNormalColor = themeColor.placeholderNormalColor
        mobileNoText.placeholderActiveColor = themeColor.placeholderActiveColor
        mobileNoText.dividerNormalColor = themeColor.dividerNormalColor
        mobileNoText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
//        let image = info[UIImagePickerControllerOriginalImage]
//        
//        imageView.image = image as? UIImage
//        
//        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Image Tap")
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        print("Account VIEWWILLAPPEAR")
      
        customUtil.navTitle(text: "Account", view: self)
        self.navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBgColor)
        themeColor.createGradientLayer(view: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Account viewWillDisappear")
        customUtil.removeNavTitle(view: self)
    }

    @IBAction func backBtnAction(_ sender: Any) {
        let res = isUIViewControllerPresentedAsModal()
        print("RESULT \(res)")
        if res == true {
            print("123 if")
            self.dismiss(animated: true, completion: nil)
        }
        else{
            print("456 else ")
            
            //Close Push Segue with animation
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionReveal
            transition.subtype = kCATransitionFromBottom
            navigationController?.view.layer.add(transition, forKey: nil)
            _ = navigationController?.popViewController(animated: false)
            
        }

//        self.dismiss(animated: true, completion: nil)

    }
   
    
    @IBAction func saveBtnAction(_ sender: Any) {
        
    }
    
}
