//
//  Player.swift
//  Holdem (iOS)
//
//  Created by User10 on BE 2566/5/24.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

struct Player: Codable {
    var account: String
    var password: String
    
    var name: String
    var money: Int
    
    var currentRoom: String?
    var handCards: [Card]?
}

func savePlayer(player: Player, completion: @escaping () -> Void) {
    do {
        let playerData = try Firestore.Encoder().encode(player)
        db.collection("player").document().setData(playerData) { error in
            if let error = error {
                print("Failed to store player data: \(error.localizedDescription)")
            } else {
                print("Player data stored successfully")
                completion()
            }
        }
    } catch {
        print("Failed to encode player data: \(error.localizedDescription)")
    }
}
