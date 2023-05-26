//
//  GameViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/26.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published var playerCard: Card?
    func test() {
        let deck = Deck()
        saveDeck(deck: deck)
        playerCard = deck.cards.first
    }
}
