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
import CoreMedia

class RoomViewModel: ObservableObject {
    @Published var showRoom: Bool = false
    @Published var showAlert: Bool = false
    @Published var roomId: String = ""
    @Published var players: [Player] = []
    @Published var alert: Alert = Alert(title: Text("HI"))
    
    func createRoom(player: Player) {
        self.roomId = generateRoomCode(length: 8)
        searchDocument(collectionName: "player", fieldName: "account", target: player.account) { playerID in
            let room = Room(roomId: self.roomId, roomStatus: "waiting", players: [playerID!])
            room.saveRoom() { [self] in
                getPlayerData(playerID: playerID!) { player in
                    players.append(player!)
                    print(players)
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
        getPlayerInFirestore(roomId: roomId) {
            print("Get player in firestore successfully.")
            print(self.players)
        }
        searchDocument(collectionName: "player", fieldName: "account", target: player.account) { playerID in
            searchDocument(collectionName: "room", fieldName: "roomId", target: roomId) { roomID in
                guard let roomID = roomID else {
                    self.alert = Alert(
                        title: Text("Failed"),
                        message: Text("Room is not found"),
                        dismissButton: .default(Text("OK"))
                    )
                    self.showAlert.toggle()
                    return
                }
                let roomRef = db.collection("room").document(roomID)
                roomRef.getDocument { (document, error) in
                    guard let document = document, document.exists else {
                        print("Document does not exist")
                        return
                    }
                    if let data = document.data(), let roomStatus = data["roomStatus"] as? String {
                        switch roomStatus {
                        case "waiting":
                            roomRef.updateData(["players": FieldValue.arrayUnion([playerID!])])
                            print("Room updated successfully!")
                            self.getPlayerData(playerID: playerID!) { player in
                                self.players.append(player!)
                                self.roomId = roomId
                                self.alert = Alert(
                                    title: Text("Success"),
                                    message: Text("Room is available"),
                                    dismissButton: .default(Text("OK")) {
                                        self.showRoom.toggle()
                                    }
                                )
                                print(self.roomId)
                                print(self.players)
                                self.showAlert.toggle()
                            }
                        case "gaming":
                            self.alert = Alert(
                                title: Text("Failed"),
                                message: Text("Game has started"),
                                dismissButton: .default(Text("OK"))
                            )
                            self.showAlert.toggle()
                        case "full":
                            self.alert = Alert(
                                title: Text("Failed"),
                                message: Text("Room is full"),
                                dismissButton: .default(Text("OK"))
                            )
                            self.showAlert.toggle()
                        default:
                            break
                        }
                    } else {
                        print("Players field does not exist or is not of type [String]")
                    }
                }
            }
        }
    }
    
    func getPlayerData(playerID: String, completion: @escaping (Player?) -> Void) {
        let playerRef = db.collection("player").document(playerID)
        playerRef.getDocument { snapshot, error in
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
    
    func getPlayerInFirestore(roomId: String, completion: @escaping () -> Void) {
        searchDocument(collectionName: "room", fieldName: "roomId", target: roomId) { roomID in
            guard let roomID = roomID else { return }
            let roomRef = db.collection("room").document(roomID)
            roomRef.getDocument { document, error in
                guard let document = document, document.exists else {
                    print("Document does not exist")
                    completion()
                    return
                }
                
                if let data = document.data(), let players = data["players"] as? [String] {
                    for playerId in players {
                        self.getPlayerData(playerID: playerId, completion: { player in
                            guard let player = player else { return }
                            self.players.append(player)
                            completion()
                        })
                    }
                } else {
                    print("Players field does not exist or is not of type [String]")
                    completion()
                }
            }
        }
    }
}
