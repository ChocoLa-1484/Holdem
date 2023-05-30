//
//  GameViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/26.
//

import Foundation
import FirebaseFirestore

class GameViewModel: ObservableObject {
    @Published var round: Int = 0
    var room: Room = Room(roomStatus: "waiting", players: [])
    var roomID: String = ""
    var waiting: Bool = false
    func startGame() {
        print("Start Game")
        self.roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        let documentRef = db.collection("rooms").document(roomID)
        round += 1
        documentRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let roomData = snapshot.data() else { return }
            // 解析房间数据为 Room 对象，你需要根据你的数据模型进行调整
            if let room = try? Firestore.Decoder().decode(Room.self, from: roomData) {
                self.room = room
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.dealCardsToPlayers()
        }
//        self.dealCardsToPlayers(index: 0, count: 0, target: 2)
    }
    
    func dealCardsToPlayers() {
        for (index, playerID) in self.room.players.enumerated() {
            debugPrint("Deal card to \(index), \(playerID)")
            self.dealOneCard(playerID: playerID) {
                debugPrint("Deal card to \(index), \(playerID) successfully")
            }
        }
    }
    
    /*
    func gamelistenChange() {
        db.collection("rooms").document(roomID).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let roomData = snapshot.data() else {
                print("Room document data is nil")
                return
            }
            // 解析房间数据为 Room 对象，你需要根据你的数据模型进行调整
            if let room = try? Firestore.Decoder().decode(Room.self, from: roomData) {
                for playerID in room.players {
                    let playerRef = db.collection("players").document(playerID)
                    playerRef.addSnapshotListener { snapshot, error in
                        guard let snapshot = snapshot else {
                            print("Error fetching player document: \(error!)")
                            return
                        }
                    }
                }
            }
        }
    }*/
    func dealOneCard(playerID: String, completion: @escaping () -> Void) {
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        let documentRef = db.collection("rooms").document(roomID)
        documentRef.getDocument { snapshot, error in
            /*
            do {
                if let deckData = try snapshot?.data(as: Deck.self) {
                    print(deckData)
                }
            } catch {
                print("failed")
            }*/
            
            guard let snapshot = snapshot, snapshot.exists else { return }
            guard let roomData = snapshot.data() else { return }
            print("dealOneCard: \(roomData["deck"] ??  "HI")")
            let cardsData = roomData["deck"] as? [[String: Any]]
            print("dealOneCard: \(cardsData ?? [])")
            var cards: [Card] = []
            for cardData in cardsData ?? [] {
                if let suitRawValue = cardData["suit"] as? Int,
                   let rankRawValue = cardData["rank"] as? Int,
                   let suit = Card.Suit(rawValue: suitRawValue),
                   let rank = Card.Rank(rawValue: rankRawValue) {
                    let card = Card(suit: suit, rank: rank)
                    cards.append(card)
                }
            }
            print("dealOneCard: \(cards)")
            if cards.isEmpty {
                print("No Cards")
                completion()
            } else {
                let card = cards.removeFirst()
                self.saveDeck(deck: cards)
                self.addHandCard(playerID: playerID, card: card)
                completion()
            }
            
        }
        
    }
    
    func saveDeck(deck: [Card]) {
        let deckRef = db.collection("rooms").document(roomID)
        var cardsData: [[String: Int]] = []
        for card in deck {
            let cardData: [String: Int] = [
                "suit": card.suit.rawValue,
                "rank": card.rank.rawValue
            ]
            cardsData.append(cardData)
        }
        deckRef.setData(["cards": cardsData])
    }
    
    func addHandCard(playerID: String, card: Card){
        let playerRef = db.collection("players").document(playerID)
        playerRef.getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let playerData = snapshot.data() else { return }
            
            if (playerData["handCard"] as? [Card]) != nil {
                playerRef.updateData(["handCard": FieldValue.arrayUnion([card])])
                print("PlayerID: \(playerID), Update Data \(card.suit) \(card.rank)")
            } else {
                playerRef.setData(["handCard": card])
                print("PlayerID: \(playerID), Set Data \(card.suit) \(card.rank)")
            }
        }
    }
    /*
    func dealCardsToPlayers(index: Int, count: Int, target: Int) {
        guard index < self.room!.players.count else {
            // 所有玩家都已发牌，开始下一阶段
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.waitForPlayerToPlay(index: 0)
            }
            return
        }
        
        let playerID = room.players[index]
        
        if count < target {
            // 发一张牌给当前玩家
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dealOneCard(playerID: playerID)
                self.dealCardsToPlayers(index: index, count: count + 1, target: target)
            }
        } else {
            // 发牌给下一个玩家
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dealCardsToPlayers(index: index + 1, count: 0, target: target)
            }
        }
    }
    
    func waitForPlayerToPlay(index: Int) {
        guard index < room.players.count else {
            // 所有玩家都已出牌，继续下一阶段
            startNextPhase()
            return
        }
        
        // let playerID = room!.players[index]
        // 等待玩家出牌逻辑
        
        // 出牌完成后，等待下一个玩家出牌
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.waitForPlayerToPlay(index: index + 1)
        }
    }

    func startNextPhase() {
        dealCardsToPlayers(index: 0, count: 0, target: 1)
    }
    */
    
    func exitGame() {
        var player = UserManager.shared.getLoggedPlayer()!
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        player.roomID = nil
        player.host = false
        
        deletePlayerFromGame(playerID: UserManager.shared.getLoggedPlayer()?.id ?? "", roomID: roomID)
        modifyPlayer()
    }
    
    func modifyPlayer() {
        let player = UserManager.shared.getLoggedPlayer()!
        do {
            try db.collection("players").document(player.id ?? "").setData(from: player)
        } catch  {
            print(error)
        }
    }
    
    func deletePlayerFromGame(playerID: String, roomID: String) {
        let roomRef = db.collection("rooms").document(roomID)
        // 刪除rooms collection下players
        roomRef.updateData([
            "players": FieldValue.arrayRemove([playerID])
        ]) { error in
            if let error = error {
                print("Error deleting player from room: \(error)")
            } else {
                print("Player deleted from room successfully")
            }
        }
        // 刪除players collection下的roomID
        db.collection("players").document(playerID).getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                let playerRef = snapshot.reference
                playerRef.updateData(["roomID": FieldValue.delete()]) { error in
                    if let error = error {
                        print("Error updating roomID: \(error)")
                    } else {
                        print("roomID set to nil successfully")
                    }
                }
            } else {
                print("Player document does not exist")
            }
        }
    }
}
