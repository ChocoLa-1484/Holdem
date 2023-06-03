//
//  RegisterViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI
import FirebaseFirestoreSwift

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
        
        isAccountDuplicated(account: account, completion: { isDuplicated in
            if isDuplicated {
                self.alert = Alert(
                    title: Text("Failed."),
                    message: Text("Duplicated account."),
                    dismissButton: .default(Text("OK"))
                )
                self.showAlert.toggle()
                return
            }
            print("No duplicate account")
            let player = Player(account: account, password: password, name: name, money: 1000000, host: false, online: false, ready: false)
            self.addPlayer(player: player) {
                self.alert = Alert(
                    title: Text("Success."),
                    message: Text("Account registered successfully."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                print("Account registered successfully")
                self.showAlert.toggle()
            }
        })
    }
    
    func isAccountDuplicated(account: String, completion: @escaping (Bool) -> Void){
        db.collection("players").whereField("account", isEqualTo: account).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                completion(false)
                return
            }
            if documents.isEmpty {
                print("Account and password are not found.")
                completion(false)
            } else {
                print("Account is duplicated")
                completion(true)
            }
        }
    }
    
    func addPlayer(player: Player, completion: @escaping () -> Void) {
        let playerRef = try? db.collection("players").addDocument(from: player)
        print(playerRef?.documentID ?? "00000000")
        completion()
    }
}
