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
    var roomStatus: String
    var players: [String]
    
    func saveRoom(completion: @escaping () -> Void) {
        do {
            try db.collection("room").document().setData(from: self) { error in
                if let error = error {
                    print("Failed to store room data: \(error.localizedDescription)")
                } else {
                    print("Room data stored successfully")
                    completion()
                }
            }
        } catch {
            print("Failed to encode room data: \(error.localizedDescription)")
        }
    }
    
    func getRoomField(roomId: String) {
        
    }
}
