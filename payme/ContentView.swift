//
//  ContentView.swift
//  payme
//
//  Created by Doug Purdy on 2/23/20.
//  Copyright © 2020 Humanity. All rights reserved.
//

import SwiftUI

struct NavButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .cornerRadius(40)
            .foregroundColor(Color.white)
            .padding(20)
    }
        
}

struct ContentView: View {
    //#todo: get these from the payid provider
    var methods = ["XRP", "ILP/XRP", "ILP/BTC", "ILP/ETH"]
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    Text("How do you want to $payme?")
                        .font(.title)
                        .padding(.bottom, 20)
                        
            
                    ForEach(methods, id: \.self) { method in
                        Button(action: {}) {
                            VStack {
                                if (method == "XRP") {
                                    NavigationLink(destination: XrplView()) {
                                        HStack {
                                            Image("x")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                
                                            Text(method)
                                                .fontWeight(.bold)
                                        }
                                    }.buttonStyle(
                                        NavButtonStyle(
                                            backgroundColor: Color(UIColor.systemBlue)
                                        )
                                    )
                                
                                } else {
                                    NavigationLink(destination: IlpView()) {
                                        HStack {
                                            Image("interledger")
                                                .renderingMode(.original)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                            Text(method)
                                                .fontWeight(.bold)
                                        }
                                    }.buttonStyle(
                                        NavButtonStyle(
                                            backgroundColor: Color(UIColor.systemGreen)
                                        )
                                    )
                                }
                            }
                        }
                    }
                    
                    Spacer()

                }
            }
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
