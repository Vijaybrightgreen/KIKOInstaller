//
//  LoginSsoViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 7/26/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Alamofire

class LoginSsoViewController: UIViewController,UIWebViewDelegate,NSURLConnectionDataDelegate {

    @IBOutlet weak var webView: UIWebView!

    var customUtil = CustomUtil()
    
    var _Authenticated : Bool!
    var _FailedRequest : URLRequest!
    
    override func viewDidLoad() {
        
        print("Balajiii")
        self.navigationItem.setHidesBackButton(true, animated:false)
        customUtil.activityIndicatorStart(view: view)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "LoginSsoViewController") as! LoginSsoViewController
        self.navigationController?.pushViewController(resultViewController, animated: true)
        
        webView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
//        let url = URL(string: "https://192.168.1.113")
        let url = URL(string: "https://www.facebook.com")
        let requestURL = URLRequest(url: url!)
        
        _Authenticated = false
        
        print("auth \(_Authenticated)")
        
        webView?.loadRequest(requestURL)
        
//        let url = URL(string: "https://192.168.1.113")
//        //print("url \(String(describing: url))", sessionManager.request(url!))
//        
//       // self.webView.loadRequest(URLRequest(url: url!))
//        
//        if let unwrappedUrl = url {
//            let request = URLRequest(url: unwrappedUrl)
//            let session = URLSession.shared
//            
////           session.request(request)
////                
////            self.webView.loadRequest(request)
//            
//            
//            
//            let task = session.dataTask(with: request) { (data,response,error) in
//                if error == nil {
//                    self.webView.loadRequest(request)
//                }else {
//                    print("Errororrr  \(error.debugDescription)")
//                }
//            }
//            
//            task.resume()
//        }
       
    }

    
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        print("shouldStartLoadWith")
        let result: Bool = _Authenticated
        if !_Authenticated {
            _FailedRequest = request
            NSURLConnection(request: request, delegate: self)
        }
        return result
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        customUtil.activityIndicatorStop(view: self.view)
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                print("Cookies \(cookie)")
            }
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        customUtil.activityIndicatorStop(view: self.view)
        
        customUtil.toast(view: self, title: "Error", message: error.localizedDescription)
    }
    
    func connection(_ connection: NSURLConnection, willSendRequestFor challenge: URLAuthenticationChallenge) {
        print("willSendRequestFor")
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let baseURL: URL? = _FailedRequest.url
            if (challenge.protectionSpace.host == baseURL?.host) {
                print("trusting connection to host \(challenge.protectionSpace.host)")
               // challenge.sender?.use(URLCredential(for: challenge.protectionSpace.serverTrust), for: challenge)
                
                challenge.sender?.use(URLCredential(trust: challenge.protectionSpace.serverTrust!), for: challenge)
            }
            else {
                print("Not trusting connection to host \(challenge.protectionSpace.host)")
            }
        }
        challenge.sender?.continueWithoutCredential(for: challenge)
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        print("didReceive")
        _Authenticated = true
        connection.cancel()
        webView.loadRequest(_FailedRequest)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = customUtil.hexStringToUIColor(hex: "4ABFA7")
        
       

    }
    

}
