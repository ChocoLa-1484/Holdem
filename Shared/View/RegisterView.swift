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
    @StateObject private var registerViewModel = RegisterViewModel()
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
                
                SecureField("Password\nConfirm", text: $passwordConfirm)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("In Game Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button {
                    registerViewModel.register(account: account, password: password, passwordConfirm: passwordConfirm, name: name, presentationMode: presentationMode)
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
            .alert(isPresented: $registerViewModel.showAlert, content: {
                registerViewModel.alert
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
/*
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(presentationMode: $)
    }
}
*/
