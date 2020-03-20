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
    @State private var showModal: Bool = false
    @State private var assetScale: UInt32 = 9
    
    @State private var paymentResult: Org_Interledger_Stream_Proto_SendPaymentResponse = Org_Interledger_Stream_Proto_SendPaymentResponse()
    private let ilpClient: IlpClient = IlpClient(grpcURL: "hermes-grpc-test.xpring.dev")
    
    public init() {}
    
    var body: some View {
        
        VStack {
            VStack {
                Text("$payme")
                    .font(.largeTitle)
                HStack {
                    Image("interledger")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    Text("{ Testnet }")
                        
                }
            }
            
            Section(header: Text("To")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)) {
                    TextField("💳  PayID", text: $targetid)
                        .font(Font.system(size: 20, design: .default))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
            Section(header: Text("From").bold().frame(maxWidth: .infinity, alignment: .leading)) {
                VStack {

                    TextField("💳 Account ID ", text: $accountID)
                        .font(Font.system(size: 20, design: .default))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)

                    SecureField("🔒 Access Token", text: $accessToken)
                        .font(Font.system(size: 20, design: .default))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    NavigationLink(destination: RegisterIlpUserView(isUpdate: true)) {
                        Text("Change account info")
                    }
                }
            }
            
            Section(header: Text("Amount").bold().frame(maxWidth: .infinity, alignment: .leading)) {
                           TextField("💰 Amount", text: $amount)
                               .textFieldStyle(RoundedBorderTextFieldStyle())
                       }
            
            Button(action: {
                do {
                    self.paymentResult = try self.ilpClient.sendPayment(UInt64(self.amount) ?? 0, to: self.targetid, from: self.accountID, withAuthorization: self.accessToken)
                    
                    let paymentResultString =
                    """
                    - \(self.accountID) -> \(self.targetid) : \(self.paymentResult.amountSent)
                    """
                    self.showModal.toggle()
                    self.results.append(paymentResultString)
                } catch {
                    print("Failed to send payment.")
                }
            })
            {
                Text("💸 Move").font(Font.system(size: 20, design: .default))
            }
            .sheet(isPresented: $showModal) {
                IlpModalView(
                    showModal: self.$showModal,
                    accountID: self.$accountID,
                    targetID: self.$targetid,
                    paymentResult: self.$paymentResult)
            }
            .buttonStyle(NavButtonStyle(backgroundColor: Color(UIColor.systemGreen)))
            .disabled(self.accessToken.isEmpty || self.targetid.isEmpty || self.amount.isEmpty)
            
            Section(header: Text("Results").bold()) {
                Text(results)
            }
            
            Spacer()
        }
        .onAppear() {
            let userDefaults = IlpUserAccessService()
            let ilpUser = userDefaults.getIlpUserFromUserDefault()
            if (ilpUser != nil) {
                self.accountID = ilpUser!.accountId
                self.accessToken = ilpUser!.accessToken
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

struct IlpView_Previews: PreviewProvider {
    static var previews: some View {
        IlpView()
    }
}
