//
//  HttpClient.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 4/19/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


// GLOBAL SSL Custom Evaluation
let serverTrustPolicies: [String: ServerTrustPolicy] = [
     
//    "192.168.1.108" : ServerTrustPolicy.customEvaluation { (serverTrust, host) -> Bool in  //change to .1.108
//
//        return evaluateSSL(trust: serverTrust)
//
//    }
    
    //    "192.168.1.108": .pinCertificates(
    //        certificates: ServerTrustPolicy.certificates(),
    //        validateCertificateChain: false,
    //        validateHost: true
    //    )
    
    "192.168.1.108" : .disableEvaluation
    
]

let serverTrustPolicyManager = ServerTrustPolicyManager(policies: serverTrustPolicies)


let sessionManager: SessionManager = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    
    
    return SessionManager(configuration: configuration,serverTrustPolicyManager: serverTrustPolicyManager)
}()

public func evaluateSSL(trust: SecTrust!) -> Bool
{
    
    let mainBundle = Bundle.main.path(forResource: "kiko", ofType: "der")  //Change to kiko.der
    let key = NSData(contentsOfFile: mainBundle!)
    let caCertificate = [SecCertificateCreateWithData(nil, key!)!]
    print("caCertificate",caCertificate)
    
    /* We need to build our own SecTrustRef since
     the one provided by the system expects the
     host name to match */
    
    let certificateCount = SecTrustGetCertificateCount(trust)
    var trustCertificates = [SecCertificate]()
    for index in 0..<certificateCount
    {
        guard let c = SecTrustGetCertificateAtIndex(trust, index) else
        {
            return false
        }
        
        trustCertificates.append(c)
    }
    
    /* SecPolicyCreateBasicX509 is the key to
     skipping requiring a host name match */
    
    let policy = SecPolicyCreateBasicX509()
    var testTrust: SecTrust? = nil
    let testTrustResult = SecTrustCreateWithCertificates(trustCertificates as CFTypeRef, policy, &testTrust)
    if (testTrustResult != errSecSuccess || testTrust == nil)
    {
        return false
    }
    
    /* Allow only certificates signed by our CA */
    
    SecTrustSetAnchorCertificates(testTrust!,caCertificate as CFArray)
    SecTrustSetAnchorCertificatesOnly(testTrust!, true)
    
    var trustResult: SecTrustResultType = SecTrustResultType.invalid
    SecTrustEvaluate(testTrust!, &trustResult)
    
    let allow = (trustResult == SecTrustResultType.unspecified || trustResult == SecTrustResultType.proceed)
    print("allow",allow)
    return allow
}



class HttpsClient {
   
    
    let propertiesList = GlobalClass.sharedInstance.propertiesJson()
 
    func postRequest(urlPath:String, headers:HTTPHeaders, parameters: Parameters, sucCompletionHandler: @escaping (JSON) -> (), failCompletionHandler: @escaping (JSON) -> () , error: @escaping (String) -> ()) {
        
        let host = propertiesList["Host"].stringValue
        let url = host + urlPath
        print("URL**",url)
        
        sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseString { response in
            print("ALAMO RESPONSE",response)
            
            let responseString = response.result.value
            
            if responseString != nil {
                let encodedString = responseString!.data(using: String.Encoding.utf8)
                
                let responseJson = JSON(data: encodedString!)
                
                print("response JSON",responseJson)
                
                switch response.result {
                case .success:
                    print("Sucess PLAN ")
                    
                    let message = responseJson["Message"].stringValue
                    print("message",message)
                    
                    sucCompletionHandler(responseJson)
                    
                    
                case .failure:
                    print("FAILURE PLAN")
                    
                    failCompletionHandler(responseJson)
                }
                
            }else {
                print("response JSON is NIL")
                
                error("Please check the server status")
                
            }
        }
        
        
    }
    
}
