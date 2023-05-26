//
//  RegisterViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI

class RegisterViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var alert: Alert = Alert(title: Text("HI"))
    
    func register(account: String, password: String, passwordConfirm: String, name: String, presentationMode: Binding<PresentationMode>) {
        
        guard password == passwordConfirm else {
            alert = Alert(
                title: Text("Failed."),
                message: Text("Passwords do not match."),
                dismissButton: .default(Text("OK"))
            )
            showAlert.toggle()
            return
        }
        
        isAccountDuplicated(account: account, completion: { [self] isDuplicated in
            if isDuplicated {
                alert = Alert(
                    title: Text("Failed."),
                    message: Text("Duplicated account."),
                    dismissButton: .default(Text("OK"))
                )
                showAlert.toggle()
                return
            }
            print("No duplicate account")
            let player = Player(account: account, password: password, name: name, money: 1000000)
            player.savePlayer() { [self] in
                alert = Alert(
                    title: Text("Success."),
                    message: Text("Account registered successfully."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                showAlert.toggle()
            }
        })
    }
    
    func isAccountDuplicated(account: String, completion: @escaping (Bool) -> Void){
        let query = db.collection("player").whereField("account", isEqualTo: account)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                // 查询过程中出现错误
                print("Failed to get collection documents: \(error.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else {
                    print("No documents found in the collection.")
                    completion(false)
                    return
                }
                if documents.isEmpty {
                    print("Account and password not found.")
                    completion(false)
                } else {
                    print("Account is duplicated")
                    completion(true)
                }
            }
        }
    }
}
