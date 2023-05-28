//
//  LoggingView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI

struct LoggingView: View {
    @State private var account: String = ""
    @State private var password: String = ""
    @ObservedObject var loggingViewModel: LoggingViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Account", text: $account)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button {
                    loggingViewModel.logging(account: account, password: password, presentationMode: presentationMode)
                } label: {
                    Text("Login!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .alert(isPresented: $loggingViewModel.showAlert, content: {
                loggingViewModel.alert
            })
            .navigationBarItems(leading: backButton)
            .padding()
            
        }
    }
    
    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .imageScale(.large)
        }
    }
}
// 未登入中
/*
struct LoggingView_Previews: PreviewProvider {
    static var previews: some View {
        LoggingView()
    }
}
*/
