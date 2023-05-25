//
//  RegisterViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI

enum RegisterStatus {
    case none
    case success(String)
    case failed(String)
}

class RegisterViewModel: ObservableObject {
    @Published var registerStatus: RegisterStatus = .none
    @Published var showAlert: Bool = false
    
    func register(account: String, password: String, passwordConfirm: String, name: String) {
        
        guard password == passwordConfirm else {
            registerStatus = .failed("Passwords do not match.")
            showAlert = true
            return
        }
        
        isAccountDuplicated(account: account, completion: { [self] isDuplicated in
            if isDuplicated {
                registerStatus = .failed("Duplicated account.")
                showAlert = true
                return
            }
            print("No duplicate account")
            let player = Player(account: account, password: password, name: name, money: 1000000)
            player.savePlayer() { [self] in
                registerStatus = .success("Account registered successfully.")
                showAlert = true
            }
        })
    }
    
    func resetRegisterStatus() {
        registerStatus = .none
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
