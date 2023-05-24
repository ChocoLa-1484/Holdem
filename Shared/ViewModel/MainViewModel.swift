//
//  MainViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import Foundation

class MainViewModel: ObservableObject {
    @Published var playerCard: Card?
    func test() {
        let deck = Deck()
        saveDeck(deck: deck)
        playerCard = deck.cards.first
    }
}
