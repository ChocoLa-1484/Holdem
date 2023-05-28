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
    @Published var showGameView: Bool = false
    @Published var alert: Alert = Alert(title: Text("HI"))
    @Published var rooms: [Room] = []

    func modifyRoom(room: Room) {
        do {
            try db.collection("rooms").document(room.id ?? "").setData(from: room)
        } catch  {
            print(error)
        }
    }
    
    func addRoom(room: Room, roomID: String) {
        do {
            _ = try db.collection("rooms").document(roomID).setData(from: room)
        } catch {
            print(error)
        }
    }
    
    func deleteRoom(roomID: String) {
        let documentReference = db.collection("rooms").document(roomID)
        documentReference.delete()
    }
    
    func roomlistenChange() {
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        let documentRef = db.collection("rooms").document(roomID)
        documentRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching room document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let roomData = snapshot.data() else {
                print("Room document data is nil")
                return
            }
            
            // 解析房间数据为 Room 对象，你需要根据你的数据模型进行调整
            if let room = try? Firestore.Decoder().decode(Room.self, from: roomData) {
                print("Room:", room)
                if room.roomStatus == "gaming" {
                    let deck = Deck()
                    let deckData = try? Firestore.Encoder().encode(deck)
                    db.collection("rooms").document(roomID).updateData(["deck": deckData!])
                    self.showGameView = true
                }
                for playerID in room.players {
                    let playerRef = db.collection("players").document(playerID)
                    playerRef.getDocument { snapshot, error in
                        guard let snapshot = snapshot else {
                            print("Error fetching player document: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        guard let playerData = snapshot.data() else {
                            print("Player document data is nil")
                            return
                        }
                        
                        // 解析玩家数据为 Player 对象，你需要根据你的数据模型进行调整
                        if let player = try? Firestore.Decoder().decode(Player.self, from: playerData) {
                            print("Player:", player)
                        } else {
                            print("Failed to decode player data")
                        }
                    }
                }
            } else {
                print("Failed to decode room data")
            }
        }
    }
    
    func modifyPlayer() {
        let player = UserManager.shared.getLoggedPlayer()!
        do {
            try db.collection("players").document(player.id ?? "").setData(from: player)
        } catch  {
            print(error)
        }
    }
    
    func createRoom() {
        let roomID = generateRoomCode(length: 8)
        let room = Room(roomStatus: "waiting", players: [UserManager.shared.getLoggedPlayer()!.id ?? ""])
        var player = UserManager.shared.getLoggedPlayer()!
        player.roomID = roomID
        player.host = true
        UserManager.shared.setLoggedPlayer(player)
        modifyPlayer()
        addRoom(room: room, roomID: roomID)
        self.showRoom = true
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
    
    func joinRoom(roomID: String) {
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.getDocument { (snapshot, error) in
            if let error = error {
                print("Error fetching room document: \(error)")
                return
            }
           
            guard let roomData = snapshot?.data() else {
                self.alert = Alert(
                    title: Text("Failed"),
                    message: Text("Room is not found"),
                    dismissButton: .default(Text("OK"))
                )
                self.showAlert.toggle()
                return
            }
            
            switch roomData["roomStatus"] as! String? {
            case "waiting":
                roomRef.updateData(["players": FieldValue.arrayUnion([UserManager.shared.getLoggedPlayer()!.id ?? ""])])
                var player = UserManager.shared.getLoggedPlayer()!
                player.roomID = roomID
                UserManager.shared.setLoggedPlayer(player)
                self.modifyPlayer()
                self.alert = Alert(
                    title: Text("Success"),
                    message: Text("Room is available"),
                    dismissButton: .default(Text("OK")) {
                        self.showRoom = true
                    }
                )
                self.showAlert.toggle()
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
        }
    }
    
    func exitRoom() {
        var player = UserManager.shared.getLoggedPlayer()!
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        player.roomID = nil
        player.host = false
        
        if UserManager.shared.getLoggedPlayer()!.host {
            deleteAllPlayer(roomID: roomID) {
                self.deleteRoom(roomID: roomID)
                UserManager.shared.setLoggedPlayer(player)
                self.modifyPlayer()
            }
        } else {
            deletePlayerFromRoom(playerID: UserManager.shared.getLoggedPlayer()?.id ?? "", roomID: roomID)
            modifyPlayer()
        }
    }
    
    func deleteAllPlayer(roomID: String, completion: @escaping () -> Void) {
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                guard let roomData = snapshot.data(),
                      let players = roomData["players"] as? [String] else {
                    return
                }
                for playerID in players {
                    let playerRef = db.collection("players").document(playerID)
                    playerRef.getDocument { snapshot, error in
                        guard let snapshot = snapshot else { return }
                        
                        if snapshot.exists {
                            playerRef.updateData(["roomID": FieldValue.delete()]) { error in
                                if let error = error {
                                    print("Error updating roomID for player \(playerID): \(error)")
                                } else {
                                    print("roomID set to nil for player \(playerID) successfully")
                                }
                            }
                        } else {
                            print("Player document does not exist")
                        }
                    }
                    self.deletePlayerFromRoom(playerID: playerID, roomID: roomID)
                    completion()
                }
            } else {
                print("Room document does not exist")
            }
        }
    }

    
    func deletePlayerFromRoom(playerID: String, roomID: String) {
        let roomRef = db.collection("rooms").document(roomID)
        // 刪除rooms collection下players
        roomRef.updateData([
            "players": FieldValue.arrayRemove([playerID])
        ]) { error in
            if let error = error {
                print("Error deleting player from room: \(error)")
            } else {
                print("Player deleted from room successfully")
            }
        }
        // 刪除players collection下的roomID
        db.collection("players").document(playerID).getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                let playerRef = snapshot.reference
                playerRef.updateData(["roomID": FieldValue.delete()]) { error in
                    if let error = error {
                        print("Error updating roomID: \(error)")
                    } else {
                        print("roomID set to nil successfully")
                    }
                }
            } else {
                print("Player document does not exist")
            }
        }
    }
}

// Firestore Query fetchPlayer
