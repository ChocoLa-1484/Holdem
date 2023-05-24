//
//  Deck.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI
import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestoreSwift

struct Deck: Codable {
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

func saveDeck(deck: Deck) {
    let deckRef = db.collection("deck").document()
    var cardsData: [[String: Int]] = []
    for card in deck.cards {
        let cardData: [String: Int] = [
            "suit": card.suit.rawValue,
            "rank": card.rank.rawValue
        ]
        cardsData.append(cardData)
    }
    deckRef.setData([
        "cards": cardsData
    ])
}
