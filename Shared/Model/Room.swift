//
//  Room.swift
//  Holdem (iOS)
//
//  Created by User10 on BE 2566/5/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Room: Codable, Identifiable {
    @DocumentID var id: String?
    var roomStatus: String
    var players: [String]
    var deck: Deck?
}

