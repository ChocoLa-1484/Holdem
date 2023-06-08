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
    @Published var showNotReady: Bool = false
    @Published var alert = Alert(title: Text("HI"))
    
    func addRoom(room: Room, roomID: String, completion: @escaping () -> Void) {
        do {
            _ = try db.collection("rooms").document(roomID).setData(from: room)
            print("addRoom Successfully")
            completion()
        } catch {
            print("addRoom Failed")
            completion()
        }
    }
    
    func deleteRoom(roomID: String) {
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.delete()
        print("deleteRoom Successfully")
    }
    
    func modifyPlayer(completion: @escaping () -> Void) {
        let player = UserManager.shared.getLoggedPlayer()!
        do {
            try db.collection("players").document(player.id ?? "").setData(from: player)
            completion()
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
        self.addRoom(room: room, roomID: roomID) {
            print("createRoom addRoom")
            self.modifyPlayer() {
                print("createRoom modifyPlayer")
                self.showRoom = true
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
    
    func roomListener() {
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        let roomRef = db.collection("rooms").document(roomID)
        
        var listener: ListenerRegistration?
        listener = roomRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, let room = try? snapshot.data(as: Room.self) else { return }
            if room.roomStatus == "gaming" {
                self.showGameView = true
                print("showGameView \(self.showGameView)")
                listener?.remove()
            }
        }
    }
    
    func joinRoom(roomID: String) {
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.getDocument { (snapshot, error) in
            guard let snapshot = snapshot, snapshot.exists, var room = try? snapshot.data(as: Room.self) else {
                self.alert = Alert(
                    title: Text("Failed"),
                    message: Text("Room is not found"),
                    dismissButton: .default(Text("OK")) {
                        self.showAlert = false
                    }
                )
                self.showAlert = true
                return
            }
    
            switch room.roomStatus {
            case "waiting":
                room.players.append(UserManager.shared.getLoggedPlayer()!.id ?? "Error")
                do {
                    try roomRef.setData(from: room)
                } catch {
                    print("Error")
                }
                var player = UserManager.shared.getLoggedPlayer()!
                player.roomID = roomID
                UserManager.shared.setLoggedPlayer(player)
                self.modifyPlayer() {
                    self.alert = Alert(
                        title: Text("Success"),
                        message: Text("Room is available"),
                        dismissButton: .default(Text("OK")) {
                            self.showAlert = false
                            self.showRoom = true
                        }
                    )
                    self.showAlert = true
                }
            case "gaming":
                self.alert = Alert(
                    title: Text("Failed"),
                    message: Text("Game has started"),
                    dismissButton: .default(Text("OK")) {
                        self.showAlert = false
                    }
                )
                self.showAlert = true
            case "full":
                self.alert = Alert(
                    title: Text("Failed"),
                    message: Text("Room is full"),
                    dismissButton: .default(Text("OK")) {
                        self.showAlert = false
                    }
                )
                self.showAlert = true
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
        player.handCard = nil
        self.showGameView = false
        if UserManager.shared.getLoggedPlayer()!.host {
            deleteAllPlayer(roomID: roomID) {
                self.deleteRoom(roomID: roomID)
                UserManager.shared.setLoggedPlayer(player)
                self.modifyPlayer() {}
            }
        } else {
            deletePlayerFromRoom(playerID: UserManager.shared.getLoggedPlayer()?.id ?? "", roomID: roomID)
            modifyPlayer() {}
        }
    }
    
    func deleteAllPlayer(roomID: String, completion: @escaping () -> Void) {
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else { return }
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
        }
    }

    
    func deletePlayerFromRoom(playerID: String, roomID: String) {
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.updateData(["players": FieldValue.arrayRemove([playerID])]) { error in
            if let error = error {
                print("Error deleting player from room: \(error)")
            } else {
                print("Player deleted from room successfully")
            }
        }
        db.collection("players").document(playerID).getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else { return }
            let playerRef = snapshot.reference
            playerRef.updateData(["roomID": FieldValue.delete()]) { error in
                if let error = error {
                    print("Error updating roomID: \(error)")
                } else {
                    print("roomID set to nil successfully")
                }
            }
        }
    }
    
    func startGame() {
        let roomID = UserManager.shared.getLoggedPlayer()!.roomID!
        let roomRef = db.collection("rooms").document(roomID)
        checkReady { isReady in
            if isReady {
                roomRef.getDocument{ snapshot, error in
                    guard let snapshot = snapshot, snapshot.exists, var room = try? snapshot.data(as: Room.self) else { return }
                    room.roomStatus = "gaming"
                    room.deck = Deck()
                    try? roomRef.setData(from: room) { error in
                        self.showGameView = true
                    }
                }
            } else {
                self.alert = Alert(
                    title: Text("Failed"),
                    message: Text("Player are not all ready"),
                    dismissButton: .default(Text("OK")) {
                        self.showNotReady = false
                    }
                )
                self.showNotReady = true
            }
        }
    }
    
    func getReady() {
        let playerID = UserManager.shared.getLoggedPlayer()!.id ?? ""
        let playerRef = db.collection("players").document(playerID)
        playerRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, var player = try? snapshot.data(as: Player.self) else { return }
            player.ready = !player.ready
            try? playerRef.setData(from: player)
        }
    }
    
    func checkReady(completion: @escaping (Bool) -> Void) {
        let roomID = UserManager.shared.getLoggedPlayer()!.roomID!
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else {
                completion(false)
                return
            }
            guard let room = try? snapshot.data(as: Room.self) else {
                print("Can't transform")
                completion(false)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var allReady = true
            
            for playerID in room.players {
                dispatchGroup.enter()
                let playerRef = db.collection("players").document(playerID)
                playerRef.getDocument { snapshot, error in
                    defer {
                        dispatchGroup.leave()
                    }
                    guard let snapshot = snapshot, snapshot.exists else { return }
                    guard let player = try? snapshot.data(as: Player.self) else { return }
                    if !player.ready {
                        allReady = false
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion(allReady)
            }
        }
    }

}

// Firestore Query fetchPlayer
