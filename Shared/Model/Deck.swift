//
//  Deck.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI
import Foundation
import FirebaseFirestoreSwift

struct Deck: Codable{
    var cards: [Card] = []
    
    init() {
        for suit in Card.Suit.allCases {
            for rank in Card.Rank.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        shuffle()
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func deal() -> Card? {
        if !cards.isEmpty {
            return cards.removeLast()
        } else {
            return nil
        }
    }
}
