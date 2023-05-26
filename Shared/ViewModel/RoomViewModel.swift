//
//  RoomViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class RoomViewModel: ObservableObject {
    @Published var showRoom: Bool = false
    @Published var showAlert: Bool = false
    @Published var roomId: String = ""
    @Published var players: [Player] = []
    @Published var alert: Alert = Alert(title: Text("HI"))
    func createRoom(player: Player) {
        self.roomId = generateRoomCode(length: 8)
        searchDocument(collectionName: "player", fieldName: "account", target: player.account) { documentID in
            let room = Room(roomId: self.roomId, gameState: RoomStatus.waiting, players: [documentID!])
            room.saveRoom() { [self] in
                getPlayerData(documentID: documentID!) { player in
                    players.append(player!)
                    showRoom.toggle()
                }
            }
        }
    }
    
    func generateRoomCode(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomCode = ""
        
        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<characters.count)
            let character = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            randomCode.append(character)
        }
        
        return randomCode
    }
    
    func joinRoom(player: Player, roomId: String) {
        searchDocument(collectionName: "player", fieldName: "account", target: player.account) { playerID in
            searchDocument(collectionName: "room", fieldName: "roomId", target: roomId) { roomID in
                guard let roomID = roomID else {
                    self.showAlert = true
                    self.alert = Alert(
                        title: Text("Failed"),
                        message: Text("Room is not found"),
                        dismissButton: .default(Text("OK"))
                    )
                    return
                }
                let roomRef = db.collection("room").document(roomID)
                roomRef.updateData(["players": FieldValue.arrayUnion([playerID!])])
                self.alert = Alert(
                    title: Text("Success"),
                    message: Text("Room is found"),
                    dismissButton: .default(Text("OK")){
                        self.showRoom.toggle()
                    })
                self.showAlert.toggle()
            }
        }
    }
    
    func getPlayerData(documentID: String, completion: @escaping (Player?) -> Void) {
        let documentRef = db.collection("player").document(documentID)
        documentRef.getDocument { snapshot, error in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let documentData = snapshot?.data() else {
                print("Document data not found")
                completion(nil)
                return
            }
            
            do {
                let player = try Firestore.Decoder().decode(Player.self, from: documentData)
                completion(player)
            } catch {
                print("Failed to decode player data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

}
