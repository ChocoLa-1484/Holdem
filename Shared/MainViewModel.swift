//
//  MainViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published var playerCard: Card?
    @Published var computerCard: Card?
    @Published var playerMoney: Int = 1000
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""

    private var deck: [Card] {
        var deck = [Card]()
        for suit in Card.Suit.allCases {
            for rank in Card.Rank.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        return deck.shuffled()
    }

    func drawCards() {
        let shuffledDeck = deck
        playerCard = shuffledDeck.first
        computerCard = shuffledDeck.last

        if let playerCard = playerCard, let computerCard = computerCard {
            if playerCard > computerCard {
                playerMoney += 100
                alertTitle = "恭喜你，獲勝了！"
            } else if playerCard < computerCard {
                playerMoney -= 100
                alertTitle = "很可惜，你輸了。"
            } else {
                alertTitle = "平手！"
            }

            if playerMoney <= 0 {
                alertTitle = "破產了！重新開始。"
                playerMoney = 1000
            }

            showAlert = true
        }
    }
}
