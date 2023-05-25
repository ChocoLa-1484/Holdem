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
    @StateObject private var loggingViewModel = LoggingViewModel()
    @State private var isShowingAlert: Bool = false
    @State private var alert: Alert = Alert(title: Text("HI"))
    @Binding var isLogged: Bool
    @Environment(\.presentationMode) var presentationMode
        
    var body: some View {
        ZStack(alignment: .topLeading) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "x.circle")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            }
            VStack {
                TextField("Account", text: $account)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button {
                    loggingViewModel.logging(account: account, password: password)
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
            .onReceive(loggingViewModel.$loggingStatus) { status in
                switch status {
                case .failed(let message):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        alert = Alert(
                            title: Text("Sign in Failed."),
                            message: Text(message),
                            dismissButton: .default(Text("OK")) {
                                loggingViewModel.resetLoggingStatus()
                            }
                        )
                        isShowingAlert.toggle()
                    }
                case .success(let message):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        alert = Alert(
                            title: Text("Sign in Successfully."),
                            message: Text(message),
                            dismissButton: .default(Text("OK")) {
                                loggingViewModel.resetLoggingStatus()
                                isLogged = true
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                        isShowingAlert.toggle()
                    }
                default:
                    break
                }
            }
            .alert(isPresented: $isShowingAlert, content: {
                alert
            })
            .padding()
        }
    }
}
// Bug：點太快
// alert寫法

struct LoggingView_Previews: PreviewProvider {
    static var previews: some View {
        LoggingView(isLogged: .constant(false))
    }
}

