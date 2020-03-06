//
//  ContentView.swift
//  payme
//
//  Created by Doug Purdy on 2/23/20.
//  Copyright © 2020 sunyata tools. All rights reserved.
//

import SwiftUI
import XpringKit

public class WalletAction
{
    
    static func getXrpWallet(payid: String, seed: String, completion: (_ wallet: Wallet) -> Void)
    {
        let seedWallet = Wallet(seed: seed)!
        
        return completion(seedWallet)
    }
    
    static func getXrpAddressFromPayID(_ id: String, completion: @escaping (_ xAddress: String) -> Void)
    {
        var payIdUrl = id
        let isPayID = id.starts(with: "$")
        let containsPath = id.contains("/")
        
        if(isPayID)
        {
            let httpPrefix = "https://"
            let httpPostfix = "/.well-known/pay"
            
            if(!containsPath)
            {
                payIdUrl = httpPrefix + id.dropFirst() + httpPostfix
            }
            else
            {
                payIdUrl = httpPrefix + id.dropFirst()
            }
            
        }
        
        guard let url = URL(string: payIdUrl) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        request.addValue("application/xrp+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) {
            
            data, response, error in
            
            if let data = data {
                
                let decodedResponse = try! JSONDecoder().decode(XRPJSONResult.self, from: data)
                
                completion(decodedResponse.address)
                
            }
        }.resume()
        
    }
    
    struct XRPJSONResult: Codable {
        var address: String
    }
    
    static func moveXrp(source: Wallet, target: String, drops: String)
    {
        //let remoteURL = "alpha.xrp.xpring.io:50051"
        
        let remoteURL = "main.xrp.xpring.io:50051"
        
        let xpringClient = XpringClient(grpcURL: remoteURL, useNewProtocolBuffers: true)
        
        let xAddress = Utils.encode(classicAddress: target)!
        
        let udrops = UInt64(drops)!
        
        let transactionHash = try! xpringClient.send(udrops, to: xAddress, from: source)
        
        let status = try! xpringClient.getTransactionStatus(for: transactionHash)
        
        let success = status == TransactionStatus.succeeded
        
        print(success)
        
    }
    
}

struct ContentView: View {
    
    //#todo: get these from the source payid or do match?
    var methods = ["XRP", "ILP/XRP", "ILP/BTC", "ILP/ETH"]
    
    @State private var payid: String = ""
    @State private var seed: String = ""
    @State private var targetid: String = ""
    @State private var amount: String = ""
    @State private var selectedMethod = 0
    
    init()
    {
        
    }
    
    var body: some View {
        
        VStack {
            
            NavigationView {
                
                Form {
                    
                    Section(header: Text("To").bold()) {
                        TextField("💳  PayID", text: $targetid)
                            .font(Font.system(size: 20, design: .default))
                    }
                    
                    Section(header: Text("Who").bold()) {
                        VStack {
                            
                            TextField("💳 PayID ", text: $payid)
                                .font(Font.system(size: 20, design: .default))
                            
                            SecureField("🔒 Key", text: $seed)
                                .font(Font.system(size: 20, design: .default))
                        }
                    }
                    
                    
                    Section(header: Text("Amount").bold()) {
                        Picker(selection: $selectedMethod, label: Text("Method")) {
                            ForEach(0 ..< methods.count) {
                                Text(self.methods[$0])
                            }
                            
                        }
                        TextField("💰 Amount", text: $amount)
                    }
                    
                    Section(header: Text("Actions").bold()) {
                        Button(action: {
                            
                            WalletAction.getXrpWallet(payid: self.payid, seed: self.seed) {
                                
                                senderWallet in
                                
                                WalletAction.getXrpAddressFromPayID(self.targetid) {
                                    
                                    targetAddress in
                                    
                                    WalletAction.moveXrp(source: senderWallet, target: targetAddress, drops: self.amount)
                                    
                                }
                            }
                        })
                        {
                            Text("💸 Move").font(Font.system(size: 20, design: .default))
                        }
                    }
                    Section(header: Text("Results").bold()) {
                        Text("")
                    }
                }
                .navigationBarTitle(Text("$payme"))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
