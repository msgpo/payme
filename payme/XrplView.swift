//
//  XrplView.swift
//  payme
//
//  Created by Noah Kramer on 3/13/20.
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
            let httpPostfix = "/.well-known/pay?" + Float.random(in: 0 ..< 1).description
            
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
        
        request.addValue("application/xrpl-mainnet+json", forHTTPHeaderField: "Accept")
        
        
        URLSession.shared.dataTask(with: request) {
            
            data, response, error in
            
            if let data = data {
                
                let decodedResponse = try! JSONDecoder().decode(XRPJSONResult.self, from: data)
                
                completion(decodedResponse.addressDetails.address)
                
            }
        }.resume()
        
    }
    
    struct XRPJSONResult: Codable {
        var addressDetailType : String
        var addressDetails : AddressDetails
    }
    
    struct AddressDetails : Codable {
        var address : String
    }
    
    static func moveXrp(source: Wallet, target: String, drops: String) -> String
    {
        let remoteURL = "main.xrp.xpring.io:50051"
        
        let xpringClient = DefaultXRPClient(grpcURL: remoteURL)
        
        let udrops = UInt64(drops)! * 1000000
        
        let transactionHash = try! xpringClient.send(udrops, to: target, from: source)
        
        let status = try! xpringClient.getTransactionStatus(for: transactionHash)
        
        let success = status == TransactionStatus.succeeded
        
        let retval = (txn: transactionHash.description, status: success.description)
        
        return "[txn: \(retval.txn) status: \(retval.status)] \r\n"
    }
    
}

struct XrplView: View {
    
    
    @State private var payid: String = ""
    @State private var seed: String = ""
    @State private var targetid: String = ""
    @State private var amount: String = ""
    @State private var selectedMethod = 0
    @State private var results = ""
    @State private var isToggle : Bool = true
    
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
                    Section(header: Text("Where").bold()) {
                        VStack {
                            Toggle(isOn: $isToggle){
                                Text("Mainnet")
                            }
                        }
                    }

                    Section(header: Text("Amount").bold()) {

//                        Picker(selection: $selectedMethod, label: Text("Payment Method")) {
//                            ForEach(0 ..< methods.count) {
//                                Text(self.methods[$0])
//                            }
//                        }

//                        .navigationBarTitle("$payme")
                        TextField("💰 Amount", text: $amount)

                    }


                    Section(header: Text("Actions").bold()) {
                        Button(action: {

                            WalletAction.getXrpWallet(payid: self.payid, seed: self.seed) {

                                senderWallet in

                                WalletAction.getXrpAddressFromPayID(self.targetid) {

                                    targetAddress in

                                    let results = WalletAction.moveXrp(source: senderWallet, target: targetAddress, drops: self.amount)

                                    self.results.append(results)

                                }
                            }
                        })
                        {
                            Text("💸 Move").font(Font.system(size: 20, design: .default))
                        }.disabled(self.seed.isEmpty || self.targetid.isEmpty || self.amount.isEmpty)
                    }
                    Section(header: Text("Results").bold()) {
                        Text(results)
                    }
                    .navigationBarTitle(Text("$payme"))
                }

            }
        }
    }
}


struct XrplView_Previews: PreviewProvider {
    static var previews: some View {
        XrplView()
    }
}
