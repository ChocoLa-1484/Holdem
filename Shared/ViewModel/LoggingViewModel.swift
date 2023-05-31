//
//  LoggingViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI
import FirebaseFirestoreSwift
import Combine

class LoggingViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var showAlert: Bool = false
    @Published var alert: Alert = Alert(title: Text("HI"))
    @Published var isLogged: Bool = false
    
    init() {
        UserManager.shared.observeIsLogged { [weak self] isLogged in
            self?.isLogged = isLogged
        }
    }
    
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
                        message: Text("Password is wrong."),
                        dismissButton: .default(Text("OK"))
                    )
                    showAlert.toggle()
                    return
                }
                
                alert = Alert(
                    title: Text("Success"),
                    message: Text("Sign in Susscessfully."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                showAlert.toggle()
            }
        }
    }
    
    func isAccountExisted(account: String, completion: @escaping (Bool) -> Void){
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
                print("Account is not found.")
                completion(false)
            } else {
                print("Account is found")
                completion(true)
            }
        }
    }
    
    func isAccountCorrect(account: String, password: String, completion: @escaping (Bool) -> Void){
        db.collection("players")
            .whereField("account", isEqualTo: account)
            .whereField("password", isEqualTo: password).getDocuments { (snapshot, error) in
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
                print("Password is wrong")
                completion(false)
            } else {
                print("Password is correct")
                guard var player = try? documents[0].data(as: Player.self) else {
                    print("Can't transform data")
                    completion(false)
                    return
                }
                player.handCard = nil
                player.roomID = nil
                player.bet = nil
                player.number = nil
                player.host = false
                player.ready = false
                player.online = true
                UserManager.shared.setLoggedPlayer(player)
                self.modifyPlayer() {
                    completion(true)
                }
            }
        }
    }
    
    func modifyPlayer(completion: @escaping () -> Void) {
        let player = UserManager.shared.getLoggedPlayer()!
        do {
            try db.collection("players").document(player.id ?? "").setData(from: player)
            print(player)
            completion()
        } catch  {
            print(error)
            completion()
        }
    }
    
    func logout() {
        var player = UserManager.shared.getLoggedPlayer()!
        player.handCard = nil
        player.roomID = nil
        player.bet = nil
        player.number = nil
        player.host = false
        player.ready = false
        player.online = true
        modifyPlayer() {
            UserManager.shared.clearLoggedPlayer()
        }
    }
}
