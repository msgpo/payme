//
//  IlpUser.swift
//  payme
//
//  Created by Noah Kramer on 3/20/20.
//  Copyright © 2020 sunyata tools. All rights reserved.
//

import Foundation
import XpringKit

class IlpUser {
    
    let accountId: String
    let accessToken: String
    let assetScale: UInt32
    
    public init(accountId: String, accessToken: String, assetScale: UInt32) {
        self.accountId = accountId
        self.accessToken = accessToken
        self.assetScale = assetScale
    }
    
    public convenience init(accountId: String, accessToken: String) {
        self.init(accountId: accountId, accessToken: accessToken, assetScale: 9)
    }
    
    
}

class IlpUserAccessService {
    private let ilpClient: IlpClient = IlpClient(grpcURL: "hermes-grpc-test.xpring.dev")
    
    func storeIlpUserToUserDefault(_ ilpUser: IlpUser) {
        UserDefaults.standard.set(ilpUser.accountId, forKey: "accountId")
        UserDefaults.standard.set(ilpUser.accessToken, forKey: "accessToken")
        
        do {
            let balance = try ilpClient.getBalance(for: ilpUser.accountId, withAuthorization: ilpUser.accessToken)
            UserDefaults.standard.set(balance.assetScale, forKey: "assetScale")
        } catch {
            print("Unable to retreive user's balance")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    
    func getIlpUserFromUserDefault() -> IlpUser? {
    
        let accountId = UserDefaults.standard.value(forKey: "accountId")
        let accessToken = UserDefaults.standard.value(forKey: "accessToken")
        let assetScale = UserDefaults.standard.value(forKey: "assetScale")
        
        if (accountId == nil || accessToken == nil || assetScale == nil) {
            print("User defaults have not been set.")
            return nil
        }
        let ilpUser = IlpUser(accountId: accountId as! String, accessToken: accessToken as! String, assetScale: assetScale as! UInt32)
        return ilpUser
    }
}
