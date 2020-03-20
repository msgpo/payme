//
//  RegisterIlpUserView.swift
//  payme
//
//  Created by Noah Kramer on 3/20/20.
//  Copyright © 2020 sunyata tools. All rights reserved.
//

import SwiftUI

struct RegisterIlpUserView: View {
    
    @State private var accountId: String = ""
    @State private var accessToken: String = ""
    @State private var navigate: Bool = false
    private var isUpdate: Bool = false
    @EnvironmentObject private var userRegistered: UserRegistered
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let userDefaults: IlpUserAccessService = IlpUserAccessService()
    
    public init() {
        self.init(isUpdate: false)
    }
    
    public init(isUpdate: Bool) {
        self.isUpdate = isUpdate
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Register your ILP account")
                    .font(.largeTitle)
                HStack {
                    Image("interledger")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                }
            }
            
            Section(header: Text("Account Info").bold().frame(maxWidth: .infinity, alignment: .leading)) {
                VStack {

                    TextField("Account ID ", text: $accountId)
                        .font(Font.system(size: 20, design: .default))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)

                    TextField("Access Token", text: $accessToken)
                        .font(Font.system(size: 20, design: .default))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            if (!self.isUpdate) {
                NavigationLink(destination: IlpView(), isActive: $navigate) {
                    EmptyView()
                   }
                    Button(action: {
                        // Set user defaults
                        let ilpUser = IlpUser(accountId: self.accountId, accessToken: self.accessToken)
                        self.userDefaults.storeIlpUserToUserDefault(ilpUser)
                        self.userRegistered.set(true)
                        self.navigate = true
                    }) {
                        HStack {
                        Image("interledger")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        Text("Continue")
                            .fontWeight(.bold)
                    }
                }
                .buttonStyle(NavButtonStyle(backgroundColor: Color(UIColor.systemGreen)))
                .disabled(self.accountId.isEmpty || self.accessToken.isEmpty)
            } else {
                Button(action: {
                    // Set user defaults
                    let ilpUser = IlpUser(accountId: self.accountId, accessToken: self.accessToken)
                    self.userDefaults.storeIlpUserToUserDefault(ilpUser)
                    self.userRegistered.set(true)
                    self.navigate = true
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image("interledger")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        Text("Update")
                            .fontWeight(.bold)
                    }
                }
                .buttonStyle(NavButtonStyle(backgroundColor: Color(UIColor.systemGreen)))
                .disabled(self.accountId.isEmpty || self.accessToken.isEmpty)
            }
        }
    }
}

struct RegisterIlpUserView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterIlpUserView()
    }
}
