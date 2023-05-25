//
//  RegisterView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI

struct RegisterView: View {
    @State private var account: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var name: String = ""
    @State private var isShowingAlert: Bool = false
    @State private var alert: Alert = Alert(title: Text("HI"))
    @StateObject private var registerViewModel = RegisterViewModel()
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
            .frame(alignment: .topLeading)
            VStack {
                TextField("Account", text: $account)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password\nConfirm", text: $passwordConfirm)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("In Game Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button {
                    registerViewModel.register(account: account, password: password, passwordConfirm: passwordConfirm, name: name)
                } label: {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .onReceive(registerViewModel.$registerStatus) { status in
                switch status {
                case .failed(let message):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        alert = Alert(
                            title: Text("Registration Failed."),
                            message: Text(message),
                            dismissButton: .default(Text("OK")) {
                                registerViewModel.resetRegisterStatus()
                            }
                        )
                        isShowingAlert.toggle()
                    }
                case .success(let message):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        alert = Alert(
                            title: Text("Registration Successful"),
                            message: Text(message),
                            dismissButton: .default(Text("OK.")) {
                                registerViewModel.resetRegisterStatus()
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
/*
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(presentationMode: $)
    }
}
*/
