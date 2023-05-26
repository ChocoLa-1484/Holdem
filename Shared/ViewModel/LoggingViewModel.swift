//
//  LoggingViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI

class LoggingViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var alert: Alert = Alert(title: Text("HI"))
    @Published var loggedPlayer: Player?
    func logging(account: String, password: String, presentationMode: Binding<PresentationMode>) {
        // 构建查询条件
        isAccountExisted(account: account) { [self] isExisted in
            guard isExisted else {
                alert = Alert(
                    title: Text("Failed."),
                    message: Text("The account does not exist."),
                    dismissButton: .default(Text("OK"))
                )
                showAlert.toggle()
                return
            }
            isAccountCorrect(account: account, password: password) { [self] isCorrect in
                guard isCorrect else {
                    alert = Alert(
                        title: Text("Failed."),
                        message: Text("The password is wrong."),
                        dismissButton: .default(Text("OK"))
                    )
                    showAlert.toggle()
                    return
                }
                alert = Alert(
                    title: Text("Success"),
                    message: Text("Sign in Susscessfully."),
                    dismissButton: .default(Text("OK")) {
                        UserManager.shared.loggedPlayer = loggedPlayer!
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                print("Player \(loggedPlayer!.name) logged in")
                showAlert.toggle()
            }
        }
    }
    
    func isAccountExisted(account: String, completion: @escaping (Bool) -> Void){
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
                    print("Account and password are not found.")
                    completion(false)
                } else {
                    print("Account exist.")
                    completion(true)
                }
            }
        }
    }
    
    func isAccountCorrect(account: String, password: String, completion: @escaping (Bool) -> Void){
        let query = db.collection("player")
            .whereField("account", isEqualTo: account)
            .whereField("password", isEqualTo: password)
        query.getDocuments { [self] (snapshot, error) in
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
                    print("Password is wrong.")
                    completion(false)
                } else {
                    print("Sign in suceesfully.")
                    let document = documents[0]
                    // 从文档中获取字段值并创建Player对象
                    let name = document.data()["name"] as? String
                    let money = document.data()["money"] as? Int
                    self.loggedPlayer = Player(account: account, password: password, name: name!, money: money!)
                    completion(true)
                }
            }
        }
    }
}
