//
//  Room.swift
//  Holdem (iOS)
//
//  Created by User10 on BE 2566/5/24.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

struct Room: Codable {
    let roomId: String
    let gameState: String
    var playersId: [String]
}

func saveRoom(room: Room, player: Player) {
    do {
        let roomData = try Firestore.Encoder().encode(room)
        db.collection("rooms").document(room.roomId).setData(roomData) { error in
            if let error = error {
                print("Failed to store room data: \(error.localizedDescription)")
            } else {
                print("Room data stored successfully")
            }
        }
    } catch {
        print("Failed to encode room data: \(error.localizedDescription)")
    }
}
