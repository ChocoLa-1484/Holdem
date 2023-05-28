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
            let player = Player(account: account, password: password, name: name, money: 1000000, host: false)
            addPlayer(player: player) {
                self.alert = Alert(
                    title: Text("Success."),
                    message: Text("Account registered successfully."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                self.showAlert.toggle()
            }
        })
    }
    
    func isAccountDuplicated(account: String, completion: @escaping (Bool) -> Void){
        db.collection("players").whereField("account", isEqualTo: account).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                completion(false)
                return
            }
            
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
    
    func modifyPlayer(player: Player) {
        do {
            try db.collection("players").document(player.id ?? "").setData(from: player)
        } catch  {
            print(error)
        }
    }
    
    func addPlayer(player: Player, completion: @escaping () -> Void) {
        do {
            _ = try db.collection("players").addDocument(from: player)
            completion()
        } catch {
            print(error)
        }
    }
    
    func deletePlayer(player: Player) {
        let documentReference = db.collection("players").document(player.id ?? "")
        documentReference.delete()
    }
    /*
    func fetchPlayer(){
        let playerRef = db.collection("players")
        playerRef.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching subcollection documents: \(error?.localizedDescription ?? "")")
                return
            }
            
            for document in snapshot.documents {
                guard let player = try? document.data(as: Player.self) else { break }
                self.players.append(player)
            }
        }
    }*/
}
