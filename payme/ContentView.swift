//
//  ContentView.swift
//  payme
//
//  Created by Doug Purdy on 2/23/20.
//  Copyright © 2020 Humanity. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    //#todo: get these from the payid provider
    var methods = ["XRP", "ILP/XRP", "ILP/BTC", "ILP/ETH"]
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    Text("How do you want to $payme?")
                        .font(.title)
                
                    List(methods, id: \.self) { method in
                        if (method == "XRP") {
                            NavigationLink(destination: XrplView()) {
                                Text(method)
                            }
                        } else {
                            NavigationLink(destination: IlpView()) {
                                Text(method)
                            }
                        }
                    }
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
