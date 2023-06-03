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
        round += 1
        
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, let room = try? snapshot.data(as: Room.self) else { return }
            self.room = room
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.dealRound(now: 0, times: 2)
            }
        }
    }
    func dealRound(now: Int, times: Int) {
        guard now < times else {
            // 所有玩家都已經發牌完成
            return
        }
        let dispatchGroup = DispatchGroup()
        for playerID in self.room.players {
            dispatchGroup.enter()
            self.dealOneCard(playerID: playerID) {
                print("Deal card to \(playerID) successfully")
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            print("Deal One Round finished")
            self.dealRound(now: now + 1, times: times)
        }
    }
    func dealOneCard(playerID: String, completion: @escaping () -> Void) {
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, var room = try? snapshot.data(as: Room.self) else {
                completion()
                return
            }
            var deck: Deck = room.deck ?? Deck()
            if deck.cards.isEmpty {
                print("No Cards")
                completion()
            } else {
                let card = deck.cards.removeFirst()
                room.deck = deck
                try? roomRef.setData(from: room) { error in
                    self.addHandCard(playerID: playerID, card: card) {
                        completion()
                    }
                }
            }
        }
    }
    
    func addHandCard(playerID: String, card: Card, completion: @escaping () -> Void){
        let playerRef = db.collection("players").document(playerID)
        playerRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, var player = try? snapshot.data(as: Player.self) else { return }
            if player.handCard == nil {
                player.handCard = []
            }
            player.handCard!.append(card)
            try? playerRef.setData(from: player) { error in
                completion()
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
        try? db.collection("players").document(player.id ?? "").setData(from: player)
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
