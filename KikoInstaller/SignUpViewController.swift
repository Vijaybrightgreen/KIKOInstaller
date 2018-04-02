//
//  SignUpViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/3/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Material

class SignUpViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailText: TextField!
    @IBOutlet weak var passwordText: TextField!
    @IBOutlet weak var confirmPasswordText: TextField!
    @IBOutlet weak var mobileNoText: TextField!
    @IBOutlet weak var textView: UITextView!
    
    var customUtil = CustomUtil()
    var themeColor = ThemeColor()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Round ProfileImage
        profileImage.layer.borderColor = Color.white.cgColor
        profileImage.layer.borderWidth = 2
        profileImage.layer.cornerRadius = profileImage.width / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
    
   
        imagePicker.delegate = self
        
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
        passwordText.textColor = UIColor.white
        passwordText.placeholderNormalColor = themeColor.placeholderNormalColor
        passwordText.placeholderActiveColor = themeColor.placeholderActiveColor
        passwordText.dividerNormalColor = themeColor.dividerNormalColor
        passwordText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        
        passwordText.delegate = self
        
        //confirmPasswordText
        confirmPasswordText.textColor = UIColor.white
        confirmPasswordText.placeholderNormalColor = themeColor.placeholderNormalColor
        confirmPasswordText.placeholderActiveColor = themeColor.placeholderActiveColor
        confirmPasswordText.dividerNormalColor = themeColor.dividerNormalColor
        confirmPasswordText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        
        confirmPasswordText.delegate = self
        
        //mobileNoText
        mobileNoText.textColor = UIColor.white
        mobileNoText.placeholderNormalColor = themeColor.placeholderNormalColor
        mobileNoText.placeholderActiveColor = themeColor.placeholderActiveColor
        mobileNoText.dividerNormalColor = themeColor.dividerNormalColor
        mobileNoText.dividerActiveColor = customUtil.hexStringToUIColor(hex: themeColor.dividerActiveColor)
        mobileNoText.clearIconButton?.tintColor = themeColor.clearBtnTintColor
 
        mobileNoText.delegate = self
        
        //Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
      
        let linkAttributes = [NSLinkAttributeName: NSURL(string: "http://www.eoxys.com/")!,
            NSForegroundColorAttributeName: Color.white
            ] as [String : Any]
        let attributedString = NSMutableAttributedString( string: "By clicking SIGN UP, you agree to our Terms and Conditions and that you have read our Privacy Policy")
        
        attributedString.setAttributes(linkAttributes, range: NSMakeRange(38, 20))
        attributedString.setAttributes(linkAttributes, range: NSMakeRange(86, 14))
        
        self.textView.delegate = self
        self.textView.attributedText = attributedString
        self.textView.font?.withSize(13)
        self.textView.textColor = Color.white
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    //Tap gesture selector
    func tap(gesture: UITapGestureRecognizer){
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        confirmPasswordText.resignFirstResponder()
        mobileNoText.resignFirstResponder()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        profileImage.image = image
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        themeColor.createGradientLayer(view: scrollView)
        
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func closeBtn(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
  
    }
    
    
    @IBAction func choosePhotoBtn(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true

        present(imagePicker, animated: true, completion: nil)
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
