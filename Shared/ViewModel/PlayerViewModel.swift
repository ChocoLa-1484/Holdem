//
//  PlayerViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/28.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class PlayerViewModel: ObservableObject {
    @Published players: [Player] = []
    func modifyPlayer(player: Player) {
        do {
            try db.collection("players").document(player.id ?? "").setData(from: player)
        } catch  {
            print(error)
        }
    }
    
    func addPlayer(player: Player) {
        do {
            _ = try db.collection("players").addDocument(from: player)
        } catch {
            print(error)
        }
    }
    
    func deletePlayer(player: Player) {
        let documentReference = db.collection("players").document(player.id ?? "")
        documentReference.delete()
    }
    
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
    }
    /*
    func playerlistenChange() {
        db.collection("players").document().addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    guard let player = try? documentChange.document.data(as: Player.self) else { break }
                    self.players.append(player)
                case .modified:
                    guard let targetPlayer = try? documentChange.document.data(as: Player.self) else { break }
                    let index = self.players.firstIndex { player in
                        player.id == targetPlayer.id
                    }
                    if let index = index {
                        self.players[index] = targetPlayer
                    }
                case .removed:
                    guard let targetPlayer = try? documentChange.document.data(as: Player.self) else { break }
                    let index = self.players.firstIndex { player in
                        player.id == targetPlayer.id
                    }
                    if let index = index {
                        self.players.remove(at: index)

                    }
                }
            }
        }
    }*/
}
