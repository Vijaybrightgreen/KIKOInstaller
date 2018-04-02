//
//  InitViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 21/03/18.
//  Copyright © 2018 Eoxys Systems. All rights reserved.
//

import UIKit
import AWSAuthCore
import AWSAuthUI
import AWSAPIGateway
import AWSMobileClient

class InitViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        
        print("viewWillAppear")
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            AWSAuthUIViewController
                .presentViewController(with: self.navigationController!,
                                       configuration: nil,
                                       completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                        if error != nil {
                                            print("Error occurred: \(String(describing: error))")
                                        } else {
                                            print("Successfully Logged In")
                                            // Sign in successful.
                                            self.doInvokeAPI()
                                            
                                            self.performSegue(withIdentifier: "homeSegue", sender: self)
                                        }
                })
        }else{
            
            print("Goes Here")
            print("Already Logged in")
            
            self.performSegue(withIdentifier: "homeSegue", sender: self)
            //            self.doInvokeAPI()
            //            handleLogout()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
    }
    func handleLogout() {
        print("handleLogout")
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?,  error: Error?) in
                DispatchQueue.main.async(execute: {
                    print("Logged Out")
                })
                //SessionController.sharedInstance.resetSession()
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }
    }
    func doInvokeAPI() {
        print("Invoking Lambda..")
        // change the method name, or path or the query string parameters here as desired
        let httpMethodName = "POST"
        // change to any valid path you configured in the API
        let URLString = "/proxyTestFunction"
        let queryStringParameters = ["name":"Eoxys"]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "day":"Monday"
        ]
        
        let httpBody = "{ \n  " +
        "\"time\":\"Morning\"\n}"
        
        
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: httpBody)
        
        // Create a service configuration object for the region your AWS API was created in
        let serviceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1,
            credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        //        YOUR-API-CLASS-NAMEMobileHubClient.register(with: serviceConfiguration!, forKey: "CloudLogicAPIKey")
        AWSAPI_WJAE3OJA7E_ProxyTestAPIClient.register(with: serviceConfiguration!, forKey:
            "ndCcIamYVDajBXvmUB5v88WDcIxJDVLt9BDX9Ijr")
        
        
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient =
            AWSAPI_WJAE3OJA7E_ProxyTestAPIClient(forKey:
                "ndCcIamYVDajBXvmUB5v88WDcIxJDVLt9BDX9Ijr")
        
        invocationClient.invoke(apiRequest).continueWith { (
            task: AWSTask) -> Any? in
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            }
            
            // Handle successful result here
            let result = task.result!
            let responseString =
                String(data: result.responseData!, encoding: .utf8)
            print("Output is: ")
            print(responseString!)
            print(result.statusCode)
            
            return nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
