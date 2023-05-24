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
                    loggingViewModel.logging(account: account, password: password) { isSuccess in
                        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
                            return
                        }
                        if isSuccess {
                            isLogged = true
                            presentationMode.wrappedValue.dismiss()
                            loggingViewModel.successResponse(on: viewController)
                        } else {
                            // 登录失败
                            loggingViewModel.failResponse(on: viewController)
                        }
                    }
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
            .padding()
        }
    }
}

struct LoggingView_Previews: PreviewProvider {
    static var previews: some View {
        LoggingView(isLogged: .constant(false))
    }
}

