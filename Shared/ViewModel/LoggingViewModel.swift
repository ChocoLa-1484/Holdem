//
//  LoggingViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI
import FirebaseFirestoreSwift

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
        @FirestoreQuery(collectionPath: "accounts", predicates: [
                .isEqualTo("account", account)
        ]) var players: [Player]
        print(players)
        if players.isEmpty {
            print("No documents found in the collection.")
            completion(false)
        } else {
            print("Account exist.")
            completion(true)
        }
    }
    
    func isAccountCorrect(account: String, password: String, completion: @escaping (Bool) -> Void){
        @FirestoreQuery(collectionPath: "accounts", predicates: [
                .isEqualTo("account", account)
        ]) var players: [Player]
        
        for player in players {
            if player.password == password {
                print("Sign in suceesfully.")
                print(player.id!)
                completion(true)
            } else {
                print("Password is wrong.")
                completion(false)
            }
        }
    }
}
