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
import FirebaseFirestoreSwift

struct Player: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    
    let account: String
    var password: String
    var name: String
    var money: Int
    var host: Bool
    var online: Bool
    var ready: Bool
    
    var number: Int?
    var roomID: String?
    var handCard: [Card]?
    var bet: Int?
}


