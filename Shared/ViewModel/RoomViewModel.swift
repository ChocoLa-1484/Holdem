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
    @Published var roomID: String = ""
    @Published var alert: Alert = Alert(title: Text("HI"))
    
    @Published var room: [Room] = []
    @Published var players: [Player] = []
    
    func modifyRoom(room: Room) {
        do {
            try db.collection("rooms").document(room.id ?? "").setData(from: room)
        } catch  {
            print(error)
        }
    }
    
    func addRoom(room: Room) {
        do {
            _ = try db.collection("rooms").addDocument(from: room)
        } catch {
            print(error)
        }
    }
    
    func deleteRoom(room: Room) {
        let documentReference = db.collection("rooms").document(room.id ?? "")
        documentReference.delete()
    }
    
    func roomlistenChange() {
        db.collection("rooms").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    guard let room = try? documentChange.document.data(as: Room.self) else { break }
                    self.rooms.append(room)
                case .modified:
                    guard let targetRoom = try? documentChange.document.data(as: Room.self) else { break }
                    let index = self.rooms.firstIndex { room in
                        room.id == targetRoom.id
                    }
                    if let index = index {
                        self.rooms[index] = targetRoom
                    }
                case .removed:
                    guard let targetRoom = try? documentChange.document.data(as: Room.self) else { break }
                    let index = self.rooms.firstIndex { room in
                        room.id == targetRoom.id
                    }
                    if let index = index {
                        self.rooms.remove(at: index)
                    
                    }
                }
            }
        }
    }
    func modifyPlayer(player: Player) {
        do {
            try db.collection("rooms").document(self.roomID).collection("players").document(player.id ?? "").setData(from: player)
        } catch  {
            print(error)
        }
    }
    
    func addPlayer(player: Player) {
        do {
            _ = try db.collection("rooms").document(self.roomID).collection("players").addDocument(from: player)
        } catch {
            print(error)
        }
    }
    
    func deletePlayer(player: Player) {
        let documentReference = db.collection("rooms").document(self.roomID).collection("players").document(player.id ?? "")
        documentReference.delete()
    }
    
    func fetchPlayer(){
        let playerRef = db.collection("rooms").document(roomID).collection("players")
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
    
    func playerlistenChange() {
        db.collection("rooms").document(self.roomID).collection("players").addSnapshotListener { snapshot, error in
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
    }
    /*
    func saveRoom(completion: @escaping () -> Void) {
        let roomData: [String: Any] = [
            "roomID": self.roomID,
            "roomStatus": self.roomStatus
        ]
        let roomRef = db.collection("rooms").document()
        roomRef.setData(roomData)
        let roomId = roomRef.documentID
        for player in players {
            do {
                let playerRef = db.collection("rooms").document(roomId).collection("players")
                let _ = try playerRef.addDocument(from: player) { error in
                    if let error = error {
                        print("Failed to store player data: \(error.localizedDescription)")
                    } else {
                        print("Player data stored successfully")
                    }
                }
            } catch {
                print("Failed to encode player data: \(error.localizedDescription)")
            }
        }
    }
     */
    
    func createRoom(player: Player) {
        self.roomID = generateRoomCode(length: 8)
        let room = Room(roomID: self.roomID, roomStatus: "waiting", players: [player])
        addRoom(room: room)
        addPlayer(player: player)
        self.showRoom.toggle()
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
    
    func joinRoom(player: Player, roomID: String) {
        @FirestoreQuery(collectionPath: "rooms", predicates: [
            .isEqualTo("roomID", roomID)
        ]) var rooms: [Room]
    
        if rooms.isEmpty {
            self.alert = Alert(
                title: Text("Failed"),
                message: Text("Room is not found"),
                dismissButton: .default(Text("OK"))
            )
            self.showAlert.toggle()
            return
        }
        
        for room in rooms {
            switch room.roomStatus {
            case "waiting":
                self.roomID = roomID
                fetchPlayer()
                addPlayer(player: player)
                self.alert = Alert(
                    title: Text("Success"),
                    message: Text("Room is available"),
                    dismissButton: .default(Text("OK")) {
                        self.showRoom.toggle()
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
    
    func exitRoom(player: Player) {
        
        if player.host {
            deleteRoom(room: self)
            self.roomID = ""
            self.players = ""
        }
        
    }
}

// Firestore Query fetchPlayer
