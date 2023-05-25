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

struct GamePlayer: Codable {
    let name: String
    let id: Int
    var money: Int
    
    var handCards: [Card]?
    
}

class RoomViewModel: ObservableObject {
    @Published var showRoom: Bool = false
    func createRoom(player: Player, completion: @escaping () -> Void) {
        let gamePlayer = GamePlayer(name: player.name, id: 0, money: player.money)
        let room = Room(roomId: generateRoomCode(length: 8), gameState: RoomStatus.waiting, players: [gamePlayer])
        room.saveRoom() { [self] in
            showRoom.toggle()
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
    
    func updateRoomMoney(name: String, newMoney: Int, completion: @escaping () -> Void) {
        db.collection("room").document(name).updateData(["money": newMoney]) { error in
            if let error = error {
                print("Error updating player's money in room collection: \(error.localizedDescription)")
            } else {
                print("Player's money updated in room collection.")
                completion()
            }
        }
    }
    
}
