//
//  IlpView.swift
//  payme
//
//  Created by Noah Kramer on 3/13/20.
//  Copyright © 2020 sunyata tools. All rights reserved.
//

import SwiftUI
import XpringKit

struct IlpView: View {
    @State private var accountID: String = ""
    @State private var accessToken: String = ""
    @State private var targetid: String = ""
    @State private var amount: String = ""
    @State private var results = ""
    @State private var isToggle : Bool = true
    
    private let ilpClient: IlpClient = IlpClient(grpcURL: "hermes-grpc-test.xpring.dev")
    
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

                            TextField("💳 Account ID ", text: $accountID)
                                .font(Font.system(size: 20, design: .default))

                            SecureField("🔒 Access Token", text: $accessToken)
                                .font(Font.system(size: 20, design: .default))
                        }
                    }
                    Section(header: Text("Where").bold()) {
                        VStack {
                            Toggle(isOn: $isToggle){
                                Text("Testnet")
                            }
                        }
                    }

                    Section(header: Text("Amount").bold()) {
                        TextField("💰 Amount", text: $amount)
                    }


                    Section(header: Text("Actions").bold()) {
                        Button(action: {
                            
                            let paymentResult = try! self.ilpClient.sendPayment(UInt64(self.amount) ?? 0, to: self.targetid, from: self.accountID, withAuthorization: self.accessToken)
                            let paymentResultString = """
                                    From: \(self.accountID)
                                    To: \(self.targetid)
                                Original Amount: \(paymentResult.originalAmount)
                                Amount Delivered: \(paymentResult.amountDelivered)
                                Amount Sent: \(paymentResult.amountSent)
                                Successful: \(paymentResult.successfulPayment)
                                """
            
                            self.results.append(paymentResultString)
                        })
                        {
                            Text("💸 Move").font(Font.system(size: 20, design: .default))
                        }.disabled(self.accessToken.isEmpty || self.targetid.isEmpty || self.amount.isEmpty)
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

struct IlpView_Previews: PreviewProvider {
    static var previews: some View {
        IlpView()
    }
}
