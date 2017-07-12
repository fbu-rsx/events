//
//  VisaDirectAPIManager.swift
//  events
//
//  Created by Rhian Chavez on 7/11/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import Alamofire

class VisaDirectAPIManager{
    
    static var serverTrustPolicies: [String: ServerTrustPolicy] = ["your-domain.com": .disableEvaluation]
    
    let sessionManager = Alamofire.SessionManager(
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
    )
    
    let cert = PKCS12.init(mainBundleResource: "cert", resourceType: "p12", password: "Temp2509!");
    
    init(){
        self.sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
                return (URLSession.AuthChallengeDisposition.useCredential, self.cert.urlCredential());
            }
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                return (URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!));
            }
            return (URLSession.AuthChallengeDisposition.performDefaultHandling, Optional.none);
        }
    }
    
    ///////////////////////////////////////////////////
    
    let userid = "L9MV1KNNDP6VZXN22U5W21ySfRLChcc9tCm36iALeiQaLD2Og"
    let password = "sO6F2Xgmu4sW1lIl"

 
    func pullFundsTransacrtions(){
        //let urlString = "https://sandbox.api.visa.com/visadirect/fundstransfer/v1/pullfundstransactions"
        
        
    }
    
    func multiPullFuncsTransactions(){
        
    }
    
    func pushFundsTransactions(){
        
    }
    
    func multiPushFundsTransactions(){
        
    }
    
    func reverseFundsTransactions(){
        
    }
    
    func multiReverseFundsTransactions(){
        
    }
}
